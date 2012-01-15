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
	[self dismissModalViewControllerAnimated:NO];
  [[IcbConnection sharedInstance] connect];
}
@end
