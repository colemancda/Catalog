//
//  ResourceID.swift
//  CoreCerraduraServer
//
//  Created by Alsey Coleman Miller on 9/25/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import SwiftFoundation

public func NewResourceID(entityName: String) -> String {
    
    let uuid = UUID()
    
    return uuid.rawValue
}