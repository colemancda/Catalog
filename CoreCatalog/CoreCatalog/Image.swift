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
    
    public var reference: (Identifier, ReferenceType)
}

public extension Image {
    
    public enum ReferenceType: String {
        
        case Store
        
        case Product
    }
}

// MARK: - CloudKit

public extension Image {
    
    static var recordType: String { return "Image" }
    
    var recordName: String { return identifier }
    
    public enum CloudKitField: String {
        
        case data, reference, referenceType
    }
    
    init?(record: CKRecord) {
        
        guard record.recordType == Image.recordType,
            let dataAsset = record[CloudKitField.data.rawValue] as? CKAsset,
            let data = NSData(contentsOfURL: dataAsset.fileURL),
            let reference = record[CloudKitField.reference.rawValue] as? CKReference,
            let referenceTypeString = record[CloudKitField.referenceType.rawValue] as? String,
            let referenceType = ReferenceType(rawValue: referenceTypeString)
            else { return nil }
        
        self.identifier = record.recordID.recordName
        
        self.data = data.arrayOfBytes()
        self.reference = (reference.recordID.recordName, referenceType)
    }
    
    func toCloudKit() -> CKRecord {
        
        let record = CKRecord(recordType: Image.recordType, recordID: CKRecordID(recordName: recordName))
        
        let (referenceIdentifier, referenceType) = reference
        
        record[CloudKitField.data.rawValue] = NSData(bytes: data)
        record[CloudKitField.reference.rawValue] = CKReference(recordID: CKRecordID(recordName: referenceIdentifier), action: .DeleteSelf)
        record[CloudKitField.referenceType.rawValue] = referenceType.rawValue
        
        return record
    }
}

// MARK: - CoreData

public extension Image {
    
    static var entityName: String { return "Image" }
    
    enum CoreDataProperty: String {
        
        case data, image, store, product
    }
    
    func save(context: NSManagedObjectContext) throws -> NSManagedObject {
        
        // find or create from cache
        let managedObject = try context.findOrCreateEntity(Listing.entityName, withResourceID: identifier)
        
        // set cached
        managedObject.willCache()
        
        // set attribute
        managedObject.set(NSData(bytes: data), CoreDataProperty.data)
        
        // set relationship
        let (referenceIdentifier, referenceType) = reference
        
        switch referenceType {
            
        case .Store:
            
            try managedObject.setManagedObject(Store.entityName, referenceIdentifier, CoreDataProperty.store, context)
            
        case .Product:
            
            try managedObject.setManagedObject(Product.entityName, referenceIdentifier, CoreDataProperty.product, context)
        }
        
        // save
        try context.save()
        
        return managedObject
    }
    
    init(managedObject: NSManagedObject) {
        
        guard managedObject.entity.name == Image.entityName else { fatalError("Invalid Entity") }
        
        self.identifier = managedObject.valueForKey(CoreDataResourceIDAttributeName) as! String
        
        // attributes
        self.data = (managedObject[CoreDataProperty.data.rawValue] as! NSData).arrayOfBytes()
        
        let referenceType: ReferenceType
        
        let referenceIdentifier: Identifier
        
        // relationship
        if let productIdentifier = managedObject.getIdentifier(CoreDataProperty.product.rawValue) {
            
            referenceType = .Product
            
            referenceIdentifier = productIdentifier
        }
        else if let storeIdentifier = managedObject.getIdentifier(CoreDataProperty.store.rawValue) {
            
            referenceType = .Store
            
            referenceIdentifier = storeIdentifier
        }
        else { fatalError("Image not attached to any other entity") }
        
        self.reference = (referenceIdentifier, referenceType)
    }
}

// MARK: - CloudKitCacheable

public extension Image {
    
    static func fetchFromCache(recordID: RecordID, context: NSManagedObjectContext) throws -> NSManagedObject? {
        
        return try context.findEntity(Image.entityName, withResourceID: recordID.recordName)
    }
}
