//
//  BrowserViewController.m
//  IcyBee
//
//  Created by Michelle Six on 10/7/12.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import "BrowserViewController.h"

@interface BrowserViewController ()

@end

@implementation BrowserViewController

+ (BrowserViewController *)sharedInstance {
	static BrowserViewController *sharedInstance;
  
	if (!sharedInstance)
		sharedInstance = [[BrowserViewController alloc] initWithNibName:@"BrowserViewController" bundle:nil];
  
	return sharedInstance;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)post:(NSURLRequest *)request {
  [browser loadRequest:request];
}

-(IBAction) doneButtonPressed {
  [self dismissViewControllerAnimated:YES completion:NULL];
}

-(IBAction) backButtonPressed {
  [browser goBack];
}

@end
