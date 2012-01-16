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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if (![[NSUserDefaults standardUserDefaults] stringForKey:@"nick_preference"]) {
    if (!myNicknameViewController)
      myNicknameViewController = [[NicknameViewController alloc] init];
    [self presentViewController:myNicknameViewController animated:NO completion:NULL];
  }   
  else {
    [[IcbConnection sharedInstance] connect];
    [[self navigationController] performSegueWithIdentifier:@"goTabBar" sender:self];
  }
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
