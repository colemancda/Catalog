//
//  Listing.swift
//  CoreCatalog
//
//  Created by Alsey Coleman Miller on 11/3/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CloudKit

public struct Listing {
    
    public static let recordType = "Listing"
    
    public let identifier: Identifier
    
    // MARK: - Attributes
    
    public var currency: String
    
    public var price: Double
    
    public var product: Identifier
    
    public var store: Identifier
}

// MARK: - CloudKit

public extension Listing {
    
    public enum CloudKitField: String {
        
        case currency, price, product, store
    }
    
    init?(record: CKRecord) {
        
        guard record.recordType == Listing.recordType,
            let currency = record[CloudKitField.currency.rawValue] as? String,
            let price = record[CloudKitField.price.rawValue] as? Double,
            let product = record[CloudKitField.product.rawValue] as? CKReference,
            let store = record[CloudKitField.store.rawValue] as? CKReference
            else { return nil }
        
        self.identifier = record.recordID.toIdentifier()
        
        self.currency = currency
        self.price = price
        self.product = product.recordID.toIdentifier()
        self.store = store.recordID.toIdentifier()
    }
}

// MARK: - Convenience Extensions

public extension Listing {
    
    
}

