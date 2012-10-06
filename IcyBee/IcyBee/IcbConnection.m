//
//  IcbConnection.m
//  tab_icb
//
//  Created by Michelle Six on 4/6/10.
//  Copyright (c) 2010 The Home for Obsolete Technology. All rights reserved.
//

#import "IcbConnection.h"

@implementation IcbConnection
@synthesize managedObjectContext, front, currentChannel;

+ (IcbConnection *)sharedInstance {
	static IcbConnection *sharedInstance;

	if (!sharedInstance)
		sharedInstance = [[IcbConnection alloc] init];

	return sharedInstance;
}

- (id) init {
  return self;
}

- (void) connect {
  loggedIn  = NO;
  snarfing  = NO;
  whoing    = NO;
  
  // delete all entries in the ChatMessage table
  NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
  [fetch setEntity:[NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext]];
  NSArray * result = [managedObjectContext executeFetchRequest:fetch error:nil];
  for (id basket in result)
    [managedObjectContext deleteObject:basket];
  
  #ifdef DEBUG
    NSLog(@"server setting is %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"server_preference"]);
    NSLog(@"port   setting is %i", [[[NSUserDefaults standardUserDefaults] stringForKey:@"port_preference"] intValue]);
    NSLog(@"Nickname is %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"nick_preference"]);
  #endif
  
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
    case NSStreamEventErrorOccurred: {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Networking Error"
                                                      message:@"Unable to connect to server.  Please try again later"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
      [alert show];  
    }
    case NSStreamEventHasSpaceAvailable: { // we only want to be in the run loop when we are interested in sending
      [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
             
      switch (loggedIn) {
        case NO: {
          #ifdef DEBUG
            NSLog(@"sending login...");
          #endif
          currentChannel = [[NSUserDefaults standardUserDefaults] stringForKey:@"channel_preference"];
          [self assemblePacketOfType:'a', 
           [[NSUserDefaults standardUserDefaults] stringForKey:@"nick_preference"],
           [[NSUserDefaults standardUserDefaults] stringForKey:@"nick_preference"],
           currentChannel,
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
      
    case NSStreamEventNone:
    case NSStreamEventOpenCompleted:
    case NSStreamEventEndEncountered:
    default:
      break;
  } // switch
}

- (void) globalWhoList {
  // delete all entries in the group table
  NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
  [fetch setEntity:[NSEntityDescription entityForName:@"Group" inManagedObjectContext:managedObjectContext]];
  NSArray * result = [managedObjectContext executeFetchRequest:fetch error:nil];
  for (id basket in result)
    [managedObjectContext deleteObject:basket];
  
  // delete all entries in the people table
  [fetch setEntity:[NSEntityDescription entityForName:@"People" inManagedObjectContext:managedObjectContext]];
  result = [managedObjectContext executeFetchRequest:fetch error:nil];
  for (id basket in result)
    [managedObjectContext deleteObject:basket];

  // send the icb global who command
  whoing = YES;
  [self assemblePacketOfType:'h', @"w\001", nil];
  [self sendPacket];
}

- (void) joinGroup:(NSString *) group {
  [self assemblePacketOfType:'h', @"g", group, nil];
  [self sendPacket];
}

- (void) joinGroupWithUser:(NSString *) user {
  [self assemblePacketOfType:'h', @"g", [NSString stringWithFormat:@"@%@", user], nil];
  [self sendPacket];
}

- (void) sendOpenMessage:(NSString *) message {
  NSLog(@"Sending open message %@", message);
  
  [self addToChatFromSender:[[NSUserDefaults standardUserDefaults] stringForKey:@"nick_preference"] type:'b' text:message];

  [self assemblePacketOfType:'b', message, nil];
  [self sendPacket];
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
    writeBuffer[strlen((char *) writeBuffer) - 1] = 0;
}

-(void) sendPacket {
  char icbLength = strlen((char *) writeBuffer) + 1;
    
  [outputStream write:(const uint8_t *) &icbLength maxLength:(unsigned int) 1];
  [outputStream write:writeBuffer maxLength:strlen((char *) writeBuffer) + 1];
}

-(void) handlePacket {
  if (!loggedIn) {
    if (*readBuffer == 'a') {
      loggedIn = YES;
      #ifdef DEBUG
        NSLog(@"Login successful");
      #endif
    }
    else if (*readBuffer == 'e') {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Server Error" 
                                                      message:[[NSString alloc] initWithBytes:(char *) (readBuffer + 1) length:(length - 1) encoding:NSASCIIStringEncoding] 
                                                     delegate:nil 
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
      [alert show];  
    }
    return;
  }
        
  // create a temporary string, read the buffer into it, then parse it.  Parameters are seperated by \0
  NSArray  *parameters = [[[NSString alloc] initWithBytes:(char *) (readBuffer + 1) length:(length - 1) encoding:NSASCIIStringEncoding] componentsSeparatedByString:@"\001"];
     
  switch (*readBuffer) {                    
    case 'b': // an open message to the channel I am in
    case 'c': // a personal message from another user to me
    case 'd': // a status message
    case 'f': { // an important message
      [self addToChatFromSender:[parameters objectAtIndex:0] type:*readBuffer text:[parameters objectAtIndex:1]];
      
      if (*readBuffer == 'd') {
        NSRange range = [[parameters objectAtIndex:1] rangeOfString:@"You are now in group "];
        if (range.location != NSNotFound) {
          NSString *substring = [[parameters objectAtIndex:1] substringFromIndex:range.location+21];
          range = [substring rangeOfString:@" "];
          if (range.location == NSNotFound) {
            currentChannel = substring;
          }
          else {
            currentChannel = [substring substringToIndex:range.location];
          }
        }
      }
      break;
    }
    
    case 'k': { //beep
      [self addToChatFromSender:[parameters objectAtIndex:0] type:*readBuffer text:@"Beep!"];
      break;
    }
      
    case 'e': { // an error message
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Server Error" 
                                                      message:[[NSString alloc] initWithBytes:(char *) (readBuffer + 1) length:(length - 1) encoding:NSASCIIStringEncoding] 
                                                     delegate:nil 
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
      [alert show];
      break;
    }
                    
    case 'g': { // exit
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Disconnected"
                                                      message:@"The server has disconnected"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
      [alert show];
      break;
    }
                    
    case 'i': { // command output
      switch (*(readBuffer + 1)) {
        case 'c': {
          switch (*(readBuffer + 2)) {
            case 'o': {
              // let's parse out the group responce.  icb is a messed up little protocol and it pre-formats for printing on a terminal group lines :(
              NSString *reply = [parameters objectAtIndex:1];
              if (whoing &&
                  ! ([reply length] == 1) &&
                  ! (reply == @"-----------------------------------------------------------------------------")) {
                if ([reply hasPrefix:@"Total:"])
                  whoing = NO;
                else if ([reply hasPrefix:@"Group:"]) {
                  NSString *name;
                  NSString *moderator;
                  NSString *topic;
                  
                  NSScanner *whoScanner = [NSScanner scannerWithString:reply];
                                      
                  [whoScanner scanUpToString:@"Group:"  intoString:nil];
                  [whoScanner scanUpToString:@" "       intoString:nil];
                  [whoScanner scanUpToString:@" "       intoString:&name];
                    
                  [whoScanner scanUpToString:@"Mod:"    intoString:nil];
                  [whoScanner scanUpToString:@" "       intoString:nil];
                  [whoScanner scanUpToString:@" "       intoString:&moderator];
                    
                  [whoScanner scanUpToString:@"Topic:"  intoString:nil];
                  [whoScanner scanUpToString:@" "       intoString:nil];                    
                  [whoScanner scanUpToString:@"\0"      intoString:&topic]; // scan till the end of the string since topics can have spaces in them
                    
                  whoChannel = name;
                  [self addGroup:name moderator:moderator topic:topic];                  
                }
              }
            }
              
            default: {
              [self addToChatFromSender:@"Server" type:*readBuffer text:[parameters objectAtIndex:0]];
              break;
            }
          }
        }
        
        case 'w': {
          switch (*(readBuffer + 2)) {
            case 'l': { // technically we should check to see if we are whoing however l can never appear except when we are whoing so the check is redundant
              NSString *accountString = [[NSString alloc] initWithFormat:@"%@@%@", [parameters objectAtIndex:6], [parameters objectAtIndex:7]];
              [self addPerson:[parameters objectAtIndex:2]
                        group:(NSString *) whoChannel
                         idle:[[NSNumber alloc] initWithInt: [[parameters objectAtIndex:3] intValue]]
                       signon:[[NSNumber alloc] initWithInt: [[parameters objectAtIndex:5] intValue]]
                      account:accountString];
            }
          }
        }
          
        default:
          break;
      }
      
      #ifdef DEBUG       
        NSLog(@"%@", [[NSString alloc] initWithBytes:(char *) readBuffer length:length encoding:NSASCIIStringEncoding]);
      #endif
      break;
    }
                    
    case 'n': // a nop packet
      break;

    default:
      break;
  }
}

- (BOOL) hasUrl:(NSString *) message {
  NSError *error = NULL;

  return [[NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error]
          numberOfMatchesInString:message
                          options:0
                            range:NSMakeRange(0, [message length])] > 0 ? YES : NO;
}

- (void) addToChatFromSender:(NSString *) sender type:(char) type text:(NSString *) text {
  ChatMessage *event = (ChatMessage *)[NSEntityDescription insertNewObjectForEntityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];  
  [event setTimeStamp: [NSDate date]];
  [event setType: [[NSString alloc] initWithBytes:&type length:1 encoding:NSASCIIStringEncoding]];
  [event setSender:sender];   
  [event setText:text];
  // only hunt for URLs in open and private messages
  [event setUrl: (type == 'b' || type == 'c') ? [self hasUrl: text] : NO];
  
  [self saveManagedObjectContext];
}

- (void) addGroup:(NSString *) name moderator:(NSString *) moderator topic:(NSString *) topic {
  Group *event = (Group *)[NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:managedObjectContext];  
  [event setName:       name];   
  [event setModerator:  moderator];   
  [event setTopic:      topic];   

  [self saveManagedObjectContext];
}

- (void) addPerson:(NSString *) nickname group:(NSString *) group idle:(NSNumber *) idle signon:(NSNumber *) signon account:(NSString *) account {
  People *event = (People *)[NSEntityDescription insertNewObjectForEntityForName:@"People" inManagedObjectContext:managedObjectContext];  
  [event setNickname: nickname];
  [event setGroup: whoChannel];
  [event setIdle:     idle];
  [event setSignon:   signon];
  [event setAccount:  account];
  
  [self saveManagedObjectContext];
}

- (void) saveManagedObjectContext {
  NSError *error;  
  
  if(![managedObjectContext save:&error]){  
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Process Message" 
                                                    message:@"Unable to process messages at this time.  Please re-start the app." 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];        
  }
  [front performSelector:@selector(updateView)]; // notify the frontmost view to update itself
}

@end
