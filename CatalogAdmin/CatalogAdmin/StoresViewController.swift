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
import CoreData
import JGProgressHUD

/// View Controller for displaying the user's ```Store``` instances.
final class StoresViewController: UITableViewController {
    
    // MARK: - Properties
    
    var userID: CKRecordID!
    
    lazy var queryController: QueryResultsController<Store> = {
        
        let query = CKQuery(recordType: Store.recordType, predicate: NSPredicate(format: "creatorUserRecordID == %@", argumentArray: [self.userID]))
        
        let fetchRequest = NSFetchRequest(entityName: Store.entityName)
        
        fetchRequest.predicate = NSPredicate(format: "%K == %@",
            argumentArray: [Store.CoreDataProperty.creator.rawValue, self.userID.recordName])
       
        let queryController = QueryResultsController<Store>(query: query, fetchRequest: fetchRequest, store: CloudKitStore.sharedStore)
        
        queryController.event.didRefresh = { [weak self] (_) in
            
            
        }
        
        return queryController
    }()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard userID != nil else { fatalError("No UserID set") }
        
        self.refresh()
    }
    
    // MARK: - Actions
    
    @IBAction func refresh(sender: AnyObject? = nil) {
    
        self.queryController.refresh()
    }
    
    // MARK: - Private Methods
    
    
    
    
}

// MARK: - Supporting Types

final class StoreCell: UITableViewCell {
    
    @IBOutlet weak var storeNameLabel: UILabel!
    
    @IBOutlet weak var storeAddressLabel: UILabel!
    
    @IBOutlet weak var storeImageActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var storeImageView: UIImageView!
    
    var tapGestureRecognizer: UITapGestureRecognizer?
}

