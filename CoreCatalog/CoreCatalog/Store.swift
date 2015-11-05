//
//  Store.swift
//  CoreCatalog
//
//  Created by Alsey Coleman Miller on 11/3/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CoreData

public final class Store: NSManagedObject {
    
    // MARK: - Attributes
    
    // Info
    
    @NSManaged public private(set) var name: String
    
    @NSManaged public private(set) var text: String
    
    @NSManaged public private(set) var phoneNumber: String
    
    // Address
    
    @NSManaged public private(set) var state: String
    
    @NSManaged public private(set) var city: String
    
    @NSManaged public private(set) var district: String
    
    @NSManaged public private(set) var street: String
    
    @NSManaged public private(set) var officeNumber: String
    
    @NSManaged public private(set) var directionsNote: String
    
    // Credentials
    
    @NSManaged public private(set) var email: String
    
    @NSManaged public private(set) var password: String
    
    // MARK: - Relationships
    
    @NSManaged public private(set) var image: Image
    
    @NSManaged public private(set) var listings: Set<Listing>?
}