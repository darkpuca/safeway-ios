//
//  AppDelegate.h
//  safeway
//
//  Created by darkpuca on 2014. 3. 15..
//  Copyright (c) 2014년 Kim Dongkyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (readonly, nonatomic) BOOL pushAvailable;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)clearCoreData;

@end
