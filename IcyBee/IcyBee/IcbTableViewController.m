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

- (BOOL) isFront {
  return ([[IcbConnection sharedInstance] displayDelegate] == self);
}

- (void) popBrowser {
  [self presentViewController:[BrowserViewController sharedInstance] animated:YES completion:NULL];
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
  
  return [inputText length] == 0 ? NO : YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
  if([title isEqualToString:@"Send"]) {
    [[IcbConnection sharedInstance] sendPrivateMessage:[NSString stringWithFormat:@"%@ %@", [alertView title], [[alertView textFieldAtIndex:0] text]]];
    [[IcbConnection sharedInstance] addToChatFromSender:[[IcbConnection sharedInstance] currentNickname] type:'c' text:[[alertView textFieldAtIndex:0] text]];
  }
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
  ChatMessage *entry = [self messageForIndex: (int) [indexPath row]];

  return [entry height];
}

- (IcbMessage *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  IcbMessage *cell = [tableView dequeueReusableCellWithIdentifier:@"person"];
  ChatMessage *entry = [self messageForIndex: (int) [indexPath row]];

  [cell setMessageDelegate:self];
  [cell setObjectID:[entry objectID]];
  [cell setNeedsSize:[entry needsSize]];
  [[cell messageButton] setTag: [indexPath row]];
  
  if (![entry needsSize]) { // if we know the correct size then size the webview correctly
    CGRect frame = [[cell message] frame];

    frame.size.height = [entry height];
    [[cell message] setFrame: frame];
    
    CGRect cellFrame = [cell frame];
    cellFrame.size.height = frame.size.height + 1;
    [cell setFrame: cellFrame];
  }
  
  [[cell message] loadHTMLString: [entry text] baseURL:nil];

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
  [[IcbConnection sharedInstance] setDisplayDelegate:self]; // tell the icb connection that we are the frontmost window and should get updates
  [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
  // cleanup datastructures from who and people views
  [[IcbConnection sharedInstance] deletePeopleEntries];
  [[IcbConnection sharedInstance] deleteWhoEntries];
}

@end
