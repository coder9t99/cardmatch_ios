//
//  AppDelegate.h
//  Card Match
//
//  Created by Quentin Lin on 5/05/2016.
//  Copyright © 2016 coder9t99. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "HighScoreSynchroniser.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (readonly, strong) HighScoreSynchroniser *synchroniser;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

