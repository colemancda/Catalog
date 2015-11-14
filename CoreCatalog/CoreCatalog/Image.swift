//
//  Image.swift
//  CoreCatalog
//
//  Created by Alsey Coleman Miller on 11/12/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import SwiftFoundation

public struct Image {
    
    public static let recordType = "Image"
    
    public let identifier: Identifier
    
    // MARK: - Attributes
    
    public var image: Data
}