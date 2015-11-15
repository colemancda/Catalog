//
//  Location.swift
//  CoreCatalog
//
//  Created by Alsey Coleman Miller on 11/13/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import SwiftFoundation
import CoreLocation

public struct Location: Equatable, FoundationConvertible {
    
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

// MARK: - CoreLocation

public extension Location {
    
    init(foundation: CLLocationCoordinate2D) {
        
        self.latitude = foundation.latitude
        self.longitude = foundation.longitude
    }
    
    func toFoundation() -> CLLocationCoordinate2D {
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}