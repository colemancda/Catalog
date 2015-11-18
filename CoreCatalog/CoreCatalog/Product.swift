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

public struct Product: CloudKitEncodable, CloudKitDecodable, CoreDataEncodable, CoreDataDecodable, CloudKitCacheable, Equatable {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var image: Identifier?
}

// MARK: - CloudKit

public extension Product {
    
    static var recordType: String { return "Product" }
    
    public enum CloudKitField: String {
        
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
        
        
    }
}

// MARK: - CoreData

public extension Product {
    
    static var entityName: String { return "Product" }
    
    enum CoreDataProperty: String {
        
        case name, text, phoneNumber, email, country
    }
}

