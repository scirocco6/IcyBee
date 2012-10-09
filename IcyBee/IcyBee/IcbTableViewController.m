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

- (void) updateView {
  [self fetchRecords];
  [dataTableView reloadData];
  
  [self scrollToBottom];
}

- (void) reJiggerCells {
  [dataTableView beginUpdates];
  [dataTableView endUpdates];
  
  [self scrollToBottom];
}

- (void) scrollToBottom {
  // scroll to bottom
  
  if(shouldScrollToBottom == NO)
    return;
  
  int lastRowNumber = [dataArray count] -1;
  
  if(lastRowNumber > 0) {
    NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
    ChatMessage *entry = [dataArray objectAtIndex: [ip row]];
    
    if ([entry height] > 0)
      [dataTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];
  }
}

- (void)fetchRecords {
  // STUB must be implemented by each actual view class
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [dataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  ChatMessage *entry = [dataArray objectAtIndex: [indexPath row]];
  
  if ([entry height]) {
    return [entry height];
  }
  else {
    return 0.0f; // this will get resized once the webview loads and a height is computed
  }
}

- (IcbMessage *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  IcbMessage *cell = [tableView dequeueReusableCellWithIdentifier:@"person"];
	ChatMessage *entry = [dataArray objectAtIndex: [indexPath row]];
  
  if ([[entry type] compare:@"c"] == NSOrderedSame) { // private message
    [[cell message] loadHTMLString: [NSString stringWithFormat:@""
                                     "<html>"
                                     "<head> \n"
                                     "<style type=\"text/css\">"
                                     "body {margin: 0; padding: 0; font-family: \"helvetica\"; font-size: 15;}"
                                     "span {color:white}"
                                     "</style>"
                                     "</head>"
                                     "<body>"
                                     "<span style='color:#00FF00; margin-right:5px;'>&lt&#42;%@&#42;&gt</span>"
                                     "<span><i style='color: #00FF00'>%@</i></span>"
                                     "</body>"
                                     "</html>",
                                     [entry sender], [entry text]] baseURL:nil];
  }
  else { // open channel message
    [[cell message] loadHTMLString: [NSString stringWithFormat:@""
                                     "<html>"
                                     "<head> \n"
                                     "<style type=\"text/css\">"
                                     "body {margin: 0; padding: 0; font-family: \"helvetica\"; font-size: 15;}"
                                     "span {color:white}"
                                     "</style>"
                                     "</head>"
                                     "<body>"
                                     "<span style='color:#FF00FF; margin-right:5px;'>&lt%@&gt</span>"
                                     "<span>%@</span>"
                                     "</body>"
                                     "</html>",
                                     [entry sender], [entry text]] baseURL:nil];
  }
  [[[cell message] scrollView] setScrollEnabled:NO];
  [cell setObjectID:[entry objectID]];
  [cell setIcbTableController:self];
  
  return cell;
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
  [self updateView];
  [[IcbConnection sharedInstance] setFront:self]; // tell the icb connection that we are the frontmost window and should get updates
  [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // Return YES for supported orientations
  return YES;
}
@end
