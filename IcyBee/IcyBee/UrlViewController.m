//
//  UrlViewController.m
//  IcyBee
//
//  Created by Michelle Six on 12/26/11.
//  Copyright (c) 2011 The Home for Obsolete Technology. All rights reserved.
//


#import "UrlViewController.h"
#import "UrlMessage.h"
#import "IcbConnection.h"

@implementation UrlViewController
@synthesize urlArray, urlTableView;

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}

- (void) updateView {
  [self fetchRecords];
  [urlTableView reloadData];
  
  // scroll to bottom
  //
  //TODO do not scroll to bottom if the user has scrolled us elsewhere
  //
  int lastRowNumber = [urlTableView numberOfRowsInSection:0] - 1;
  if(lastRowNumber > 0) {
    NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
    [urlTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
  }
}

- (void) reJiggerCells {
  [urlTableView beginUpdates];
  [urlTableView endUpdates];
}

- (void)fetchRecords {
  NSEntityDescription *entity     = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext: [[IcbConnection sharedInstance] managedObjectContext]];
  NSFetchRequest      *request    = [[NSFetchRequest alloc] init];
  NSPredicate         *predicate  = [NSPredicate predicateWithFormat: @"url == YES"];
  
  [request setEntity:entity];
  [request setPredicate:predicate];
  
  // Define how we will sort the records
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:YES];
  NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
  [request setSortDescriptors:sortDescriptors];
  
  // Fetch the records and handle an error
  NSError *error;
  NSMutableArray *mutableFetchResults = [[[[IcbConnection sharedInstance] managedObjectContext] executeFetchRequest:request error:&error] mutableCopy];
  
  if (!mutableFetchResults) {
    // Handle the error.
    // This is a serious error and should advise the user to restart the application
  }
  
  // Save our fetched data to an array
  [self setUrlArray: mutableFetchResults];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [urlArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  ChatMessage *entry = [urlArray objectAtIndex: [indexPath row]];
  
  if ([entry height]) {
    return [entry height];
  }
  else {
    return 0.0f; // this will get resized once the webview loads and a height is computed
  }
}

- (UrlMessage *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UrlMessage *cell = [tableView dequeueReusableCellWithIdentifier:@"person"];
	ChatMessage *entry = [urlArray objectAtIndex: [indexPath row]];
  
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  
  [dateFormatter setTimeStyle: NSDateFormatterShortStyle];
  [dateFormatter setDateStyle: NSDateFormatterShortStyle];
  [dateFormatter setLocale: [NSLocale currentLocale]];
  
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
  
  return cell;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
  [self updateView];
  [[IcbConnection sharedInstance] setFront:self]; // tell the icb connection that we are the frontmost window and should get updates
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // Return YES for supported orientations
  return YES;
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  if (navigationType == UIWebViewNavigationTypeOther)
    return YES;
  return NO;
}

@end
