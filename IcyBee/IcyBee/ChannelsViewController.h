//
//  ChannelsViewController.h
//  IcyBee
//
//  Created by Michelle Six on 12/26/11.
//  Copyright (c) 2011 The Home for Obsolete Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
  NSMutableArray *groupArray;
  IBOutlet UIActivityIndicatorView *activity;
  IBOutlet UITableView *myTableView;
}

@property (nonatomic, strong) IBOutlet  UIImageView     *backgroundImageView;
@property (nonatomic, strong) IBOutlet  UITableView     *channelTableView;

-(IBAction) newGroup; 
- (void) fetchRecords;

@end
