//
//  IcbConnection.m
//  tab_icb
//
//  Created by Michelle Six on 4/6/10.
//  Copyright (c) 2010 The Home for Obsolete Technology. All rights reserved.
//

#import "AppDelegate.h"
#import "IcbConnection.h"

NSString const * htmlBegin = @""
"<html>"
"<head>"
"<style type=\"text/css\">"
"body {margin: 0; padding: 0; font-family: \"helvetica\"; font-size: 15;}"
"span {color:white}"
"A:link {text-decoration: underline; color: yellow}"
"A:visited {text-decoration: underline; color: blue;}"
"A:active {text-decoration: underline; color: red;}"
"</style>"
"</head>"
"<body>";

NSString const * htmlEnd = @"</body></html>";

@implementation IcbConnection
@synthesize application, front, managedObjectContext, currentChannel, currentNickname, lastGroupMessage, lastPrivateMessage, lastUrlMessage;

+ (IcbConnection *)sharedInstance {
	static IcbConnection *sharedInstance;

	if (!sharedInstance)
		sharedInstance = [[IcbConnection alloc] init];

	return sharedInstance;
}

/*
 Connectivity testing code pulled from Apple's Reachability Example: http://developer.apple.com/library/ios/#samplecode/Reachability
 */

+(BOOL)hasConnectivity {
  struct sockaddr_in zeroAddress;
  bzero(&zeroAddress, sizeof(zeroAddress));
  zeroAddress.sin_len = sizeof(zeroAddress);
  zeroAddress.sin_family = AF_INET;
  
  SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);

  if(reachability == NULL)
    return NO;

  //NetworkStatus retVal = NotReachable;
  SCNetworkReachabilityFlags flags;
  if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) { // if target host is not reachable
      return NO;
    }
      
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) { // if target host is reachable and no connection is required then we'll assume (for now) that your on Wi-Fi
      return YES;
    }
      
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
      // ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs
      if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) { // ... and no [user] intervention is needed
        return YES;
      }
    }
      
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
      // ... but WWAN connections are OK if the calling application is using the CFNetwork (CFSocketStream?) APIs.
      return YES;
    }
  }
  return NO;
}

- (id) init {
  lastGroupMessage = 0;
  lastPrivateMessage = 0;
  lastUrlMessage = 0;
  firstTime = YES;
  dropping = NO;
  
  return self;
}

- (void) setDisconected {
  [inputStream close];
  [outputStream close];
  
  loggedIn      = NO;
  authenticated = NO;
  snarfing      = NO;
  whoing        = NO;
  
}

- (void) deleteChatEntries { // delete all entries in the ChatMessage table
  lastGroupMessage    = 0;
  lastPrivateMessage  = 0;
  lastUrlMessage      = 0;

  NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
  
  [fetch setEntity:[NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext]];
  NSArray * result = [managedObjectContext executeFetchRequest:fetch error:nil];
  for (id basket in result)
    [managedObjectContext deleteObject:basket];
}

- (void) deleteWhoEntries { // delete all entries in the group table
  NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
  
  [fetch setEntity:[NSEntityDescription entityForName:@"Group" inManagedObjectContext:managedObjectContext]];
  NSArray * result = [managedObjectContext executeFetchRequest:fetch error:nil];
  for (id basket in result)
    [managedObjectContext deleteObject:basket];
}

- (void) deletePeopleEntries { // delete all entries in the people table
  NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
  
  [fetch setEntity:[NSEntityDescription entityForName:@"People" inManagedObjectContext:managedObjectContext]];
  NSArray *result = [managedObjectContext executeFetchRequest:fetch error:nil];
  for (id basket in result)
    [managedObjectContext deleteObject:basket];
}

- (void) deleteAllTables {
  [self deleteChatEntries];
  [self deleteWhoEntries];
  [self deletePeopleEntries];
}

