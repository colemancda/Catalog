//
//  Image.swift
//  CoreCatalog
//
//  Created by Alsey Coleman Miller on 11/3/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CoreData

public final class Image: NSManagedObject {
    
    @NSManaged public private(set) var data: NSData
    
    @NSManaged public private(set) var product: Product?
    
    @NSManaged public private(set) var store: Store?
}