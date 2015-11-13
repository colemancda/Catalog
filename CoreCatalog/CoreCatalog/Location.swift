//
//  Location.swift
//  CoreCatalog
//
//  Created by Alsey Coleman Miller on 11/13/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

public struct Location {
    
    public var latitude: Double
    
    public var longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        
        self.latitude = latitude
        self.longitude = longitude
    }
}