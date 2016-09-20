//
//  ChannelViewController.h
//  IcyBee
//
//  Created by Michelle Six on 12/26/11.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IcbTableViewController.h"

@interface GroupChatViewController : IcbTableViewController <UITextFieldDelegate>  {
  IBOutlet UIScrollView   *scrollView;
}

//@property (nonatomic, strong) IBOutlet  UINavigationItem  *navBar;
@property (nonatomic, strong) IBOutlet  UITextField       *inputTextField;

- (void) keyboardWillShow:(NSNotification *) notification;
- (void) keyboardDidHide:(NSNotification *) notification;

@end
