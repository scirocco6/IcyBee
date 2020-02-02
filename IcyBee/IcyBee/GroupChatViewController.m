//
//  ChannelView.m
//  IcyBee
//
//  Created by Michelle Six on 12/26/11.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import "GroupChatViewController.h"
#import "IcbConnection.h"


@implementation GroupChatViewController
@synthesize inputTextField;

- (void) updateView {
  [[self navBar] setTitle:[[IcbConnection sharedInstance] currentChannel]];
  [[self tabBarItem] setTitle:[[IcbConnection sharedInstance] currentChannel]];

  [super updateView];
}

#pragma mark - View lifecycle
- (void) viewDidLoad {
  viewType = 'c';
  [super viewDidLoad];
  [self setAutomaticallyAdjustsScrollViewInsets:YES];
}

- (void)viewWillAppear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
  [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillChangeFrameNotification
                                                object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillHideNotification
                                                object:nil];
  [super viewWillDisappear:animated];
}

#pragma mark - UITextFieldDelegate
- (void)keyboardWillChangeFrame:(NSNotification *) notification {
  CGSize keyboardSize    = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
  NSValue *keyboardValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];

  CGRect keyboardScreenEndFrame = keyboardValue.CGRectValue;
  CGRect keyboardViewEndFrame   = [self.view convertRect:keyboardScreenEndFrame toView:self.view.window];
    
  CGRect aRect = self.view.frame;

  aRect.size.height -= keyboardSize.height;
  if (!CGRectContainsPoint(aRect, inputTextField.frame.origin) ) {
    int offset = self.view.frame.size.height - keyboardViewEndFrame.origin.y;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, offset, 0);
      
    [scrollView setContentInset:contentInsets];
    [scrollView setScrollIndicatorInsets:contentInsets];
  }
}

- (void) keyboardWillHide:(NSNotification *) notification {
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
