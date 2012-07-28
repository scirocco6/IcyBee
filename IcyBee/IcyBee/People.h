//
//  People.h
//  IcyBee
//
//  Created by Michelle Six on 7/9/12.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface People : NSManagedObject

@property (nonatomic, retain) NSString * account;
@property (nonatomic, retain) NSString * group;
@property (nonatomic, retain) NSNumber * idle;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSNumber * signon;

@end
