//
//  PrivateViewController.h
//  IcyBee
//
//  Created by Michelle Six on 12/26/11.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrivateViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>  {
  IBOutlet UIScrollView   *scrollView;
  NSMutableArray          *privateArray;
  BOOL                    shouldScrollToBottom;
}

@property (nonatomic, strong) IBOutlet  UITableView       *privateTableView;
@property (nonatomic, strong) IBOutlet  UINavigationItem  *navBar;
@property (nonatomic, retain)           NSMutableArray    *privateArray;
@property (nonatomic, strong) IBOutlet  UITextField       *inputTextField;

- (void) keyboardWillShow:(NSNotification *) notification;
- (void) keyboardDidHide:(NSNotification *) notification;
- (void) updateView;
- (void) fetchRecords;
- (void) reJiggerCells;
@end
