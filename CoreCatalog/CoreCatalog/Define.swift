//
//  Define.swift
//  CoreCatalog
//
//  Created by Alsey Coleman Miller on 11/11/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CoreData

/// The managed object model for the CoreCatalog framework.
public var ManagedObjectModel: NSManagedObjectModel {
    
    let managedObjectModel = NSManagedObjectModel(contentsOfURL: NSBundle(identifier: BundleIdentifier)!.URLForResource("Model", withExtension: "momd")!)!
    
    managedObjectModel.addResourceIDAttribute(CoreDataResourceIDAttributeName)
    
    managedObjectModel.addCachedAttribute(CoreDataCachedAttributeName)
    
    return managedObjectModel.copy() as! NSManagedObjectModel
}

// MARK: - Constants

/// The bundle identifier of CoreCatalog.
public let BundleIdentifier = "com.colemancda.CoreCatalog"

public let CoreDataResourceIDAttributeName = "id"

public let CoreDataCachedAttributeName = "cached"