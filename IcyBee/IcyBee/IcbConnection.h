//
//  IcbConnection.h
//  tab_icb
//
//  Created by Michelle Six on 4/6/10.
//  Copyright (c) 2010 The Home for Obsolete Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
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
  Boolean                 dropping, loggedIn, firstTime, authenticated, snarfing, whoing;
  int                     length, count;
  uint8_t                 readBuffer[256];
  uint8_t                 writeBuffer[256];
  UIViewController        *front;
  NSString                *currentChannel, *currentNickname, *currentPassword, *whoChannel;
}

@property (nonatomic, retain) UIApplication           *application;
@property (nonatomic, retain) NSManagedObjectContext  *managedObjectContext;
@property (nonatomic, retain) UILabel                 *connectionLabel;
@property (retain)            UIViewController        *front;
@property (nonatomic, retain) NSString                *currentChannel;
@property (nonatomic, retain) NSString                *currentNickname;
@property BOOL                                        inBackground;
@property int                                         lastGroupMessage;
@property int                                         lastPrivateMessage;
@property int                                         lastUrlMessage;

+ (IcbConnection *)	sharedInstance;
+ (BOOL) hasConnectivity;
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
- (void) deleteAllTables;
- (void) deleteWhoEntries;
- (void) deletePeopleEntries;

@end
