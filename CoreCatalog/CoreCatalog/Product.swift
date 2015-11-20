//
//  Product.swift
//  CoreCatalog
//
//  Created by Alsey Coleman Miller on 11/3/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CloudKit
import CloudKitStore
import CloudKitStruct
import CoreData
import CoreDataStruct

public struct Product: CloudKitEncodable, CloudKitDecodable, CoreDataEncodable, CoreDataDecodable, CloudKitCacheable {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var image: Identifier?
}

// MARK: - CloudKit

public extension Product {
    
    static var recordType: String { return "Product" }
    
    var recordName: String { return identifier }
    
    enum CloudKitField: String {
        
        case name, image
    }
    
    init?(record: CKRecord) {
        
        guard record.recordType == Product.recordType,
            let name = record[CloudKitField.name.rawValue] as? String
        else { return nil }
        
        self.identifier = record.recordID.recordName
        
        self.name = name
        
        if let imageReference = record[CloudKitField.image.rawValue] as? CKReference {
            
            self.image = imageReference.recordID.recordName
        }
    }
    
    func toCloudKit() -> CKRecord {
        
        let record = CKRecord(recordType: Product.recordType, recordID: CKRecordID(recordName: recordName))
        
        record[CloudKitField.name.rawValue] = name
        
        if let image = self.image {
            
            record[CloudKitField.image.rawValue] = CKReference(recordID: CKRecordID(recordName: image), action: .None)
        }
        
        return record
    }
}

// MARK: - CoreData

public extension Product {
    
    static var entityName: String { return "Product" }
    
    enum CoreDataProperty: String {
        
        case name, image
    }

    func save(context: NSManagedObjectContext) throws -> NSManagedObject {
        
        // find or create from cache
        let managedObject = try context.findOrCreateEntity(Listing.entityName, withResourceID: identifier)
        
        // set cached
        managedObject.willCache()
        
        // set attributes
        managedObject.set(name, CoreDataProperty.name)
        
        // set relationships
        try managedObject.setManagedObject(Image.entityName, image, CoreDataProperty.image, context)
        
        // save
        try context.save()
        
        return managedObject
    }
    
    init(managedObject: NSManagedObject) {
        
        guard managedObject.entity.name == Product.entityName else { fatalError("Invalid Entity") }
        
        self.identifier = managedObject.valueForKey(CoreDataResourceIDAttributeName) as! String
        
        // attributes
        self.name = managedObject[CoreDataProperty.name.rawValue] as! String
        
        // relationship
        self.image = managedObject.getIdentifier(CoreDataProperty.image.rawValue)!
    }
}

// MARK: - CloudKitCacheable

public extension Product {
    
    static func fetchFromCache(recordID: RecordID, context: NSManagedObjectContext) throws -> NSManagedObject? {
        
        return try context.findEntity(Product.entityName, withResourceID: recordID.recordName)
    }
}

