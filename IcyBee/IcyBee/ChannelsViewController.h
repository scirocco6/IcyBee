//
//  ChannelsViewController.h
//  IcyBee
//
//  Created by Michelle Six on 12/26/11.
//  Copyright (c) 2011 The Home for Obsolete Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
  NSMutableArray *groupArray;
  IBOutlet UIActivityIndicatorView *activity;
  IBOutlet UITableView *myTableView;
}

@property (nonatomic, strong) IBOutlet  UITableView     *channelTableView;
@property (nonatomic, retain)           NSMutableArray  *groupArray;  

-(IBAction) newGroup; 
- (void) fetchRecords;

@end
