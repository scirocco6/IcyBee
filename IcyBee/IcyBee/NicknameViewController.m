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

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void) viewDidAppear:(BOOL)animated {
  [DefaultGroup  setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"channel_preference"]];
}

-(IBAction) joinButtonPressed {
  BOOL errors = NO;
  
//  [scrollView setFrame:CGRectMake(0, 0, 0, 0)];
  
  if ([Nickname text].length == 0) {
    [NicknameLabel setHidden:NO];
    errors = YES;
  }

  if ([Password text].length == 0) {
    [PasswordLabel setHidden:NO];
    errors = YES;
  }
  
  if ([ConfirmPassword text].length == 0) {
    [ConfirmPasswordLabel setHidden:NO];
    errors = YES;
  }
  
  if (![[ConfirmPassword text] isEqualToString:[Password text]]) {
    [PasswordLabel setHidden:NO];
    [ConfirmPasswordLabel setHidden:NO];
    errors = YES;
  }
  
  if([DefaultGroup text].length == 0) {
    [DefaultGroupLabel setHidden:NO];
    errors = YES;
  }
  
  if(!errors) {
    [[NSUserDefaults standardUserDefaults] setObject:[Nickname text]          forKey:@"nick_preference"];
    [[NSUserDefaults standardUserDefaults] setObject:[Password text]          forKey:@"pass_preference"];
    [[NSUserDefaults standardUserDefaults] setObject:[DefaultGroup text] forKey:@"channel_preference"];

    [[NSUserDefaults standardUserDefaults] synchronize];
  
    [self dismissViewControllerAnimated:YES completion:NULL];
  }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  switch (textField.tag) {
    case 0:
      [scrollView setContentOffset:CGPointMake(0, 100) animated:YES];
      [NicknameLabel setHidden:YES];
      break;
    case 1:
      [scrollView setContentOffset:CGPointMake(0, 150) animated:YES];
      [PasswordLabel setHidden:YES];
      [ConfirmPasswordLabel setHidden:YES];
      break;
    case 2:
      [scrollView setContentOffset:CGPointMake(0, 200) animated:YES];
      [PasswordLabel setHidden:YES];
      [ConfirmPasswordLabel setHidden:YES];
      break;
  }
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

@end
