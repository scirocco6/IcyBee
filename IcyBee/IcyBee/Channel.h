//
//  Channel.h
//  IcyBee
//
//  Created by Michelle Six on 7/8/12.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Channel : UITableViewCell 
  @property (nonatomic, strong) IBOutlet UILabel *groupName;
  @property (nonatomic, strong) IBOutlet UILabel *groupModerator;
  @property (nonatomic, strong) IBOutlet UILabel *groupTopic;

@end
