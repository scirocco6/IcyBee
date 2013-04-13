//
//  IcbTableViewController.h
//  IcyBee
//
//  Created by Michelle Six on 10/9/12.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IcbConnection.h"
#import "IcbMessage.h"

@interface IcbTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate, IcbDisplayDelegate, IcbMessageDelegate> {
  NSMutableArray      *dataArray;
  BOOL                shouldScrollToBottom;
  char                viewType;
  NSEntityDescription *entity;
  NSFetchRequest      *request;
}

@property (nonatomic, strong) IBOutlet  UIImageView       *backgroundImageView;
@property (nonatomic, strong) IBOutlet  UITableView       *dataTableView;
@property (nonatomic, strong) IBOutlet  UINavigationItem  *navBar;

@end
