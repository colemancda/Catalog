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

public struct Store: CloudKitEncodable, CloudKitDecodable, CoreDataEncodable, CoreDataDecodable, CloudKitCacheable, Equatable {
    
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
    
    public var creator: Identifier
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
            let directionsNote = record[CloudKitField.directionsNote.rawValue] as? String,
            let creatorID = record.creatorUserRecordID?.recordName
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
        self.creator = creatorID
        
        if let officeNumber = record[CloudKitField.officeNumber.rawValue] as? String where officeNumber != "" {
            
            self.officeNumber = officeNumber
        }
        
        if let imageReference = record[CloudKitField.image.rawValue] as? CKReference {
            
            self.image = imageReference.recordID.recordName
        }
        
        if let location = record[CloudKitField.location.rawValue] as? CLLocation {
            
            self.location = Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    func toCloudKit() -> CKRecord {
        
        let record = CKRecord(recordType: Store.recordType, recordID: CKRecordID(recordName: recordName))
        
        record[CloudKitField.name.rawValue] = name
        record[CloudKitField.text.rawValue] = text
        record[CloudKitField.phoneNumber.rawValue] = phoneNumber
        record[CloudKitField.email.rawValue] = email
        record[CloudKitField.country.rawValue] = country
        record[CloudKitField.state.rawValue] = state
        record[CloudKitField.city.rawValue] = city
        record[CloudKitField.district.rawValue] = district
        record[CloudKitField.street.rawValue] = street
        record[CloudKitField.officeNumber.rawValue] = officeNumber
        record[CloudKitField.directionsNote.rawValue] = directionsNote
        
        if let location = self.location {
            
            let coordinates = location.toFoundation()
            
            record[CloudKitField.location.rawValue] = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        }
        
        if let image = self.image {
            
            record[CloudKitField.image.rawValue] = CKReference(recordID: CKRecordID(recordName: image), action: .None)
        }
        
        return record
    }
}

// MARK: - CoreData

public extension Store {
    
    static var entityName: String { return "Store" }
    
    enum CoreDataProperty: String {
        
        case name, text, phoneNumber, email, country, state, city, district, street, officeNumber, directionsNote, locationLatitiude, locationLongitude, image, listings, creator
    }
    
    func save(context: NSManagedObjectContext) throws -> NSManagedObject {
        
        // find or create from cache
        let managedObject = try context.findOrCreateEntity(Store.entityName, withResourceID: self.identifier)
        
        // set cached
        managedObject.willCache()
        
        // set attributes
        managedObject.set(name, CoreDataProperty.name)
        managedObject.set(text, CoreDataProperty.text)
        managedObject.set(phoneNumber, CoreDataProperty.phoneNumber)
        managedObject.set(email, CoreDataProperty.email)
        managedObject.set(country, CoreDataProperty.country)
        managedObject.set(state, CoreDataProperty.state)
        managedObject.set(city, CoreDataProperty.city)
        managedObject.set(district, CoreDataProperty.district)
        managedObject.set(street, CoreDataProperty.street)
        managedObject.set(officeNumber, CoreDataProperty.officeNumber)
        managedObject.set(directionsNote, CoreDataProperty.directionsNote)
        managedObject.set(location?.latitude, CoreDataProperty.locationLatitiude)
        managedObject.set(location?.longitude, CoreDataProperty.locationLongitude)
        managedObject.set(creator, CoreDataProperty.creator)
        
        // set relationships
        try managedObject.setManagedObject(Image.entityName, image, CoreDataProperty.image, context)
        
        // save
        try context.save()
        
        return managedObject
    }
    
    init(managedObject: NSManagedObject) {
        
        guard managedObject.entity.name == Store.entityName else { fatalError("Invalid Entity") }
        
        self.identifier = managedObject.valueForKey(CoreDataResourceIDAttributeName) as! String
        
        // attributes
        self.name = managedObject[CoreDataProperty.name.rawValue] as! String
        self.text = managedObject[CoreDataProperty.text.rawValue] as! String
        self.phoneNumber = managedObject[CoreDataProperty.phoneNumber.rawValue] as! String
        self.email = managedObject[CoreDataProperty.email.rawValue] as! String
        self.country = managedObject[CoreDataProperty.country.rawValue] as! String
        self.street = managedObject[CoreDataProperty.street.rawValue] as! String
        self.city = managedObject[CoreDataProperty.city.rawValue] as! String
        self.district = managedObject[CoreDataProperty.district.rawValue] as! String
        self.directionsNote = managedObject[CoreDataProperty.street.rawValue] as! String
        self.officeNumber = managedObject[CoreDataProperty.street.rawValue] as? String
        self.creator = managedObject[CoreDataProperty.creator.rawValue] as! String // ID is stored as string, not relationship
        
        if let latitude = managedObject[CoreDataProperty.locationLatitiude.rawValue] as? Double,
            let longitude = managedObject[CoreDataProperty.locationLongitude.rawValue] as? Double {
                
            self.location = Location(latitude: latitude, longitude: longitude)
        }
        
        // relationship
        self.image = managedObject.getIdentifier(CoreDataProperty.image.rawValue)
    }
}

// MARK: - CloudKitCacheable

public extension Store {
    
    static func fetchFromCache(recordID: RecordID, context: NSManagedObjectContext) throws -> NSManagedObject? {
        
        return try context.findEntity(Store.entityName, withResourceID: recordID.recordName)
    }
}

