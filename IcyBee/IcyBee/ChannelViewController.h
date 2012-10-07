//
//  ChannelViewController.h
//  IcyBee
//
//  Created by Michelle Six on 12/26/11.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>  {
  IBOutlet UIScrollView   *scrollView;
  BOOL                    shouldScrollToBottom;

  NSString                *htmlStart, *htmlFinish;
  NSMutableArray *messageArray;
}

@property (nonatomic, strong) IBOutlet  UITableView       *channelTableView;
@property (nonatomic, strong) IBOutlet  UINavigationItem  *navBar;
//@property (nonatomic, retain)           NSMutableArray    *messageArray;
@property (nonatomic, strong) IBOutlet  UITextField       *inputTextField;

- (void) keyboardWillShow:(NSNotification *) notification;
- (void) keyboardDidHide:(NSNotification *) notification;
- (void) updateView;
- (void) fetchRecords;
- (void) reJiggerCells;
@end
