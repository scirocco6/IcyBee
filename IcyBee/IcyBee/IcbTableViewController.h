//
//  IcbTableViewController.h
//  IcyBee
//
//  Created by Michelle Six on 10/9/12.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IcbConnection.h"

@interface IcbTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
  NSMutableArray *dataArray;
  BOOL           shouldScrollToBottom;
}

@property (nonatomic, strong) IBOutlet  UITableView       *dataTableView;
@property (nonatomic, strong) IBOutlet  UINavigationItem  *navBar;

- (void) updateView;
- (void) fetchRecords;
- (void) reJiggerCells;
- (void) popBrowser;

@end
