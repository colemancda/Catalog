//
//  Identifier.swift
//  CoreCatalog
//
//  Created by Alsey Coleman Miller on 11/12/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import CloudKit

public struct Identifier {
    
    public var value: String
    
    public init(_ value : String) {
        
        self.value = value
    }
}

public extension Identifier {
    
    func toRecordID() -> CKRecordID {
        
        return CKRecordID(recordName: value)
    }
}

public extension CKRecordID {
    
    func toIdentifier() -> Identifier {
        
        return Identifier(recordName)
    }
}