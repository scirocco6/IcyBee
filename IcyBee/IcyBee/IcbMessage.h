//
//  UrlMessage.h
//  IcyBee
//
//  Created by Michelle Six on 10/3/12.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class IcbMessage;

@protocol IcbMessageDelegate <NSObject>
- (BOOL) isFront;
- (void) reJiggerCells;
- (void) popBrowser;
@end

@interface IcbMessage : UITableViewCell <UIWebViewDelegate>
@property (nonatomic)         id       <IcbMessageDelegate>   messageDelegate;
@property (nonatomic, strong) IBOutlet UIWebView              *message;
@property (nonatomic, strong) IBOutlet UIButton               *messageButton;
@property (nonatomic, strong)          NSManagedObjectID      *objectID;
@property (nonatomic)                  BOOL                   needsSize;
@end
