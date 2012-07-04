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

@interface IcbConnection : NSObject <NSStreamDelegate> {
	CFReadStreamRef         myReadStream;
	CFWriteStreamRef        myWriteStream;
  NSInputStream           *inputStream;
  NSOutputStream          *outputStream;
  NSManagedObjectContext  *managedObjectContext;
  Boolean                 loggedIn;
  Boolean                 snarfing;
  int                     length, count;
  uint8_t                 readBuffer[256];
  uint8_t                 writeBuffer[256];
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;  

+ (IcbConnection *)	sharedInstance;
- (void) connect;
- (void) handlePacket;
- (void) assemblePacketOfType:(char) packetType, ...;
- (void) sendPacket;
@end
