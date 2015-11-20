//
//  Image.swift
//  CoreCatalog
//
//  Created by Alsey Coleman Miller on 11/12/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import SwiftFoundation
import CloudKit
import CloudKitStruct
import CloudKitStore
import CoreData
import CoreDataStruct

public struct Image: CloudKitEncodable, CloudKitDecodable, CoreDataEncodable, CoreDataDecodable, CloudKitCacheable {
    
    public let identifier: Identifier
    
    // MARK: - Attributes
    
    public var data: Data
    
    public var reference: Identifier
}

// MARK: - CloudKit

public extension Image {
    
    static var recordType: String { return "Image" }
    
    var recordName: String { return identifier }
    
    public enum CloudKitField: String {
        
        case data, reference
    }
    
    init?(record: CKRecord) {
        
        guard record.recordType == Image.recordType,
            let dataAsset = record[CloudKitField.data.rawValue] as? CKAsset,
            let data = NSData(contentsOfURL: dataAsset.fileURL),
            let reference = record[CloudKitField.reference.rawValue] as? CKReference
            else { return nil }
        
        self.identifier = record.recordID.recordName
        
        self.data = data.arrayOfBytes()
        self.reference = reference.recordID.recordName
    }
    
    func toCloudKit() -> CKRecord {
        
        let record = CKRecord(recordType: Image.recordType, recordID: CKRecordID(recordName: recordName))
        
        record[CloudKitField.data.rawValue] = NSData(bytes: data)
        record[CloudKitField.reference.rawValue] = CKReference(recordID: CKRecordID(recordName: reference), action: .DeleteSelf)
        
        return record
    }
}

// MARK: - CoreData

public extension Image {
    
    static var entityName: String { return "Image" }
    
    enum CoreDataProperty: String {
        
        case data, image
    }
    
    func save(context: NSManagedObjectContext) throws -> NSManagedObject {
        
        // find or create from cache
        let managedObject = try context.findOrCreateEntity(Listing.entityName, withResourceID: identifier)
        
        // set cached
        managedObject.willCache()
        
        // set attributes
        managedObject.set(NSData(bytes: data), CoreDataProperty.data)
        managedObject.set(reference, CoreDataProperty.fere)
        
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
