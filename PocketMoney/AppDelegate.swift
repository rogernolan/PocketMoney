//
//  AppDelegate.swift
//  PocketMoney
//
//  Created by roger nolan on 10/04/2015.
//  Copyright (c) 2015 Babbage Consulting. All rights reserved.
//

import UIKit
// import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Parse.enableLocalDatastore()
        Parse.setApplicationId("SQT3AkCHEIOJAIFOTrBV01GeLURTKLDKR9HkyGDQ",
            clientKey: "YLVwRUtX1tyQiZVnxMAkCQ9WAZNLU8ucwOXWuwi7")
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block:nil);
        
        Account.registerSubclass()
        Transaction.registerSubclass()
        PMUser.registerSubclass()
        
        fetchModifications()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: Our init code
    func fetchModifications() -> Void{
        Account.fetchModifications().continueWithBlock { (task:BFTask!) -> AnyObject! in
            return Transaction.fetchModifications()
        }
        
//        Account.loadFrom(.server) { (accounts, error) -> Void in
//            PFObject.pinAllInBackground(accounts)
//            println("Have new data")
//        }
    }

}

