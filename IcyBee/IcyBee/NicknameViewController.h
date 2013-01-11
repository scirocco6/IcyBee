//
//  NicknameViewController.h
//  IcyBee
//
//  Created by Michelle Six on 1/14/12.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NicknameViewController : UIViewController <UITextFieldDelegate> {
  IBOutlet UITextField		*Nickname;
  IBOutlet UITextField		*Password;
  IBOutlet UITextField		*ConfirmPassword;
  IBOutlet UITextField    *DefaultGroup;
  IBOutlet UILabel        *NicknameLabel;
  IBOutlet UILabel        *PasswordLabel;
  IBOutlet UILabel        *ConfirmPasswordLabel;
  IBOutlet UILabel        *DefaultGroupLabel;
  IBOutlet UIScrollView   *scrollView;  
}
-(IBAction) joinButtonPressed;

@end
