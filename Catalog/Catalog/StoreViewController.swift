//
//  StoreViewController.swift
//  Catalog
//
//  Created by Alsey Coleman Miller on 11/15/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import CoreCatalog

final class StoreViewController: UITableViewController {
    
    // MARK: - IB Outlets
    
    
    
    // MARK: - Properties
    
    var store: Store!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard self.store != nil else { fatalError("Store must be set") }
        
        // setup UI
        self.configureUI()
    }
    
    // MARK: - Methods
    
    func configureUI() {
        
        self.navigationItem.title = store.name
    }
}