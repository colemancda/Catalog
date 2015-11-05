//
//  Product.swift
//  CoreCatalog
//
//  Created by Alsey Coleman Miller on 11/3/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CoreData

public final class Product: NSManagedObject {
    
    @NSManaged public private(set) var name: String
    
    @NSManaged public private(set) var productIdentifier: String
    
    @NSManaged public private(set) var image: Image
    
    @NSManaged public private(set) var listings: Set<Listing>?
}