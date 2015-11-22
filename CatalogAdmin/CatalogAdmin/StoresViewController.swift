//
//  StoresViewController.swift
//  CatalogAdmin
//
//  Created by Alsey Coleman Miller on 11/22/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import Foundation
import UIKit
import CoreCatalog
import CloudKit
import CloudKitStore
import JGProgressHUD

/// View Controller for displaying the user's ```Store``` instances.
final class StoresViewController: UITableViewController {
    
    // MARK: - Properties
    
    var userID: Identifier!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refresh()
    }
    
    // MARK: - Actions
    
    @IBAction func refresh(sender: AnyObject? = nil) {
    
        
    }
    
    // MARK: - Private Methods
    
    
    
    
}