- (void) connect {
  [self setDisconected];
  
  currentChannel  = [[NSUserDefaults standardUserDefaults] stringForKey:@"channel_preference"];
  currentNickname = [[NSUserDefaults standardUserDefaults] stringForKey:@"nick_preference"];
  currentPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"pass_preference"];
  
  CFHostRef host = CFHostCreateWithName(kCFAllocatorDefault, (__bridge_retained CFStringRef) [[NSUserDefaults standardUserDefaults] stringForKey:@"server_preference"]);
	CFStreamCreatePairWithSocketToCFHost(kCFAllocatorDefault, host, [[[NSUserDefaults standardUserDefaults] stringForKey:@"port_preference"] intValue], &myReadStream, &myWriteStream);
  
  if (!CFReadStreamSetProperty(myReadStream, kCFStreamNetworkServiceType, kCFStreamNetworkServiceTypeVoIP))
    NSLog(@"Could not set VoIP mode to read stream");
  
  if (!CFWriteStreamSetProperty(myWriteStream, kCFStreamNetworkServiceType, kCFStreamNetworkServiceTypeVoIP))
    NSLog(@"Could not set VoIP mode to write stream");
	
  inputStream     = (__bridge NSInputStream *)    myReadStream;
  outputStream    = (__bridge NSOutputStream *)   myWriteStream;

  [inputStream  setDelegate:self];
  [outputStream setDelegate:self];
  
