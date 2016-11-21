//
//  ChannelsViewController.m
//  IcyBee
//
//  Created by Michelle Six on 12/26/11.
//  Copyright (c) 2011 The Home for Obsolete Technology. All rights reserved.
//

#import "ChannelsViewController.h"
#import "IcbConnection.h"
#import "Channel.h"

@implementation ChannelsViewController
@synthesize channelTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      // Custom initialization
  }
  return self;
}

- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
    
  // Release any cached data, images, etc that aren't in use.
}

- (void) updateView {
  [self fetchRecords];
  [channelTableView reloadData];
}

- (void)fetchRecords {   
  NSEntityDescription *entity     = [NSEntityDescription entityForName:@"Group" inManagedObjectContext: [[IcbConnection sharedInstance] managedObjectContext]];   
  NSFetchRequest      *request    = [[NSFetchRequest alloc] init];  
  
  [request setEntity:entity];
  
  // Define how we will sort the records  
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];  
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
  groupArray = mutableFetchResults;
  
  [activity stopAnimating];
  [myTableView setHidden:NO];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
  if ([[UIScreen mainScreen] bounds].size.height == 568)
    [[self backgroundImageView] setImage: [UIImage imageNamed:@"background-568h@2x.png"]];
  else
    [[self backgroundImageView] setImage: [UIImage imageNamed:@"background.png"]];
  
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
  [myTableView setHidden:YES];
  [activity startAnimating];
  
  [[IcbConnection sharedInstance] setDisplayDelegate:self]; // tell the icb connection that we are the frontmost window and should get updates
  [[IcbConnection sharedInstance] globalGroupList];
  [super viewWillAppear:animated];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  Group   *entry  = [groupArray objectAtIndex: [indexPath row]];
  
  [[IcbConnection sharedInstance] joinGroup:[entry name]];
  [[self tabBarController] setSelectedIndex:2];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {  
  return [groupArray count];  
}   

- (Channel *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  Channel *cell   = [tableView dequeueReusableCellWithIdentifier:@"group"];
	Group   *entry  = [groupArray objectAtIndex: [indexPath row]];  

  [[cell groupName]       setText: [entry name]];
  [[cell groupModerator]  setText: [entry moderator]];
  [[cell groupTopic]      setText: [entry topic]];
  
  return cell;
}

-(IBAction) newGroup {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Group"
                                                  message:nil
                                                 delegate:self
                                        cancelButtonTitle:@"Cancel"
                                        otherButtonTitles:@"Join", nil];
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
  NSString *inputText = [[alertView textFieldAtIndex:0] text];

  if(([title isEqualToString:@"Join"]) && ([inputText length] != 0)) {
    [[IcbConnection sharedInstance] joinGroup:inputText];
    [[self tabBarController] setSelectedIndex:2];
  }
}

@end
