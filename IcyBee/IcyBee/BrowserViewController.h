//
//  BrowserViewController.h
//  IcyBee
//
//  Created by Michelle Six on 10/7/12.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrowserViewController : UIViewController <UIWebViewDelegate> {
  IBOutlet UIWebView         *browser;
  IBOutlet UINavigationItem  *navBar;
}
+ (BrowserViewController *) sharedInstance;
- (void)post:(NSURLRequest *)request;

@end
