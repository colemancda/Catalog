//
//  Location.swift
//  CoreCatalog
//
//  Created by Alsey Coleman Miller on 11/13/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

public struct Location: Equatable {
    
    public var latitude: Double
    
    public var longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        
        self.latitude = latitude
        self.longitude = longitude
    }
}

// MARK: - Equatable

public func == (lhs: Location, rhs: Location) -> Bool {
    
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}