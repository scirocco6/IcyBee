//
//  AppDelegate.m
//  IcyBee
//
//  Created by Michelle Six on 12/26/11.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import "AppDelegate.h"
#import "IcbConnection.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions { // Override point for customization after application launch.
//  [application beginIgnoringInteractionEvents];
  [self setupDefaults];
  
  [[IcbConnection sharedInstance] setManagedObjectContext:self.managedObjectContext];
  [[IcbConnection sharedInstance] setApplication:application];
  return YES;
}

- (void)setupDefaults {
  
  //get the plist location from the settings bundle
  NSString *settingsPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Settings.bundle"];
  NSString *plistPath = [settingsPath stringByAppendingPathComponent:@"Root.plist"];
  
  //get the preference specifiers array which contains the settings
  NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
  NSArray *preferencesArray = [settingsDictionary objectForKey:@"PreferenceSpecifiers"];
  
  //use the shared defaults object
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  //for each preference item, set its default if there is no value set
  for(NSDictionary *item in preferencesArray) {
    
    //get the item key, if there is no key then we can skip it
    NSString *key = [item objectForKey:@"Key"];
    if (key) {
      
      //check to see if the value and default value are set
      //if a default value exists and the value is not set, use the default
      id value = [defaults objectForKey:key];
      id defaultValue = [item objectForKey:@"DefaultValue"];
      if(defaultValue && !value) {
        [defaults setObject:defaultValue forKey:key];
      }
    }
  }
  
  //write the changes to disk
  [defaults synchronize];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application { // This is where you can do your X Minutes, if >= 10Minutes is okay.
  BOOL backgroundAccepted = [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{ [self backgroundHandler]; }];
  if (backgroundAccepted) {
    NSLog(@"VOIP backgrounding accepted");
  }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)saveContext {
  NSError *error = nil;
  NSManagedObjectContext *myManagedObjectContext = self.managedObjectContext;
  if (myManagedObjectContext != nil) {
    if ([myManagedObjectContext hasChanges] && ![myManagedObjectContext save:&error]) {
      /*
       Replace this implementation with code to handle the error appropriately.
       
       abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
       */
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
    } 
  }
}

// if the iOS device allows background execution,
// this Handler will be called
- (void)backgroundHandler {
  
//  NSLog(@"### -->VOIP backgrounding callback");
  
//  [[IcbConnection sharedInstance] sendNop];
  
  
  /*
  // try to do sth. According to Apple we have ONLY 30 seconds to perform this Task!
  // Else the Application will be terminated!
  UIApplication* app = [UIApplication sharedApplication];
  NSArray*    oldNotifications = [app scheduledLocalNotifications];
  
  // Clear out the old notification before scheduling a new one.
  if ([oldNotifications count] > 0) [app cancelAllLocalNotifications];
  
  // Create a new notification
  UILocalNotification* alarm = [[UILocalNotification alloc] init];
  if (alarm) {
    alarm.fireDate = [NSDate date];
    alarm.timeZone = [NSTimeZone defaultTimeZone];
    alarm.repeatInterval = 0;
    alarm.soundName = @"alarmsound.caf";
    alarm.alertBody = @"Don't Panic! This is just a Push-Notification Test.";
    
    [app scheduleLocalNotification:alarm];
  }
   */
}


#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
  if (__managedObjectContext != nil) {
    return __managedObjectContext;
  }
  
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (coordinator != nil) {
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];
  }
  return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
  if (__managedObjectModel != nil) {
    return __managedObjectModel;
  }
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ChatModel" withExtension:@"momd"];
  __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
  if (__persistentStoreCoordinator != nil) {
    return __persistentStoreCoordinator;
  }
  
  NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ChatModel.sqlite"];
  
  NSError *error = nil;
  __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
  if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
     //Most likely an upgrade incompatible with the data store.  Delete it and try again
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
    
     //Performing automatic lightweight migration by passing the following dictionary as the options parameter:
     //[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
     //Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
      // This should never ever happen
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
    }
  }
  
  return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
