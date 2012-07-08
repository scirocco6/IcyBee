//
//  ChannelsViewController.h
//  IcyBee
//
//  Created by Michelle Six on 12/26/11.
//  Copyright (c) 2011 The Home for Obsolete Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
  UITableView *channelTableView;

  NSMutableArray *groupArray;
}

@property (nonatomic, retain) NSMutableArray *groupArray;  

@property (nonatomic, retain) UITableView *channelTableView;


-(IBAction) newGroup; 

@end
