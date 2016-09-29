//
//  ChannelView.m
//  IcyBee
//
//  Created by Michelle Six on 12/26/11.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import "Constants.h"
#import "GroupChatViewController.h"
#import "IcbConnection.h"


@implementation GroupChatViewController
@synthesize inputTextField;

- (void) updateView {
  [[self navBar] setTitle:[[IcbConnection sharedInstance] currentChannel]];
  
  [super updateView];
}

#pragma mark - View lifecycle
- (void) viewDidLoad {
  viewType = 'c';
  [super viewDidLoad];
  [self setAutomaticallyAdjustsScrollViewInsets:YES];
}

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
      UIEdgeInsets contentInsets = UIEdgeInsetsMake(scrollView.contentInset.top, 0.0, keyboardSize.height, 0.0);
      scrollView.contentInset = contentInsets;
      scrollView.scrollIndicatorInsets = contentInsets;
  }
}


- (void) keyboardDidHide:(NSNotification *) notification {
  UIEdgeInsets contentInsets = UIEdgeInsetsMake(scrollView.contentInset.top, 0.0, 0.0, 0.0);
  scrollView.contentInset = contentInsets;
  scrollView.scrollIndicatorInsets = contentInsets;
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
