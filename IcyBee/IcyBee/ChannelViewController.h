//
//  ChannelViewController.h
//  IcyBee
//
//  Created by Michelle Six on 12/26/11.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate, UITextFieldDelegate>  {
  IBOutlet UIScrollView   *scrollView;

  NSMutableArray *messageArray;
}

@property (nonatomic, strong) IBOutlet  UITableView       *channelTableView;
@property (nonatomic, strong) IBOutlet  UINavigationItem  *navBar;
@property (nonatomic, retain)           NSMutableArray    *messageArray;
@property (nonatomic, strong) IBOutlet  UITextField       *inputTextField;

- (void) keyboardWillShow:(NSNotification *) notification;
- (void) keyboardDidHide:(NSNotification *) notification;
- (BOOL) webView:(UIWebView *) webView shouldStartLoadWithRequest:(NSURLRequest *) request navigationType:(UIWebViewNavigationType) navigationType;
- (void) updateView;
- (void) fetchRecords;  
@end
