//
//  MainQueue.swift
//  CatalogAdmin
//
//  Created by Alsey Coleman Miller on 11/21/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import Foundation

func MainQueue(block: () -> ()) {
    
    NSOperationQueue.mainQueue().addOperationWithBlock(block)
}