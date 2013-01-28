//
//  IcbTableViewController.m
//  IcyBee
//
//  Created by Michelle Six on 10/9/12.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import "IcbTableViewController.h"
#import "IcbMessage.h"
#import "BrowserViewController.h"

NSString const * htmlBegin = @""
"<html>"
"<head>"
"<style type=\"text/css\">"
"body {margin: 0; padding: 0; font-family: \"helvetica\"; font-size: 15;}"
"span {color:white}"
"A:link {text-decoration: underline; color: yellow}"
"A:visited {text-decoration: underline; color: blue;}"
"A:active {text-decoration: underline; color: red;}"
"</style>"
"</head>"
"<body>";

NSString const * htmlEnd = @"</body></html>";

@interface IcbTableViewController ()

@end

@implementation IcbTableViewController

@synthesize dataTableView;

- (NSString *) tableIdentifier {
  return @"baseTable";
}

- (int) rowCount {
  switch (viewType) {
    case 'c': {
      return [[IcbConnection sharedInstance] lastGroupMessage];
      break;
    }
    case 'p': {
      return [[IcbConnection sharedInstance] lastPrivateMessage];
      break;
    }
    case 'u': {
      return [[IcbConnection sharedInstance] lastUrlMessage];
      break;
    }
    default:    // this should never ever happen
      return 0;
  }
}

- (void) updateView {
  [dataTableView reloadData];
  
  [self scrollToBottom];
}

- (void) reJiggerCells {
  [dataTableView beginUpdates];
  [dataTableView endUpdates];

  [self scrollToBottom];
}

- (void) scrollToBottom {
  if(shouldScrollToBottom == NO)
    return;
  
  int lastRowNumber = [self rowCount] -1;
  
  if(lastRowNumber > 0)
    [dataTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastRowNumber inSection:0]
                         atScrollPosition:UITableViewScrollPositionBottom
                                 animated:YES];
}

- (void) popBrowser {
  [self presentViewController:[BrowserViewController sharedInstance] animated:YES completion:NULL];
}

- (void)scrollViewDidScroll: (UIScrollView *)myScrollView {
  if ([myScrollView isDragging]) { // we only care if the user is dragging us
    if(self.dataTableView.contentOffset.y<0){ // table view is pulled down like twitter refresh
      return;
    }
    else if(self.dataTableView.contentOffset.y >= (self.dataTableView.contentSize.height - self.dataTableView.bounds.size.height)) { // bottom
      shouldScrollToBottom = YES;
    }
    else // user has scrolled somewhere other than the bottom, don't move it on them
      shouldScrollToBottom = NO;
  }
}

- (IBAction) messageUser:(UIButton *) sender {
  ChatMessage *entry = [self messageForIndex: [sender tag]];
  
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[entry sender]
                                                  message:nil
                                                 delegate:self
                                        cancelButtonTitle:@"Cancel"
                                        otherButtonTitles:@"Send", nil];
  [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
  [alert show];
}

#pragma mark - UIAlertViewDelegate

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
  NSString *inputText = [[alertView textFieldAtIndex:0] text];
  
  NSLog(@"Input length == %i", [inputText length]);
  return [inputText length] == 0 ? NO : YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
  if([title isEqualToString:@"Send"])
    [[IcbConnection sharedInstance] sendPrivateMessage:[NSString stringWithFormat:@"%@ %@", [alertView title], [[alertView textFieldAtIndex:0] text]]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return([self rowCount]);
}

- (ChatMessage *) messageForIndex:(int) index {
  NSPredicate *predicate;
  switch (viewType) {
    case 'c': {
      predicate = [NSPredicate predicateWithFormat: @"groupIndex == %i", index];
      break;
    }
    case 'p': {
      predicate = [NSPredicate predicateWithFormat: @"privateIndex == %i", index];
      break;
    }
    case 'u': {
      predicate = [NSPredicate predicateWithFormat: @"urlIndex == %i", index];
      break;
    }
  }
  
  [request setEntity:entity];
  [request setPredicate:predicate];

  NSError *error;
  NSMutableArray *fetchResults = [[[[IcbConnection sharedInstance] managedObjectContext] executeFetchRequest:request error:&error] mutableCopy];
  
  assert(fetchResults);
  
  return([fetchResults objectAtIndex:0]);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  ChatMessage *entry = [self messageForIndex: [indexPath row]];

  return [entry height];
}

- (IcbMessage *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  IcbMessage *cell = [tableView dequeueReusableCellWithIdentifier:@"person"];
  ChatMessage *entry = [self messageForIndex:[indexPath row]];

  [cell setObjectID:[entry objectID]];
  [cell setNeedsSize:[entry needsSize]];
  [[cell messageButton] setTag: [indexPath row]];
  [cell setIcbTableController:self];
  
  if (![entry needsSize]) { // if we know the correct size then size the webview correctly
    CGRect frame = [[cell message] frame];

    frame.size.height = [entry height];
    [[cell message] setFrame: frame];
    
    CGRect cellFrame = [cell frame];
    cellFrame.size.height = frame.size.height + 1;
    [cell setFrame: cellFrame];
  }
  
  if ([[entry type] compare:@"c"] == NSOrderedSame) { // private message
    [[cell message] loadHTMLString: [NSString stringWithFormat:@"%@"
                                     "<span style='color:#00FF00; margin-right:5px;'>&lt&#42;%@&#42;&gt</span>"
                                     "<span><i style='color: #00FF00'>%@</i></span>"
                                     "%@",
                                     htmlBegin, [entry sender], [entry text], htmlEnd] baseURL:nil];
  }
  else if ([[entry type] compare:@"o"] == NSOrderedSame) { // server responce from a command
    [[cell message] loadHTMLString: [NSString stringWithFormat:@"%@"
                                     "<span><i style='color: #FFF0F0'>%@</i></span>"
                                     "%@",
                                     htmlBegin, [entry text], htmlEnd] baseURL:nil];
  }
  else if ([[entry type] compare:@"d"] == NSOrderedSame) { // server responce from a command
    [[cell message] loadHTMLString: [NSString stringWithFormat:@"%@"
                                     "<span style='color:#FFAAAA; margin-right:5px;'>&lt%@&gt</span>"
                                     "<span>%@</span>"
                                     "%@",
                                     htmlBegin, [entry sender], [entry text], htmlEnd] baseURL:nil];
  }
  else { // open channel message
    [[cell message] loadHTMLString: [NSString stringWithFormat:@"%@"
                                     "<span style='color:#FF00FF; margin-right:5px;'>&lt%@&gt</span>"
                                     "<span>%@</span>"
                                     "%@",
                                     htmlBegin, [entry sender], [entry text], htmlEnd] baseURL:nil];
  }
  
  return cell;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
  [dataTableView setAllowsSelection:NO];
  shouldScrollToBottom  = YES;
  entity                = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext: [[IcbConnection sharedInstance] managedObjectContext]];
  request               = [[NSFetchRequest alloc] init];
  
  if ([[UIScreen mainScreen] bounds].size.height == 568)
    [[self backgroundImageView] setImage: [UIImage imageNamed:@"background-568h@2x.png"]];
  else
    [[self backgroundImageView] setImage: [UIImage imageNamed:@"background.png"]];
  
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
  [self updateView];
  [[IcbConnection sharedInstance] setFront:self]; // tell the icb connection that we are the frontmost window and should get updates
  [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
  // cleanup datastructures from who and people views
  [[IcbConnection sharedInstance] deletePeopleEntries];
  [[IcbConnection sharedInstance] deleteWhoEntries];
}

@end
