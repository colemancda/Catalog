//
//  Cache.swift
//  CatalogAdmin
//
//  Created by Alsey Coleman Miller on 11/21/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CloudKitStore
import CoreData

extension CloudKitStore {
    
    static var sharedStore: CloudKitStore { return SharedStore }
}

private var PersistentStore: NSPersistentStore?

/// Loads the persistent store.
func LoadPersistentStore() throws {
    
    let url = SQLiteStoreFileURL
    
    // load SQLite store
    
    PersistentStore = try CloudKitStore.sharedStore.managedObjectContext.persistentStoreCoordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
}

func RemovePersistentStore() throws {
    
    let url = SQLiteStoreFileURL
    
    if NSFileManager.defaultManager().fileExistsAtPath(url.path!) {
        
        // delete file
        
        try NSFileManager.defaultManager().removeItemAtURL(url)
    }
    
    if let store = PersistentStore {
        
        guard let psc = CloudKitStore.sharedStore.managedObjectContext.persistentStoreCoordinator
            else { fatalError() }
        
        try psc.removePersistentStore(store)
        
        PersistentStore = nil
    }
}

let SQLiteStoreFileURL: NSURL = {
    
    let cacheURL = try! NSFileManager.defaultManager().URLForDirectory(NSSearchPathDirectory.CachesDirectory,
        inDomain: NSSearchPathDomainMask.UserDomainMask,
        appropriateForURL: nil,
        create: false)
    
    let fileURL = cacheURL.URLByAppendingPathComponent("data.sqlite")
    
    return fileURL
}()

// MARK: - Private

private let SharedStore: CloudKitStore = {
    
    let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
   
    let store = CloudKitStore(context: context)
    
    return store
}()

