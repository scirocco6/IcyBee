//
//  ChannelView.m
//  IcyBee
//
//  Created by Michelle Six on 12/26/11.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import "ChannelViewController.h"
#import "ChannelMessage.h"
#import "IcbConnection.h"

@implementation ChannelViewController
@synthesize channelTableView, inputTextField;

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}

- (void) updateView {
  [[self navBar] setTitle:[[IcbConnection sharedInstance] currentChannel]];
  [self fetchRecords];
  [channelTableView reloadData];
  
  [self scrollToBottom];
}

- (void) reJiggerCells {
  [channelTableView beginUpdates];
  [channelTableView endUpdates];
  
  [self scrollToBottom];
}

- (void) scrollToBottom {
  // scroll to bottom

  if(shouldScrollToBottom == NO)
    return;
  
  int lastRowNumber = [messageArray count] -1;
 
  if(lastRowNumber > 0) {
    NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
    ChatMessage *entry = [messageArray objectAtIndex: [ip row]];
    
    if ([entry height] > 0)
      [channelTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];
  }
}

- (void)fetchRecords {
  NSEntityDescription *entity     = [NSEntityDescription entityForName:@"ChatMessage"
                                                inManagedObjectContext: [[IcbConnection sharedInstance] managedObjectContext]];
  NSFetchRequest      *request    = [[NSFetchRequest alloc] init];
  NSPredicate         *predicate  = [NSPredicate predicateWithFormat: @"type IN %@", @[@"b", @"c", @"d", @"f", @"k", @"o"]];
  
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
  messageArray = mutableFetchResults;
}

- (void)scrollViewDidScroll: (UIScrollView *)myScrollView {
  if ([myScrollView isDragging]) { // we only care if the user is dragging us
    if(self.channelTableView.contentOffset.y<0){ // table view is pulled down like twitter refresh
      return;
    }
    else if(self.channelTableView.contentOffset.y >= (self.channelTableView.contentSize.height - self.channelTableView.bounds.size.height)) { // bottom
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [messageArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  ChatMessage *entry = [messageArray objectAtIndex: [indexPath row]];
  
  if ([entry height]) {
    return [entry height];
  }
  else {
    return 0.0f; // this will get resized once the webview loads and a height is computed
  }
}

- (ChannelMessage *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ChannelMessage *cell = [tableView dequeueReusableCellWithIdentifier:@"person"];
	ChatMessage *entry = [messageArray objectAtIndex: [indexPath row]];
  
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  
  [dateFormatter setTimeStyle: NSDateFormatterShortStyle];
  [dateFormatter setDateStyle: NSDateFormatterShortStyle];
  [dateFormatter setLocale: [NSLocale currentLocale]];

  if ([[entry type] compare:@"c"] == NSOrderedSame) { // private message
    [[cell message] loadHTMLString: [NSString stringWithFormat:@"%@"
                                        "<span style='color:#00FF00; margin-right:5px;'>&lt&#42;%@&#42;&gt</span>"
                                        "<span><i style='color: #00FF00'>%@</i></span>"
                                     "%@",
                                     htmlStart, [entry sender], [entry text], htmlFinish] baseURL:nil];
  }
  else if ([[entry type] compare:@"o"] == NSOrderedSame) { // server responce from a comand
    [[cell message] loadHTMLString: [NSString stringWithFormat:@"%@"
                                        "<span><i style='color: #FFF0F0'>%@</i></span>"
                                     "%@",
                                     htmlStart, [entry text], htmlFinish] baseURL:nil];
  }
  else { // open channel message
    [[cell message] loadHTMLString: [NSString stringWithFormat:@"%@"
                                         "<span style='color:#FF00FF; margin-right:5px;'>&lt%@&gt</span>"
                                         "<span>%@</span>"
                                     "%@",

                                     htmlStart, [entry sender], [entry text], htmlFinish] baseURL:nil];
  }
  [[[cell message] scrollView] setScrollEnabled:NO];
  [cell setObjectID:[entry objectID]];

  return cell;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
  shouldScrollToBottom = YES;
  
  htmlStart = @""
  "<html>"
  "<head> \n"
  "<style type=\"text/css\">"
  "body {margin: 0; padding: 0; font-family: \"helvetica\"; font-size: 15;}"
  "span {color:white}"
  "A:link {text-decoration: underline; color: yellow}"
  "A:visited {text-decoration: underline; color: blue;}"
  "A:active {text-decoration: underline; color: red;}"
  "</style>"
  "</head>"
  "<body>";
  
  htmlFinish = @""
  "</body>"
  "</html>";
  
  [super viewDidLoad];
}

- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
  NSLog(@"Setting navBar to %@", [[IcbConnection sharedInstance] currentChannel]);
  [self updateView];
  [[IcbConnection sharedInstance] setFront:self]; // tell the icb connection that we are the frontmost window and should get updates

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:)  name:UIKeyboardDidHideNotification  object:nil];
  
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillShowNotification
                                                object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillHideNotification
                                                object:nil];
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

#pragma mark - UITextFieldDelegate

- (void)keyboardWillShow:(NSNotification *) notification {
  NSLog(@"keyboard in channel");
  CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

  CGRect aRect = self.view.frame;
  
  aRect.size.height -= keyboardSize.height;
  if (!CGRectContainsPoint(aRect, inputTextField.frame.origin) ) {
    CGPoint scrollPoint = CGPointMake(0.0, inputTextField.frame.origin.y - (keyboardSize.height - (inputTextField.frame.size.height + 7)));
    [scrollView setContentOffset:scrollPoint animated:YES];
  }
}

- (void) keyboardDidHide:(NSNotification *) notification {
  [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  [inputTextField resignFirstResponder];
  
  if([[inputTextField text] length]) {
    [[IcbConnection sharedInstance] processInput: [inputTextField text]];
    [inputTextField setText:@""];
  }
  
  return YES;
}

@end
