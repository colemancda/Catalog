//
//  Store.swift
//  CoreCatalog
//
//  Created by Alsey Coleman Miller on 11/3/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import CoreLocation
import CloudKit

public struct Store: CloudKitDecodable {
    
    public static let recordType = "Store"
    
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

// MARK: - CloudKit

public extension Store {
    
    public enum CloudKitField: String {
    
        case name, text, phoneNumber, email, country, state, city, district, street, officeNumber, directionsNote, location, image
    }
    
    init?(record: CKRecord) {
        
        guard record.recordType == Store.recordType,
            let name = record[CloudKitField.name.rawValue] as? String,
            let text = record[CloudKitField.text.rawValue] as? String,
            let phoneNumber = record[CloudKitField.phoneNumber.rawValue] as? String,
            let email = record[CloudKitField.email.rawValue] as? String,
            let country = record[CloudKitField.country.rawValue] as? String,
            let state = record[CloudKitField.state.rawValue] as? String,
            let city = record[CloudKitField.city.rawValue] as? String,
            let district = record[CloudKitField.district.rawValue] as? String,
            let street = record[CloudKitField.street.rawValue] as? String,
            let directionsNote = record[CloudKitField.directionsNote.rawValue] as? String
            else { return nil }
        
        self.identifier = record.recordID.toIdentifier()
        
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
        
        if let officeNumber = record[CloudKitField.officeNumber.rawValue] as? String {
            
            self.officeNumber = officeNumber
        }
        
        if let imageReference = record[CloudKitField.image.rawValue] as? CKReference {
            
            self.image = imageReference.recordID.toIdentifier()
        }
    }
}


