//
//  FirstViewController.m
//  IcyBee
//
//  Created by Michelle Six on 1/15/12.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import "FirstViewController.h"
#import "IcbConnection.h"

@implementation FirstViewController

- (void) preConnect{
  if (![IcbConnection hasConnectivity]) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Unavailable"
                                                    message:@"Icy Bee needs to be connected to the internet to function.  Please connect to a network and click, \"retry\""
                                                   delegate:self
                                          cancelButtonTitle:@"retry"
                                          otherButtonTitles:nil];
    [alert show];
  }
  else if ([[NSUserDefaults standardUserDefaults] stringForKey:@"nick_preference"])
    [self connect];
  else {
    [scrollView setHidden:NO];
    [DefaultGroup  setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"channel_preference"]];
  }
}

- (void) connect {
  [[IcbConnection sharedInstance] connect];
  [[self navigationController] performSegueWithIdentifier:@"goTabBar" sender:self];
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    if ([[UIScreen mainScreen] bounds].size.height == 568)
      [[self backgroundImageView] setImage: [UIImage imageNamed:@"background-568h@2x.png"]];
    else
      [[self backgroundImageView] setImage: [UIImage imageNamed:@"background.png"]];  }
  return self;
}

- (void) viewWillAppear:(BOOL)animated {
  [self preConnect];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  [self preConnect];
}

#pragma mark - Form controls

-(IBAction) joinButtonPressed {
  BOOL errors = NO;
    
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
    [[NSUserDefaults standardUserDefaults] setObject:[DefaultGroup text]      forKey:@"channel_preference"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self connect];
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

@end
