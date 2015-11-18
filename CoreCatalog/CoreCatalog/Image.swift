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

public struct Image: CloudKitDecodable {
    
    public static let recordType = "Image"
    
    public let identifier: Identifier
    
    // MARK: - Attributes
    
    public var data: Data
    
    public var referenceID: String
}

// MARK: - CloudKit

public extension Image {
    
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
        self.referenceID = reference.recordID.recordName
    }
}

// MARK: - CoreData

public extension Image {
    
    static var entityName: String { return "Image" }
}
