//
//  Listing.swift
//  CoreCatalog
//
//  Created by Alsey Coleman Miller on 11/3/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CoreData

public struct Listing {
    
    public let identifier: Identifier
    
    // MARK: - Attributes
    
    public var currency: String
    
    public var price: Double
    
    public var product: Product
    
    public var store: Store
}