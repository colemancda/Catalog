//
//  LocalizedDescription.swift
//  Vistage
//
//  Created by Alsey Coleman Miller on 11/19/15.
//  Copyright © 2015 Vistage. All rights reserved.
//

import Foundation
import CloudKitStore
import CoreCatalog

protocol LocalizedDescription {
    
    var localizedDescription: String { get }
}

extension NSError: LocalizedDescription { }

extension CloudKitStore.Error: LocalizedDescription {
    
    var localizedDescription: String {
        
        switch self {
            
        case CouldNotDecode:
            
            return LocalizedText.InvalidResponse.localizedString
        }
    }
}

func ErrorText(error: ErrorType) -> String {
    
    if let localizedError = error as? LocalizedDescription {
        
        return localizedError.localizedDescription
    }
    else { return (error as NSError).localizedDescription }
}