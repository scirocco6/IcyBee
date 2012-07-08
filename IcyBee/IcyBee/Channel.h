//
//  Channel.h
//  IcyBee
//
//  Created by Michelle Six on 7/8/12.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Channel : NSObject
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, copy) NSString *groupModerator;
@property (nonatomic, copy) NSString *groupTopic;

@end
