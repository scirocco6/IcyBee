//
//  NicknameViewController.m
//  IcyBee
//
//  Created by Michelle Six on 1/14/12.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import "NicknameViewController.h"
#import "IcbConnection.h"

@implementation NicknameViewController

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

-(IBAction) joinButtonPressed {
  [scrollView setFrame:CGRectMake(0, 0, 0, 0)];

  NSUserDefaults  *defaults       = [NSUserDefaults standardUserDefaults]; 
  [defaults setObject:[Nickname text] forKey:@"nick_preference"];
  [defaults synchronize];
  
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  switch (textField.tag) {
    case 0:
      [scrollView setContentOffset:CGPointMake(0, 100) animated:YES];
      break;
    case 1:
      [scrollView setContentOffset:CGPointMake(0, 150) animated:YES];
      break;
    case 2:
      [scrollView setContentOffset:CGPointMake(0, 200) animated:YES];
      break;
  }
  return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
  [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
  return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
  switch (textField.tag) {
    case 0:
      [Password becomeFirstResponder];
      break;
    case 1:
      [ConfirmPassword becomeFirstResponder];
      break;
    default:
      [textField resignFirstResponder];
      break;
  }
  return YES;
}


@end
