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
    
    static let EmptyProductsResult = LocalizedText(value: "No products were found", identifier: "EmptyProductsResult")
    
    static let EmptyProductSearch = LocalizedText(value: "Search for a product", identifier: "EmptyProductSearch")
    
    static let EmptyStoreResult = LocalizedText(value: "No stores were found", identifier: "EmptyStoreResult")
    
    static let EmptyStoreSearch = LocalizedText(value: "Search for a store", identifier: "EmptyStoreSearch")
    
    static let EmptyProductListings = LocalizedText(value: "No stores are selling this product", identifier: "EmptyProductListings")
    
    static let Email = LocalizedText(value: "Email", identifier: "Email")
    
    static let Success = LocalizedText(value: "Success", identifier: "Success")
    
    static let Ok = LocalizedText(value: "OK", identifier: "Ok")
    
    static let Cancel = LocalizedText(value: "Cancel", identifier: "Cancel")
    
    static let On = LocalizedText(value: "On", identifier: "On")
    
    static let Off = LocalizedText(value: "Off", identifier: "Off")
    
    static let Loading = LocalizedText(value: "Loading...", identifier: "Loading")
    
    static let Error = LocalizedText(value: "Error", identifier: "Error")
}

