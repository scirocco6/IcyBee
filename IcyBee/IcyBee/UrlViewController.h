//
//  UrlViewController.h
//  IcyBee
//
//  Created by Michelle Six on 12/26/11.
//  Copyright (c) 2011 The Home for Obsolete Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UrlViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>  {
  NSMutableArray *privateArray;
}

@property (nonatomic, strong) IBOutlet  UITableView       *urlTableView;
@property (nonatomic, strong) IBOutlet  UINavigationItem  *navBar;
@property (nonatomic, retain)           NSMutableArray    *urlArray;

- (void) updateView;
- (void) fetchRecords;
- (void) reJiggerCells;
@end
