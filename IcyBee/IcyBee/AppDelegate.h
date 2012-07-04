//
//  AppDelegate.h
//  IcyBee
//
//  Created by Michelle Six on 12/26/11.
//  Copyright (c) 2012 The Home for Obsolete Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
  NSManagedObjectModel *managedObjectModel;  
  NSManagedObjectContext *managedObjectContext;      
  NSPersistentStoreCoordinator *persistentStoreCoordinator; 
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext        *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel          *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator  *persistentStoreCoordinator;

- (void)setupDefaults;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
@end
