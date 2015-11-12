//
//  Validate.swift
//  CoreCerradura
//
//  Created by Alsey Coleman Miller on 9/28/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import SwiftFoundation

// MARK: - Lock

// MARK: - User

public extension Model.User {
    
    public struct Validate {
        
        private static let usernameRegex = try! RegularExpression("([a-z0-9_-]){6,}", options: [.ExtendedSyntax])
        
        public static func username(value: String) -> Bool {
            
            return usernameRegex.match(value)?.range.count == value.utf8.count
        }
        
        private static let passwordRegex = try! RegularExpression("([A-Za-z0-9_-]){6,}", options: [.ExtendedSyntax])
        
        public static func password(value: String) -> Bool {
            
            return usernameRegex.match(value)?.range.count == value.utf8.count
        }
        
        private static let emailRegex = try! RegularExpression("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}", options: [.ExtendedSyntax])
        
        public static func email(value: String) -> Bool {
            
            return emailRegex.match(value)?.range.count == value.utf8.count
        }
    }
}