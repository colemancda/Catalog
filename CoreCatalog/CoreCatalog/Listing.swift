//
//  Listing.swift
//  CoreCatalog
//
//  Created by Alsey Coleman Miller on 11/3/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import CoreLocation
import CloudKit
import CoreData
import CoreDataStruct
import CloudKitStruct
import CloudKitStore

public struct Listing: CloudKitEncodable, CloudKitDecodable, CoreDataEncodable, CoreDataDecodable, CloudKitCacheable, Equatable {
        
    public let identifier: Identifier
    
    // MARK: - Attributes
    
    public var currency: Currency
    
    public var price: Double
    
    public var product: Identifier
    
    public var store: Identifier
}

// MARK: - Equatable

public func == (lhs: Listing, rhs: Listing) -> Bool {
    
    return (lhs.identifier == rhs.identifier &&
        lhs.currency == rhs.currency &&
        lhs.price == rhs.price &&
        lhs.product == rhs.product &&
        lhs.store == rhs.store)
}

// MARK: - CloudKit

public extension Listing {
    
    static var recordType: String { return "Store" }
    
    var recordName: String { return identifier }
    
    enum CloudKitField: String {
        
        case currency, price, product, store
    }
    
    init?(record: CKRecord) {
        
        guard record.recordType == Listing.recordType,
            let currencyString = record[CloudKitField.currency.rawValue] as? String,
            let currency = Currency(rawValue: currencyString),
            let price = record[CloudKitField.price.rawValue] as? Double,
            let product = record[CloudKitField.product.rawValue] as? CKReference,
            let store = record[CloudKitField.store.rawValue] as? CKReference
            else { return nil }
        
        self.identifier = record.recordID.recordName
        
        self.currency = currency
        self.price = price
        self.product = product.recordID.recordName
        self.store = store.recordID.recordName
    }
    
    func toCloudKit() -> CKRecord {
        
        let record = CKRecord(recordType: Listing.recordType, recordID: CKRecordID(recordName: recordName))
        
        record[CloudKitField.currency.rawValue] = currency.rawValue
        record[CloudKitField.price.rawValue] = price
        record[CloudKitField.product.rawValue] = CKReference(recordID: CKRecordID(recordName: product), action: .DeleteSelf)
        record[CloudKitField.store.rawValue] = CKReference(recordID: CKRecordID(recordName: store), action: .DeleteSelf)
        
        return record
    }
}

// MARK: - CoreData

public extension Listing {
    
    static var entityName: String { return "Store" }
    
    enum CoreDataProperty: String {
        
        case currency, price, product, store
    }
    
    func save(context: NSManagedObjectContext) throws -> NSManagedObject {
        
        // find or create from cache
        let managedObject = try context.findOrCreateEntity(Listing.entityName, withResourceID: identifier)
        
        // set cached
        managedObject.willCache()
        
        // set attributes
        managedObject.set(currency.rawValue, CoreDataProperty.currency)
        managedObject.set(price, CoreDataProperty.price)
        
        // set relationships
        try managedObject.setManagedObject(Product.entityName, product, CoreDataProperty.product, context)
        try managedObject.setManagedObject(Store.entityName, store, CoreDataProperty.store, context)
        
        // save
        try context.save()
        
        return managedObject
    }
    
    init(managedObject: NSManagedObject) {
        
        guard managedObject.entity.name == Store.entityName else { fatalError("Invalid Entity") }
        
        self.identifier = managedObject.valueForKey(CoreDataResourceIDAttributeName) as! String
        
        // attributes
        self.currency = Currency(rawValue: managedObject[CoreDataProperty.currency.rawValue] as! String)!
        self.price = managedObject[CoreDataProperty.price.rawValue] as! Double
        
        // relationship
        self.product = managedObject.getIdentifier(CoreDataProperty.product.rawValue)!
        self.store = managedObject.getIdentifier(CoreDataProperty.store.rawValue)!
    }
}

// MARK: - CloudKitCacheable

public extension Listing {
    
    static func fetchFromCache(recordID: RecordID, context: NSManagedObjectContext) throws -> NSManagedObject? {
        
        return try context.findEntity(Listing.entityName, withResourceID: recordID.recordName)
    }
}

// MARK: - Convenience Extensions

public extension Listing {
    
    public var currencyLocale: NSLocale {
        
        let components = [NSLocaleCurrencyCode: currency.rawValue]
        
        let localeRecordID = NSLocale.localeRecordIDFromComponents(components)
        
        let locale = NSLocale(localeRecordID: localeRecordID)
        
        return locale
    }
    
    public var priceString: String {
        
        NumberFormatter.locale = currencyLocale
        
        return NumberFormatter.stringFromNumber(price)!
    }
}

// MARK: - Private

private let NumberFormatter: NSNumberFormatter = {
    
    let formatter = NSNumberFormatter()
    
    formatter.numberStyle = .CurrencyStyle
    
    return formatter
}()



