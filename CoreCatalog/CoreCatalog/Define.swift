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
public func ManagedObjectModel() -> NSManagedObjectModel {
    
    let managedObjectModel = NSManagedObjectModel(contentsOfURL: NSBundle(identifier: BundleIdentifier)!.URLForResource("Model", withExtension: "momd")!)!
    
    return managedObjectModel
}

// MARK: - Constants

/// The bundle identifier of CoreCatalog.
public let BundleIdentifier = "com.colemancda.CoreCatalog"

public let CoreDataResourceIDAttributeName = "id"