//  [inputStream  setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType] ;
//  [outputStream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType] ;
    
  [inputStream  scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  
  [inputStream  open];
  [outputStream open];
  
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {    
  switch(eventCode) {
    case NSStreamEventErrorOccurred: {
      [self setDisconected];
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Networking Error"
                                                      message:@"Unable to connect to server.  Tap to try again"
                                                     delegate:self
                                            cancelButtonTitle:@"retry"
                                            otherButtonTitles:nil];
      [alert show];  
    }

    case NSStreamEventHasSpaceAvailable: { // we only want to be in the run loop when we are interested in sending
      [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
             
      switch (loggedIn) {
        case NO: {
          if(dropping) {
            int rnum = arc4random() % 9999999;
            [self assemblePacketOfType:'a', [NSString stringWithFormat:@"icy%d", rnum], [NSString stringWithFormat:@"icy%d", rnum], @"__hiddenIcyDrop", @"login", nil];
          }
          else
            [self assemblePacketOfType:'a', currentNickname, currentNickname, currentChannel, @"login", currentPassword, nil];
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

- (void) processInput:(NSString *) line {
  if([line characterAtIndex:0] == '/') {
    switch ([line characterAtIndex:1]) {
      case 'm':
        [self sendPrivateMessage:[line substringFromIndex:3]];
        break;
        
      case 'b':
        [self sendBeep:[line substringFromIndex:6]];
        break;
        
      default:
        break;
    }
  }
  else {
    [self sendOpenMessage:line];
  }
  
  [self addToChatFromSender:currentNickname type:'b' text:line];
}

- (void) globalWhoList {
  [self deleteWhoEntries];
  [self deletePeopleEntries];

  whoing = YES;
  [self assemblePacketOfType:'h', @"w\001", nil]; // send the icb global who command
  [self sendPacket];
}

- (void) globalGroupList {
  [self deleteWhoEntries];
  
  whoing = YES;
  [self sendPrivateMessage:@"server w -g"]; // there is no protocol group list but there is a server command
}

- (void) joinGroup:(NSString *) group {
  [self assemblePacketOfType:'h', @"g", group, nil];
  [self sendPacket];
}

- (void) sendNop {
  [self assemblePacketOfType:'n',nil];
  [self sendPacket];
}

- (void) joinGroupWithUser:(NSString *) user {
  [self assemblePacketOfType:'h', @"g", [NSString stringWithFormat:@"@%@", user], nil];
  [self sendPacket];
}

- (void) sendOpenMessage:(NSString *) message {
  [self assemblePacketOfType:'b', message, nil];
  [self sendPacket];
}

- (void) sendPrivateMessage:(NSString *) message {
  [self assemblePacketOfType:'h', @"m", message, nil];
  [self sendPacket];
}

- (void) sendBeep:(NSString *) user {
  [self assemblePacketOfType:'h', @"beep", user, nil];
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
  // create a temporary string, read the buffer into it, then parse it.  Parameters are seperated by \001
  NSArray  *parameters = [[[NSString alloc] initWithBytes:(char *) (readBuffer + 1) length:(length - 1) encoding:NSASCIIStringEncoding] componentsSeparatedByString:@"\001"];
  
  if (!loggedIn) {
    if (*readBuffer == 'a') {
      if (dropping) {
        [self sendPrivateMessage:[NSString stringWithFormat:@"server drop %@ %@", currentNickname, currentPassword]];
        sleep(6);
        [front performSelector:@selector(setStatus:) withObject:@"conecting"];
        dropping = NO;
        [self setDisconected];
        [self connect];
        
        return;
      }
      loggedIn = YES;
    }
    else if (*readBuffer == 'e') {
      if([[parameters objectAtIndex:0] hasPrefix:@"Nickname already in use"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nickname in use"
                                                        message:[NSString stringWithFormat:@"%@ is already logged in elsewhere.", currentNickname]
                                                       delegate:self
                                              cancelButtonTitle:@"Change User"
                                              otherButtonTitles:@"Drop Other", nil];
        [alert show];
        
        return;
      }
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Server Error"
                                                      message:[[NSString alloc] initWithBytes:(char *) (readBuffer + 1) length:(length - 1) encoding:NSASCIIStringEncoding] 
                                                     delegate:nil 
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
      [alert show];  
    }
    return;
  }
  
  switch (*readBuffer) {                    
    case 'b': // an open message to the channel I am in
    case 'c': // a personal message from another user to me
    case 'd': // a status message
    case 'f': { // an important message
      if (*readBuffer == 'd') {
        if ([[parameters objectAtIndex:0] isEqualToString:@"No-Pass"] && [[parameters objectAtIndex:1] hasPrefix:@"Your nickname does not have a password"]) {
          [front performSelector:@selector(setStatus:) withObject:@"creating account"];
          [self sendPrivateMessage:[NSString stringWithFormat:@"server p %@", currentPassword]];
        }
        else if ([[parameters objectAtIndex:0] isEqualToString:@"Register"]) {
          if([[parameters objectAtIndex:1] hasPrefix:@"Nick registered"]) {
            authenticated = YES;
            if(firstTime) {
              firstTime = NO;
              [front performSelector:@selector(connected)];
              return;
            }
          }
        } // if
        else {          
          NSRange range = [[parameters objectAtIndex:1] rangeOfString:@"You are now in group "];
          if (range.location != NSNotFound) {
            NSString *substring = [[parameters objectAtIndex:1] substringFromIndex:range.location+21];
            range = [substring rangeOfString:@" "];
            if (range.location == NSNotFound)
              currentChannel = substring;
            else
              currentChannel = [substring substringToIndex:range.location];
          } // if
        } // else
      } // if
      if(authenticated)
        [front performSelector:@selector(updateView)]; // notify the frontmost view to update itself

      [self addToChatFromSender:[parameters objectAtIndex:0] type:*readBuffer text:[parameters objectAtIndex:1]];

      break;
    } // case
    
    case 'k': { //beep the server sends an extra /0 on beeps.  remove it
      [self addToChatFromSender:[[parameters objectAtIndex:0] substringToIndex:[[parameters objectAtIndex:0] length] -  1] type:*readBuffer text:@"Beep!"];
      break;
    }
      
    case 'e': { // an error message
      if ([[parameters objectAtIndex:0] hasPrefix:@"Password Incorrect"] ||
          [[parameters objectAtIndex:0] hasPrefix:@"Authorization failure"] ||
          [[parameters objectAtIndex:0] hasPrefix:@"Authentication failure"]) {
        dropping = NO;
        [self setDisconected];
        [front performSelector:@selector(setStatus:) withObject:@"connection failed"];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed"
                                                        message:[NSString stringWithFormat:@"Please enter the password for user %@", currentNickname]
                                                       delegate:self
                                              cancelButtonTitle:@"Change User"
                                              otherButtonTitles:@"Login", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alert show];
        
        
        break;
      }
      
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
                  ! ([reply isEqual: @"-----------------------------------------------------------------------------"])) {
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
                } //else if
              } // if
              else if(!whoing) {
                [self addToChatFromSender:@"server" type:'o' text:[parameters objectAtIndex:1]];
              }
              break;
            } // case
              
            default: {
              [self addToChatFromSender:@"Server" type:*readBuffer text:[parameters objectAtIndex:0]];
              break;
            }
          } // switch
          break;
        } // case 'c'
      
        case 'w': {
          switch (*(readBuffer + 2)) {
            case 'l': { // technically we should check to see if we are whoing however 'l' can never appear except when we are whoing so the check is redundant
              NSString *accountString = [[NSString alloc] initWithFormat:@"%@@%@", [parameters objectAtIndex:6], [parameters objectAtIndex:7]];
              [self addPerson:[parameters objectAtIndex:2]
                        group:(NSString *) whoChannel
                         idle:[[NSNumber alloc] initWithInt: [[parameters objectAtIndex:3] intValue]]
                       signon:[[NSNumber alloc] initWithInt: [[parameters objectAtIndex:5] intValue]]
                      account:accountString];
            }
          }
        } // case 'w'

        default:
          break;
      } // switch
      break;
    } // case 'i'
                    
    case 'n': // a nop packet
      break;

    default:
      break;
  }
}

