//
//  Listing.swift
//  CoreCatalog
//
//  Created by Alsey Coleman Miller on 11/3/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CoreData

public final class Listing: NSManagedObject {
    
    @NSManaged public private(set) var currency: String
    
    @NSManaged public private(set) var price: NSNumber
    
    @NSManaged public private(set) var product: Product
    
    @NSManaged public private(set) var store: Store
}