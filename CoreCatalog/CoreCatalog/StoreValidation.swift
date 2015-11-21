//
//  StoreValidation.swift
//  CoreCatalog
//
//  Created by Alsey Coleman Miller on 11/20/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import SwiftFoundation

public extension Store {
    
    public struct Validate {
        
        public static func name(value: String) -> Bool {
            
            return value.utf8.count > 1
        }
        
        public static func text(value: String) -> Bool {
            
            return value.utf8.count > 10
        }
        
        public static func phoneNumber(value: String) -> Bool {
            
            return value.utf8.count > 6
        }
        
        private static let emailRegex = try! RegularExpression("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}", options: [.ExtendedSyntax])
        
        public static func email(value: String) -> Bool {
            
            return emailRegex.match(value)?.range.count == value.utf8.count
        }
    }
}