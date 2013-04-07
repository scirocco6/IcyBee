//
//  PeopleViewController.h
//  IcyBee
//
//  Created by Michelle Six on 12/26/11.
//  Copyright (c) 2011 The Home for Obsolete Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IcbConnection.h"


@interface PeopleViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, IcbDisplayDelegate> {
  NSMutableArray *peopleArray;
  IBOutlet UIActivityIndicatorView *activity;
  IBOutlet UITableView *myTableView;
}

@property (nonatomic, strong) IBOutlet  UIImageView     *backgroundImageView;
@property (nonatomic, strong) IBOutlet  UITableView     *peopleTableView;

- (void) fetchRecords;

@end
