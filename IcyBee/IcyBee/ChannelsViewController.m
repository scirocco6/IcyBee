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


-(IBAction) newGroup {
  NSLog(@"New group button pressed");
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
  [myTableView setHidden:YES];
  [activity startAnimating];
  
  [[IcbConnection sharedInstance] setFront:self]; // tell the icb connection that we are the frontmost window and should get updates
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

@end
