//
//  RequestAuthenticationContext.swift
//  CoreCerradura
//
//  Created by Alsey Coleman Miller on 9/23/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import SwiftFoundation
import CoreModel
import NetworkObjects
import SwiftCF

public struct RequestAuthenticationContext: AuthenticationContext {
    
    // MARK: - Properties
    
    public let date: Date
    
    public let dateString: String
    
    public let request: Request
    
    // MARK: - Initialization
    
    public init?(request: Request, dateString: String) {
        
        self.request = request
        self.dateString = dateString
        
        guard let date = HTTPDateFormatter.valueFromString(dateString) else { return nil }
        
        self.date = date
    }
    
    public init(request: Request, date: Date = Date()) {
        
        self.request = request
        self.date = date
        self.dateString = HTTPDateFormatter.stringFromValue(date)
    }
    
    // MARK: - AuthenticationContext
    
    public var concatenatedString: String {
        
        let requestString: String
        
        switch request {
            
        case let .Get(resource): requestString = "Get \(resource.entityName) \(resource.resourceID)"
            
        case let .Edit(resource, _): requestString = "Edit \(resource.entityName) \(resource.resourceID)"
            
        case let .Delete(resource): requestString = "Delete \(resource.entityName) \(resource.resourceID)"
            
        case let .Create(entityName, _): requestString = "Create \(entityName)"
            
        case let .Search(fetchRequest): requestString = "Search \(fetchRequest.entityName)"
            
        case let .Function(resource, functionName, _): requestString = "Function \(resource.entityName) \(resource.resourceID) \(functionName)"
        }
        
        return "Date: \(dateString) " + "Request: \(requestString)"
    }
}

// MARK: - Private Constants

private let HTTPDateFormatter = DateFormatter(format: "EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz")

