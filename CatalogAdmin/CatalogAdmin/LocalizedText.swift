//
//  LocalizedText.swift
//  Vistage
//
//  Created by Alsey Coleman Miller on 10/27/15.
//  Copyright © 2015 Vistage. All rights reserved.
//

import Foundation

struct LocalizedText {
    
    var value: String
    
    var identifier: String
    
    var localizedString: String {
        
        return NSLocalizedString(identifier,
            tableName: nil,
            bundle: NSBundle.mainBundle(),
            value: value,
            comment: identifier)
    }
}

// List of Localized Strings

extension LocalizedText {
    
    static let InvalidEmail = LocalizedText(value: "Invalid Email", identifier: "InvalidEmail")
    
    static let InvalidValues = LocalizedText(value: "Invalid Values", identifier: "InvalidValues")
    
    static let ImageRequired = LocalizedText(value: "Image Required", identifier: "ImageRequired")
    
    static let Email = LocalizedText(value: "Email", identifier: "Email")
    
    static let Success = LocalizedText(value: "Success", identifier: "Success")
    
    static let Ok = LocalizedText(value: "OK", identifier: "Ok")
    
    static let Cancel = LocalizedText(value: "Cancel", identifier: "Cancel")
    
    static let On = LocalizedText(value: "On", identifier: "On")
    
    static let Off = LocalizedText(value: "Off", identifier: "Off")
    
    static let Loading = LocalizedText(value: "Loading", identifier: "Loading")
    
    static let Error = LocalizedText(value: "Error", identifier: "Error")
    
    static let InvalidResponse = LocalizedText(value: "The server responded with an invalid response.", identifier: "InvalidResponse")
}

