//
//  Currency.swift
//  CoreCatalog
//
//  Created by Alsey Coleman Miller on 11/16/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

public enum Currency: String {
    
    /// ```$``` US Dollars
    case USD
    
    /// ```S/.``` Peruvian Nuevos Soles
    case PEN
}

public extension Currency {
    
    var allCurrencies: [Currency] {
        
        var currencies = [Currency]()
        
        currencies.append(.USD)
        currencies.append(.PEN)
        
        return currencies
    }
}