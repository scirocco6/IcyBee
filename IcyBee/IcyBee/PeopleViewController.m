//
//  PeopleViewController.m
//  IcyBee
//
//  Created by Michelle Six on 12/26/11.
//  Copyright (c) 2011 The Home for Obsolete Technology. All rights reserved.
//

#import "PeopleViewController.h"
#import "Person.h"
#import "IcbConnection.h"

@implementation PeopleViewController
@synthesize peopleArray, peopleTableView;

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
  [peopleTableView reloadData];
}

- (void)fetchRecords {   
  NSEntityDescription *entity     = [NSEntityDescription entityForName:@"People" inManagedObjectContext: [[IcbConnection sharedInstance] managedObjectContext]];   
  NSFetchRequest      *request    = [[NSFetchRequest alloc] init];  
  
  [request setEntity:entity];
  
  // Define how we will sort the records  
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"nickname" ascending:YES];  
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
  [self setPeopleArray: mutableFetchResults];  
}   

-(IBAction) joinGroup:(UIButton *) sender {
  People *entry  = [peopleArray objectAtIndex: [sender tag]];
  
  NSLog(@"Join Group button pressed Row: %i, Nick %@", [sender tag], [entry nickname]);
  [[IcbConnection sharedInstance] joinGroupWithUser:[entry nickname]];
}

-(IBAction) messageUser {
  NSLog(@"Message User button pressed");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {  
  return [peopleArray count];  
}   

- (Person *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  Person *cell   = [tableView dequeueReusableCellWithIdentifier:@"person"];
	People *entry  = [peopleArray objectAtIndex: [indexPath row]];  
  
  NSDate *signonDate    = [[NSDate alloc] initWithTimeIntervalSince1970:[[entry signon] intValue]];
  
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

  [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
  [dateFormatter setDateStyle:NSDateFormatterShortStyle];
  [dateFormatter setLocale:[NSLocale currentLocale]];
  NSString *signonString  = [dateFormatter stringFromDate:signonDate];

  int seconds  = [[entry idle] integerValue];
  int days     = seconds / (24 * 60 * 60);
  seconds     -= days * 24 * 60 * 60;
  int hours    = seconds / (60 * 60);
  seconds     -= hours * 60 * 60;
  int minutes  = seconds / 60;
  seconds -= minutes * 60;
  
  NSString *idleString = [[NSString alloc] init];

  if (days > 0) {
    if (days > 1) {
      idleString = [idleString stringByAppendingFormat:@"%i days, ", days];
    }
    else {
      idleString = [idleString stringByAppendingFormat:@"%i day, ", days];
    }
  }
  if (hours > 0) {
    if (hours > 1) {
      idleString = [idleString stringByAppendingFormat:@"%i hours, ", hours];
    }
    else {
      idleString = [idleString stringByAppendingFormat:@"%i hour, ", hours];
    }
  }
  if (minutes > 0) {
    if (minutes > 1) {
      idleString = [idleString stringByAppendingFormat:@"%i minutes, ", minutes];
    }
    else {
      idleString = [idleString stringByAppendingFormat:@"%i minute, ", minutes];
    }
  }
  if (!days) { // there's no room for, and little point in reporting, seconds if the person has been idle over 24 hours
    if (seconds > 1) {
      idleString = [idleString stringByAppendingFormat:@"%i seconds  ", seconds];
    }
    else {
      idleString = [idleString stringByAppendingFormat:@"%i second  ", seconds]; // note 2 spaces on end
    }
  }
  idleString = [idleString substringToIndex:[idleString length] - 2 ]; // trim off either a trailing comma and space or trailing two spaces

  [[cell nickname]  setText: [entry nickname]];
  [[cell group]     setText: [entry group]];
  [[cell idle]      setText: idleString];
  [[cell signon]    setText: signonString];
  [[cell account]   setText: [entry account]];
  
  [[cell joinButton] setTag:[indexPath row]];
  return cell;
}


#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewWillAppear:(BOOL)animated {
  [[IcbConnection sharedInstance] setFront:self]; // tell the icb connection that we are the frontmost window and should get updates
  [[IcbConnection sharedInstance] globalWhoList];
  [super viewWillAppear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
