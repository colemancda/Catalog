//
//  Store.swift
//  CoreCatalog
//
//  Created by Alsey Coleman Miller on 11/3/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import CoreLocation
import CloudKit
import CoreData
import CoreDataStruct
import CloudKitStruct
import CloudKitStore

public struct Store: CloudKitDecodable, CloudKitCacheable, CoreDataEncodable, CoreDataDecodable, Equatable {
    
    public let identifier: Identifier
    
    // MARK: - Attributes
    
    // MARK: Info
    
    public var name: String
    
    public var text: String
    
    public var phoneNumber: String
    
    public var email: String
    
    // MARK: Address
    
    public var country: String
    
    public var state: String
    
    public var city: String
    
    public var district: String
    
    public var street: String
    
    public var officeNumber: String?
    
    public var directionsNote: String
    
    public var location: Location?
    
    // MARK: - Relationships
    
    public var image: Identifier?
}

// MARK: - Equatable

public func == (lhs: Store, rhs: Store) -> Bool {
    
    return (lhs.identifier == rhs.identifier &&
        lhs.name == rhs.name &&
        lhs.text == rhs.text &&
        lhs.phoneNumber == rhs.phoneNumber &&
        lhs.email == rhs.email &&
        lhs.country == rhs.country &&
        lhs.state == rhs.state &&
        lhs.city == rhs.city &&
        lhs.district == rhs.district &&
        lhs.street == rhs.street &&
        lhs.officeNumber == rhs.officeNumber &&
        lhs.directionsNote == rhs.directionsNote &&
        lhs.location == rhs.location &&
        lhs.image == rhs.image)
}

// MARK: - CloudKit

public extension Store {
    
    static var recordType: String { return "Store" }
    
    var recordName: String { return identifier }
    
     enum CloudKitField: String {
    
        case name, text, phoneNumber, email, country, state, city, district, street, officeNumber, directionsNote, location, image
    }
    
    init?(recordName: String, values: [String : CKRecordValue]) {
        
        guard let name = values[CloudKitField.name.rawValue] as? String,
            let text = values[CloudKitField.text.rawValue] as? String,
            let phoneNumber = values[CloudKitField.phoneNumber.rawValue] as? String,
            let email = values[CloudKitField.email.rawValue] as? String,
            let country = values[CloudKitField.country.rawValue] as? String,
            let state = values[CloudKitField.state.rawValue] as? String,
            let city = values[CloudKitField.city.rawValue] as? String,
            let district = values[CloudKitField.district.rawValue] as? String,
            let street = values[CloudKitField.street.rawValue] as? String,
            let directionsNote = values[CloudKitField.directionsNote.rawValue] as? String
            else { return nil }
        
        self.identifier = recordName
        
        self.name = name
        self.text = text
        self.phoneNumber = phoneNumber
        self.email = email
        self.country = country
        self.state = state
        self.city = city
        self.district = district
        self.street = street
        self.directionsNote = directionsNote
        
        if let officeNumber = values[CloudKitField.officeNumber.rawValue] as? String where officeNumber != "" {
            
            self.officeNumber = officeNumber
        }
        
        if let imageReference = values[CloudKitField.image.rawValue] as? CKReference {
            
            self.image = imageReference.recordID.recordName
        }
        
        if let location = values[CloudKitField.location.rawValue] as? CLLocation {
            
            self.location = Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
}

// MARK: - CoreData

public extension Store {
    
    static var entityName: String { return "Store" }
    
    enum CoreDataProperty: String {
        
        case name, text, phoneNumber, email, country, state, city, district, street, officeNumber, directionsNote, locationLatitiude, locationLongitude, image, listings
    }
    
    func save(context: NSManagedObjectContext) throws -> NSManagedObject {
        
        
    }
}

// MARK: - CloudKitCacheable

public extension Store {
    
    static func fetchFromCache(recordName: String, context: NSManagedObjectContext) throws -> NSManagedObject? {
        
        
    }
}

