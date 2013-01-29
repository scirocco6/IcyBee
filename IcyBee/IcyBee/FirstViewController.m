//
//  FirstViewController.m
//  IcyBee
//
//  Created by Michelle Six on 1/15/12.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

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
  [spinnyThing setHidden:NO];
  [messageLabel setText:@"connecting"];
  [messageLabel setHidden:NO];
  
  [[IcbConnection sharedInstance] setFront:self];
  [[IcbConnection sharedInstance] connect];
}

- (void) connected {
  [spinnyThing setHidden:YES];
  [messageLabel setHidden:YES];
  
  [[self navigationController] performSegueWithIdentifier:@"goTabBar" sender:self];
}

- (void) setStatus:(NSString *) message {
  [messageLabel setText:message];
}

#pragma mark - View lifecycle

-(void) viewDidLoad {
  [super viewDidLoad];
  
  CALayer *layer = [joinButton layer];
  layer.backgroundColor = [[UIColor clearColor] CGColor];
  layer.borderColor = [[UIColor darkGrayColor] CGColor];
  layer.cornerRadius = 8.0f;
  layer.borderWidth = 1.0f;
  
  [joinButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
  [joinButton setTitle:@"JOIN" forState:UIControlStateHighlighted];
  
  if ([[UIScreen mainScreen] bounds].size.height == 568)
    [[self backgroundImageView] setImage: [UIImage imageNamed:@"background-568h@2x.png"]];
  else
    [[self backgroundImageView] setImage: [UIImage imageNamed:@"background.png"]];
  
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
