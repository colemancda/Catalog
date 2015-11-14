//
//  LocalizedText.swift
//  Catalog
//
//  Created by Alsey Coleman Miller on 11/14/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
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
    
    static let Store = LocalizedText(value: "Store", identifier: "Store")
    
    static let InvalidEmail = LocalizedText(value: "Invalid Email", identifier: "InvalidEmail")
    
    static let Recover = LocalizedText(value: "Recover", identifier: "Recover")
    
    static let RecoverUsername = LocalizedText(value: "Recover Username", identifier: "RecoverUsername")
    
    static let RecoverPassword = LocalizedText(value: "Recover Password", identifier: "RecoverPassword")
    
    static let RecoverUsernameMessage = LocalizedText(value: "Fill your email to send your associated username", identifier: "RecoverUsernameMessage")
    
    static let RecoverPasswordMessage = LocalizedText(value: "Fill your email to send your password", identifier: "RecoverPasswordMessage")
    
    static let Email = LocalizedText(value: "Email", identifier: "Email")
    
    static let CheckEmail = LocalizedText(value: "Check your email", identifier: "CheckEmail")
    
    static let Success = LocalizedText(value: "Success", identifier: "Success")
    
    static let Ok = LocalizedText(value: "OK", identifier: "Ok")
    
    static let Cancel = LocalizedText(value: "Cancel", identifier: "Cancel")
    
    static let On = LocalizedText(value: "On", identifier: "On")
    
    static let Off = LocalizedText(value: "Off", identifier: "Off")
    
    static let Loading = LocalizedText(value: "Loading", identifier: "Loading")
    
    static let LoadingGroups = LocalizedText(value: "Loading Groups...", identifier: "LoadingGroups")
    
    static let NoGroups = LocalizedText(value: "No Groups", identifier: "NoGroups")
    
    static let Error = LocalizedText(value: "Error", identifier: "Error")
}

