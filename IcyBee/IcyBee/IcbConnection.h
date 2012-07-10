//
//  IcbConnection.h
//  tab_icb
//
//  Created by Michelle Six on 4/6/10.
//  Copyright (c) 2010 The Home for Obsolete Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import <CFNetwork/CFHost.h>
#import <CFNetwork/CFSocketStream.h>
#import "ChatMessage.h"
#import "Group.h"
#import "People.h"

@interface IcbConnection : NSObject <NSStreamDelegate> {
	CFReadStreamRef         myReadStream;
	CFWriteStreamRef        myWriteStream;
  NSInputStream           *inputStream;
  NSOutputStream          *outputStream;
  NSManagedObjectContext  *managedObjectContext;
  Boolean                 loggedIn, snarfing, whoing;
  int                     length, count;
  uint8_t                 readBuffer[256];
  uint8_t                 writeBuffer[256];
  UIViewController        *front;
}

@property (nonatomic, retain) NSManagedObjectContext  *managedObjectContext;
@property (nonatomic, retain) UIViewController        *front;

+ (IcbConnection *)	sharedInstance;
- (void) connect;
- (void) handlePacket;
- (void) assemblePacketOfType:(char) packetType, ...;
- (void) sendPacket;
- (void) globalWhoList;
- (void) addToChatFromSender:(NSString *) sender type:(char) type text:(NSString *) text;
- (void) addGroup:(NSString *) name moderator:(NSString *) moderator topic:(NSString *) topic;
- (void) addPerson:(NSString *) nickname idle:(NSNumber *) idle signon:(NSNumber *) signon account:(NSString *) account;

@end
