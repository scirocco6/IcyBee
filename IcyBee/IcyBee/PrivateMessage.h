//
//  PrivateMessage.h
//  IcyBee
//
//  Created by Michelle Six on 7/10/12.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface PrivateMessage : UITableViewCell
  @property (nonatomic, strong) IBOutlet UIWebView         *message;
  @property (nonatomic, strong)          NSManagedObjectID *objectID;
@end
