//
//  AppDelegate.swift
//  GriitChat
//
//  Created by leo on 03/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate  {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        /*
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if granted {
                // Access granted
                //0
                self.scheduleNotification();
            } else {
                // Access denied
            }
        }
        
        self.registerNotificationAction()*/
        
        return true
    }
    /*
    func registerNotificationAction() {
        
        let first = UNNotificationAction.init(identifier: "first", title: "Action", options: [])
        let category = UNNotificationCategory.init(identifier: "categoryIdentifier", actions: [first], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    //1
    func scheduleNotification() {
        
        // Create a content
        let content = UNMutableNotificationContent.init()
        content.title = NSString.localizedUserNotificationString(forKey: "Some title", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "Body of notification", arguments: nil)
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "categoryIdentifier"
        
        // Create a unique identifier for each notification
        let identifier = UUID.init().uuidString
        
        // Notification trigger
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 5, repeats: false)
        
        // Notification request
        let request = UNNotificationRequest.init(identifier: identifier, content: content, trigger: trigger)
        
        // Add request
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }*/
    
    
    
    func video(videoPath: String, error: Error, contextInfo: Any) {
        if (error != nil) {
//            debugPrint(String.init("Error: %@", error));
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        debugPrint("applicationWillResignActive");
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        debugPrint("applicationDidEnterBackground");
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Extern.isPaused = true;
        
        if (Extern._transMng != nil) {
            Extern.transMng.resetState();
            Extern.mainVC?.onPause();
        	Extern.transMng.onPause();
        }
    }

    var bgTask : UIBackgroundTaskIdentifier!
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        debugPrint("applicationWillEnterForeground");
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        bgTask = application.beginBackgroundTask(expirationHandler: { () -> Void in
            application.endBackgroundTask(self.bgTask)
            self.bgTask = UIBackgroundTaskInvalid
        })
        
        DispatchQueue.global(qos : .background).async() { () -> Void in
            self.bgTask = UIBackgroundTaskInvalid
            application.endBackgroundTask(self.bgTask)
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        debugPrint("1. applicationDidBecomeActive");
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        Extern.isPaused = false;
        if (Extern._transMng != nil) {
            Extern.transMng.onResume();
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        debugPrint("applicationWillTerminate");
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        if (Extern._transMng != nil) {
            Extern.transMng.logout();
            Extern.transMng.onTerminate();
            Extern.transMng.transCenter.close();
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        application.registerForRemoteNotifications();
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pushNotification"), object: self)
        
//        Extern.notificationDelegate.didRegister();
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("i am not available in simulator \(error)")
    }
    
    //3
    /*func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.notification.request.content.categoryIdentifier == "categoryIdentifier" {
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                print(response.actionIdentifier)
                completionHandler()
            case "first":
                print(response.actionIdentifier)
                completionHandler()
            default:
                break;
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //2
        completionHandler([.alert, .sound])
    }*/
    
    
    
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Database")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    
    // MARK: - Core Data stack
    
    /*lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "uk.co.plymouthsoftware.core_data" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask);
        return urls[urls.count-1] as URL
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Database", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("GriitChat.sqlite")
        var failureReason: String = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
*/
}

