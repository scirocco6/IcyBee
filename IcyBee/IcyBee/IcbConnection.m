//
//  IcbConnection.m
//  tab_icb
//
//  Created by Michelle Six on 4/6/10.
//  Copyright (c) 2010 The Home for Obsolete Technology. All rights reserved.
//

#import "IcbConnection.h"

@implementation IcbConnection

+ (IcbConnection *)sharedInstance {
	static IcbConnection *sharedInstance;

	if (!sharedInstance)
		sharedInstance = [[IcbConnection alloc] init];

	return sharedInstance;
}

- (id) init {
    loggedIn = NO;
    snarfing = NO;
    
    return self;
}

- (void) connect {
  loggedIn = NO;
  snarfing = NO;
  
  NSLog(@"server setting is %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"server_preference"]);
  NSLog(@"port   setting is %i", [[[NSUserDefaults standardUserDefaults] stringForKey:@"port_preference"] intValue]);
  NSLog(@"Nickname is %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"nick_preference"]);
  
  CFHostRef host = CFHostCreateWithName(kCFAllocatorDefault, (__bridge_retained CFStringRef) [[NSUserDefaults standardUserDefaults] stringForKey:@"server_preference"]);
	CFStreamCreatePairWithSocketToCFHost(kCFAllocatorDefault, host, [[[NSUserDefaults standardUserDefaults] stringForKey:@"port_preference"] intValue], &myReadStream, &myWriteStream);
	
  inputStream     = (__bridge NSInputStream *)    myReadStream;
  outputStream    = (__bridge NSOutputStream *)   myWriteStream;
    
  [inputStream  setDelegate:self];
  [outputStream setDelegate:self];
    
  [inputStream  scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
  [inputStream  open];
  [outputStream open];
    
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {    
    switch(eventCode) {
        case NSStreamEventHasSpaceAvailable: {
            // we only want to be in the run loop when we are interested in sending
            [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
             
            switch (loggedIn) {
                case NO: {
                    NSLog(@"sending login...");
                    [self assemblePacketOfType:'a', 
                     [[NSUserDefaults standardUserDefaults] stringForKey:@"nick_preference"],
                     [[NSUserDefaults standardUserDefaults] stringForKey:@"nick_preference"],
                     [[NSUserDefaults standardUserDefaults] stringForKey:@"channel_preference"],
                     @"login", 
                     nil];
                    [self sendPacket];

                    break;
                }
                case YES: 
                    break;
            }
            break;
        } // case
            
        case NSStreamEventHasBytesAvailable: {
            switch (snarfing) {
                case NO: {
                    if ([(NSInputStream *)stream read:readBuffer maxLength:1]) {
                        snarfing = YES; // set snarfing to YES until we have received all of the packet
                        length = *readBuffer; // the first character of a packet is always the length
                        count = 0;
                    }
                }
                case YES:{
                    // ask for length packets minus those we already have
                    // read this into the readBuffer offset by how many bytes we have already read
                    int len = [(NSInputStream *)stream read:readBuffer + count maxLength:length - count]; 
                    if (len) {
                        count += len;
                        if(count == length) {
                            snarfing = NO; // now that we have the entire packet we can process it
                            [self handlePacket];
                        }
                    }
                    break;
                }
            }
        }
    } // switch
}

- (void) assemblePacketOfType:(char) packetType, ... {
    va_list args;
    id  object;
    
    writeBuffer[0] = packetType;
    writeBuffer[1] = 0;
    
    va_start(args, packetType);
    
    while((object = va_arg(args, id))) {
        strcat((char *) writeBuffer, [object cStringUsingEncoding:NSASCIIStringEncoding]);
        strcat((char *) writeBuffer, "\001");
    }
    
    va_end(args);
    writeBuffer[strlen((char *) writeBuffer)+1] = 0;
}

-(void) sendPacket {
    char icbLength = strlen((char *) writeBuffer) + 1;
    
    [outputStream write:(const uint8_t *) &icbLength maxLength:(unsigned int) 1];
    [outputStream write:writeBuffer maxLength:strlen((char *) writeBuffer) + 1];
}

-(void) handlePacket {
    switch (loggedIn) {
        case NO: {
            if (*readBuffer == 'a') {
                loggedIn = YES;
            }
            else if (*readBuffer == 'e') {
                //
                // TODO: code to display login failure goes here
                //
            }
            break;
        }
        
        case YES: {
            NSString *packet = [[NSString alloc] initWithBytes:(char *) (readBuffer + 1) length:length encoding:NSASCIIStringEncoding];
            
            parameters = [packet componentsSeparatedByString:@"\001"];

            switch (*readBuffer) {                    
                case 'b': { // an open message to the channel I am in
                    NSLog(@"<%@> %@", [parameters objectAtIndex:0], [parameters objectAtIndex:1]);
                    break;
                }
                    
                case 'c': { // a personal message from another user to me
                    break;
                }
                    
                case 'd': { // a status message
                    break;
                }
                    
                case 'e': { // an error message
                    break;
                }
                    
                case 'f': { // an important message
                    break;
                }
                    
                case 'g': { // exit
                    break;
                }
                    
                case 'i': { // command output
                    //ico
                    //iec
                    //iwl item in a who listing
                    break;
                }
                    
                case 'k': { //beep
                    break;
                }
                
                case 'n': // a nop packet
                    break;

                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

@end
