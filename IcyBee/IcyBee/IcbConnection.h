//
//  IcbConnection.h
//  tab_icb
//
//  Created by Michelle Six on 4/6/10.
//  Copyright 2010 dotSix Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import <CFNetwork/CFHost.h>
#import <CFNetwork/CFSocketStream.h>

@interface IcbConnection : NSObject <NSStreamDelegate> {
	CFReadStreamRef     myReadStream;
	CFWriteStreamRef	myWriteStream;
    NSInputStream       *inputStream;
    NSOutputStream      *outputStream;
    Boolean             loggedIn;
    Boolean             snarfing;
    int                 length, count;
    uint8_t             readBuffer[256];
    uint8_t             writeBuffer[256];
    NSArray             *parameters;
}

+ (IcbConnection *)	sharedInstance;
- (void) connect;
- (void) handlePacket;
- (void) assemblePacketOfType:(char) packetType, ...;
- (void) sendPacket;
@end
