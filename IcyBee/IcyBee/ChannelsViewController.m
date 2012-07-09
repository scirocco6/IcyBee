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
@synthesize channelTableView, groupArray;

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
  [self setGroupArray: mutableFetchResults];  
}   


-(IBAction) newGroup {
  NSLog(@"New group button pressed");
}

#pragma mark - View lifecycle


- (void)viewDidLoad { // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
  
  [super viewDidLoad];
}

- (void)viewDidUnload {
  [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
  [[IcbConnection sharedInstance] setFront:self]; // tell the icb connection that we are the frontmost window and should get updates
  [[IcbConnection sharedInstance] globalWhoList];
  [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // Navigation logic may go here. Create and push another view controller.
  /*
   <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
   // ...
   // Pass the selected object to the new view controller.
   [self.navigationController pushViewController:detailViewController animated:YES];
   */
}



@end
