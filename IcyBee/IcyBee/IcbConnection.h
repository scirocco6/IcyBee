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

@interface IcbConnection : NSObject <NSStreamDelegate, UIAlertViewDelegate> {
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
  NSString                *currentChannel, *currentNickname, *whoChannel;
}

@property (nonatomic, retain) UIApplication           *application;
@property (nonatomic, retain) NSManagedObjectContext  *managedObjectContext;
@property (retain)            UIViewController        *front;
@property (nonatomic, retain) NSString                *currentChannel;
@property (nonatomic, retain) NSString                *currentNickname;
@property BOOL                                        inBackground;
@property int                                         lastGroupMessage;
@property int                                         lastPrivateMessage;
@property int                                         lastUrlMessage;

+ (IcbConnection *)	sharedInstance;
- (void) connect;
- (void) handlePacket;
- (void) assemblePacketOfType:(char) packetType, ...;
- (void) sendPacket;
- (void) globalWhoList;
- (void) globalGroupList;
- (void) addToChatFromSender:(NSString *) sender type:(char) type text:(NSString *) text;
- (void) addGroup:(NSString *) name moderator:(NSString *) moderator topic:(NSString *) topic;
- (void) addPerson:(NSString *) nickname group:(NSString *) group idle:(NSNumber *) idle signon:(NSNumber *) signon account:(NSString *) account;
- (void) joinGroup:(NSString *) group;
- (void) joinGroupWithUser:(NSString *) user;
- (void) processInput:(NSString *) line;
- (void) sendBeep:(NSString *) user;
- (void) sendNop;
- (void) sendPrivateMessage:(NSString *) message;
- (void) sendSixTheTime;
- (void) deleteAllTables;
- (void) deleteWhoEntries;
- (void) deletePeopleEntries;

@end
