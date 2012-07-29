//
//  ChannelMessage.h
//  IcyBee
//
//  Created by Michelle Six on 7/26/12.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ChannelMessage : UITableViewCell <UIWebViewDelegate>
  @property (nonatomic, strong) IBOutlet UIWebView         *message;
  @property (nonatomic, strong)          NSManagedObjectID *objectID;
@end