- (BOOL) hasUrl:(NSString *) message {
  NSError *error = NULL;

  //
  // the general concensus is that having to cast this to NSTextCheckingTypes is a bug
  // and it may eventually get fixed.  trying pulling the cast at a later date and see if the
  //warning is still there.
  //
  NSDataDetector *thisDetector = [NSDataDetector dataDetectorWithTypes:(NSTextCheckingTypes) NSTextCheckingTypeLink error:&error];
  return [thisDetector
          numberOfMatchesInString:message
                          options:0
                            range:NSMakeRange(0, [message length])] > 0 ? YES : NO;
}

- (void) addToChatFromSender:(NSString *) sender type:(char) type text:(NSString *) text {
  ChatMessage *event = (ChatMessage *)[NSEntityDescription insertNewObjectForEntityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
  [event setTimeStamp: [NSDate date]];
  [event setType: [[NSString alloc] initWithBytes:&type length:1 encoding:NSASCIIStringEncoding]];
  [event setSender:sender];   
  [event setHeight:21.0f];
  [event setNeedsSize:YES];
  [event setGroupIndex:lastGroupMessage++];
  
  switch (type) {
    case 'c': // private message
    case 'k': // beep message
      [event setPrivateIndex:lastPrivateMessage++];
      
      [event setText: [NSString stringWithFormat:@"%@"
                       "<span style='color:#00FF00; margin-right:5px;'>&lt&#42;%@&#42;&gt</span>"
                       "<span><i style='color: #00FF00'>%@</i></span>"
                       "%@",
                       htmlBegin, sender, text, htmlEnd]];
      break;
      
    case 'o': // server response from a command
      [event setText: [NSString stringWithFormat:@"%@"
                       "<span><i style='color: #FFF0F0'>%@</i></span>"
                       "%@",
                       htmlBegin, text, htmlEnd]];
      break;
      
    case 'd':
      [event setText: [NSString stringWithFormat:@"%@"
                       "<span style='color:#FFAAAA; margin-right:5px;'>[=%@=]</span>"
                       "<span>%@</span>"
                       "%@",
                       htmlBegin, sender, text, htmlEnd]];
      break;
      
    default:
      [event setText: [NSString stringWithFormat:@"%@"
                       "<span style='color:#FF00FF; margin-right:5px;'>&lt%@&gt</span>"
                       "<span>%@</span>"
                       "%@",
                       htmlBegin, sender, text, htmlEnd]];
      break;
  }

  
  if ((type == 'b' || type == 'c') && [self hasUrl: text]) {
    [event setUrl:YES];
    [event setUrlIndex:lastUrlMessage++];
  }
  else
    [event setUrl:NO];
  
  [self saveManagedObjectContext];

  if (![self inBackground])
    return;
  
  UILocalNotification* alarm = [[UILocalNotification alloc] init];
  if (!alarm)
    return;
    
  if (type == 'c')
    alarm.alertBody = [NSString stringWithFormat:@"<%@> %@", sender, text];
  else if (type == 'k')
    alarm.alertBody = [NSString stringWithFormat:@"%@ has sent you a beep", sender];
  else
    return;
    
  alarm.fireDate = [NSDate date];
  alarm.timeZone = [NSTimeZone defaultTimeZone];
  alarm.repeatInterval = 0;
  alarm.soundName = @"alarmsound.caf";
  [[UIApplication sharedApplication] scheduleLocalNotification:alarm];
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
  [event setGroup:    whoChannel];
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
  if(authenticated)
    [front performSelector:@selector(updateView)]; // notify the frontmost view to update itself
}

#pragma mark - UIAlertViewDelegate

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
  if([alertView alertViewStyle] != UIAlertViewStylePlainTextInput)
    return YES;
  
  return [[[alertView textFieldAtIndex:0] text] length] == 0 ? NO : YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
  
  if([title isEqualToString:@"Change User"]) {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"nick_preference"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"pass_preference"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [front performSelector:@selector(preConnect)];
    return;
  }
  else if([title isEqualToString:@"Login"]) {
    currentPassword = [[alertView textFieldAtIndex:0] text];
    [[NSUserDefaults standardUserDefaults] setObject:currentPassword forKey:@"pass_preference"];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }
  else if([title isEqualToString:@"Drop Other"]) {
    [front performSelector:@selector(setStatus:) withObject:@"dropping other login"];
    dropping = YES;
  }
  
  [self connect];
}

@end
