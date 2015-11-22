//
//  AppDelegate.swift
//  CatalogAdmin
//
//  Created by Alsey Coleman Miller on 11/7/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import UIKit
import CoreCatalog
import CloudKitStore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // print app info
        print("Launching CatalogAdmin v\(AppVersion) Build \(AppBuild)")
        
        // nuke cache if new version
        if let lastVersion = NSUserDefaults.standardUserDefaults().stringForKey(PreferenceKey.LastVersion.rawValue) where lastVersion != AppBuild  {
            
            try! RemovePersistentStore()
        }
        
        // set database
        CloudKitStore.sharedStore.cloudDatabase = CloudKitContainer.publicCloudDatabase
        
        // load cache
        do { try LoadPersistentStore() }
        catch {
            
            print("Could not load persistent store. \(error)")
            
            try! RemovePersistentStore()
            
            fatalError("Could not load persistent store.")
        }
        
        // save last version used
        NSUserDefaults.standardUserDefaults().setObject(AppBuild, forKey: PreferenceKey.LastVersion.rawValue)
        NSUserDefaults.standardUserDefaults().synchronize()
        
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


}

