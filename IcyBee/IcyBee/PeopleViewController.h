//
//  PeopleViewController.h
//  IcyBee
//
//  Created by Michelle Six on 12/26/11.
//  Copyright (c) 2011 The Home for Obsolete Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeopleViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
  NSMutableArray *peopleArray;
  IBOutlet UIActivityIndicatorView *activity;
  IBOutlet UITableView *myTableView;
}

@property (nonatomic, strong) IBOutlet  UITableView     *peopleTableView;

- (void) fetchRecords;

@end
