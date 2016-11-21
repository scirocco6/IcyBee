//
//  ChatMessage.h
//  IcyBee
//
//  Created by Michelle Six on 1/15/12.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ChatMessage : NSManagedObject

@property (nonatomic, retain) NSString  *type;
@property (nonatomic, retain) NSDate    *timeStamp;
@property (nonatomic, retain) NSString  *sender;
@property (nonatomic, retain) NSString  *text;
//@property (nonatomic)         CGFloat   height;
@property (nonatomic)         float     height;
@property (nonatomic)         BOOL      url;
@property (nonatomic)         BOOL      image;
@property (nonatomic)         BOOL      needsSize;
@property (nonatomic)         int       groupIndex;
@property (nonatomic)         int       privateIndex;
@property (nonatomic)         int       urlIndex;

@end
