//
//  AppDelegate.m
//  JSONObjectMapperExample
//
//  Created by Sergey on 20/05/2018.
//  Copyright © 2018 Sergey. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Example" withExtension:@"momd"];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator =
        [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
    
    ViewController *viewController = [[ViewController alloc] init];
    viewController.managedObjectContext = managedObjectContext;
    
    self.window = [[UIWindow alloc] init];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
