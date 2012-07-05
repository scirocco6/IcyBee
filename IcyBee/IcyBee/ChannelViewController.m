//
//  ChannelView.m
//  IcyBee
//
//  Created by Michelle Six on 12/26/11.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import "AppDelegate.h"
#import "ChannelViewController.h"
#import "IcbConnection.h"

@implementation ChannelViewController
@synthesize messageArray;   

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void) updateView {
  [self fetchRecords];  
  [[self tableView] reloadData];
  
  // scroll to bottom
  //
  //TODO do not scroll to bottom if the user has scrolled us elsewhere
  //
  int lastRowNumber = [[self tableView] numberOfRowsInSection:0] - 1;
  if(lastRowNumber > 0) {
    NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
    [[self tableView] scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
  }
}

- (void)fetchRecords {   
  NSEntityDescription *entity     = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext: [[IcbConnection sharedInstance] managedObjectContext]];   
  NSFetchRequest      *request    = [[NSFetchRequest alloc] init];  
  NSPredicate         *predicate  = [NSPredicate predicateWithFormat: @"type IN %@", [NSArray arrayWithObjects:@"b", @"c", @"d", @"f", @"k", nil]];
  
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
  [self setMessageArray: mutableFetchResults];  
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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {  
  return [messageArray count];  
}   

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"Cell";  
  static NSDateFormatter *dateFormatter = nil;   
  
  if (dateFormatter == nil) {  
    dateFormatter = [[NSDateFormatter alloc] init];  
    [dateFormatter setDateFormat:@"h:mm.ss a"];  
  }  
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];   
  
  if (cell == nil) {  
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];  
  }   
  
  ChatMessage *message = [messageArray objectAtIndex: [indexPath row]];  
  ChatMessage *previousEvent = nil;   
  
  if ([messageArray count] > ([indexPath row] + 1)) {  
    previousEvent = [messageArray objectAtIndex: ([indexPath row] + 1)];  
  }  
  
  [cell.textLabel setText: [message sender]]; 
  [cell.detailTextLabel setText: [message text]];
  
  if (previousEvent) {  
// someday this will be used to glom together sequential messages from the same nick
  }   
  
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Navigation logic may go here. Create and push another view controller.
  /*
   <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
   // ...
   // Pass the selected object to the new view controller.
   [self.navigationController pushViewController:detailViewController animated:YES];
   */
}

@end
