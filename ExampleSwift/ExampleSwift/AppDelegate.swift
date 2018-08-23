//
//  AppDelegate.swift
//  JSONObjectMapper_Example
//
//  Created by Sergey on 21/08/2018.
//

import CoreData
import UIKit

@UIApplicationMain
class AppDelegate: NSObject, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions options: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        guard let modelUrl = Bundle.main .url(forResource: "Example", withExtension: "momd"),
              let managedObjectModel = NSManagedObjectModel(contentsOf: modelUrl) else {
            return false
        }
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        let viewController = ViewController()
        viewController.managedObjectContext = managedObjectContext
        
        window = UIWindow()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        return true
    }
}
