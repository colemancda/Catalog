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
    
    init?(recordName: String, values: [String : CKRecordValue]) {
        
        guard let currencyString = values[CloudKitField.currency.rawValue] as? String,
            let currency = Currency(rawValue: currencyString),
            let price = values[CloudKitField.price.rawValue] as? Double,
            let product = values[CloudKitField.product.rawValue] as? CKReference,
            let store = values[CloudKitField.store.rawValue] as? CKReference
            else { return nil }
        
        self.identifier = recordName
        
        self.currency = currency
        self.price = price
        self.product = product.recordID.recordName
        self.store = store.recordID.recordName
    }
    
    func toCloudKit() -> (String, [String : CKRecordValue]) {
        
        var values = [String : CKRecordValue]()
        
        values[CloudKitField.currency.rawValue] = currency.rawValue
        values[CloudKitField.price.rawValue] = price
        values[CloudKitField.product.rawValue] = CKReference(recordID: CKRecordID(recordName: product), action: .DeleteSelf)
        values[CloudKitField.store.rawValue] = CKReference(recordID: CKRecordID(recordName: store), action: .DeleteSelf)
        
        return (recordName, values)
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
        let managedObject = try context.findOrCreateEntity(Listing.entityName, withResourceID: self.identifier)
        
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
        self.product = managedObject.getIdentifier(CoreDataProperty.image)
    }
}

// MARK: - CloudKitCacheable

public extension Listing {
    
    static func fetchFromCache(recordName: String, context: NSManagedObjectContext) throws -> NSManagedObject? {
        
        return try context.findEntity(Listing.entityName, withResourceID: recordName)
    }
}

// MARK: - Convenience Extensions

public extension Listing {
    
    public var currencyLocale: NSLocale {
        
        let components = [NSLocaleCurrencyCode: currency.rawValue]
        
        let localeIdentifier = NSLocale.localeIdentifierFromComponents(components)
        
        let locale = NSLocale(localeIdentifier: localeIdentifier)
        
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



