//
//  ChannelViewController.h
//  IcyBee
//
//  Created by Michelle Six on 12/26/11.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelViewController : UITableViewController  {
  NSMutableArray *messageArray;
}

@property (nonatomic, retain) NSMutableArray *messageArray;   

- (void) fetchRecords;  
@end
