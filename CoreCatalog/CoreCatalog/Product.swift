//
//  Product.swift
//  CoreCatalog
//
//  Created by Alsey Coleman Miller on 11/3/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CloudKit

public struct Product: CloudKitDecodable {
    
    public static let recordType = "Product"
    
    public let identifier: Identifier
    
    public var name: String
    
    public var image: Identifier?
}

// MARK: - CloudKit

public extension Product {
    
    public enum CloudKitField: String {
        
        case name, image
    }
    
    init?(record: CKRecord) {
        
        guard record.recordType == Product.recordType,
            let name = record[CloudKitField.name.rawValue] as? String
        else { return nil }
        
        self.identifier = record.recordID.toIdentifier()
        self.name = name
        
        if let imageReference = record[CloudKitField.image.rawValue] as? CKReference {
            
            self.image = imageReference.recordID.toIdentifier()
        }
        
    }
}




