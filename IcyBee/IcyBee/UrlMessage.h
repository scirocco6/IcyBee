//
//  UrlMessage.h
//  IcyBee
//
//  Created by Michelle Six on 10/3/12.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "UrlViewController.h"

@interface UrlMessage : UITableViewCell <UIWebViewDelegate>
@property (nonatomic, strong) IBOutlet UIWebView              *message;
@property (nonatomic, strong)          NSManagedObjectID      *objectID;
@property (nonatomic, strong)          UrlViewController      *urlController;
@end
