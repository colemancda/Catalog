//
//  Image.swift
//  CoreCatalog
//
//  Created by Alsey Coleman Miller on 11/12/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import SwiftFoundation
import CloudKit

public struct Image: CloudKitDecodable {
    
    public static let recordType = "Image"
    
    public let identifier: Identifier
    
    // MARK: - Attributes
    
    public var data: Data
}

// MARK: - CloudKit

public extension Image {
    
    public enum CloudKitField: String {
        
        case data
    }
    
    init?(record: CKRecord) {
        
        guard record.recordType == Image.recordType,
            let dataAsset = record[CloudKitField.data.rawValue] as? CKAsset,
            let data = NSData(contentsOfURL: dataAsset.fileURL)
            else { return nil }
        
        self.identifier = record.recordID.toIdentifier()
        
        self.data = data.arrayOfBytes()
    }
}

