//
//  PrivateViewController.m
//  IcyBee
//
//  Created by Michelle Six on 12/26/11.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import "PrivateViewController.h"

@implementation PrivateViewController

- (void)fetchRecords {   
  NSEntityDescription *entity     = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext: [[IcbConnection sharedInstance] managedObjectContext]];   
  NSFetchRequest      *request    = [[NSFetchRequest alloc] init];  
  NSPredicate         *predicate  = [NSPredicate predicateWithFormat: @"type IN %@", @[@"c", @"k"]];
  
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
  dataArray = mutableFetchResults;
}

#pragma mark - View lifecycle
- (void) viewDidLoad {
  viewType = 'p';
  [super viewDidLoad];
}

@end