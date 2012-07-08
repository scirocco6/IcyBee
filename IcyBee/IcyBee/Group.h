//
//  Group.h
//  IcyBee
//
//  Created by Michelle Six on 7/8/12.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * moderator;
@property (nonatomic, retain) NSString * topic;

@end
