//
//  ChannelView.m
//  IcyBee
//
//  Created by Michelle Six on 12/26/11.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import "Constants.h"
#import "ChannelViewController.h"
#import "ChannelMessage.h"
#import "IcbConnection.h"


@implementation ChannelViewController
@synthesize inputTextField;

- (void) updateView {
  [[self navBar] setTitle:[[IcbConnection sharedInstance] currentChannel]];
  
  [super updateView];
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
  dataArray = mutableFetchResults;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:)  name:UIKeyboardDidHideNotification  object:nil];
  
  [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillShowNotification
                                                object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillHideNotification
                                                object:nil];
  [super viewWillDisappear:animated];
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
