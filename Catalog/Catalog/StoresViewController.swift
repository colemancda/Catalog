//
//  StoresViewController.swift
//  Catalog
//
//  Created by Alsey Coleman Miller on 11/14/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import CoreCatalog
import JGProgressHUD

final class StoresViewController: UITableViewController {
    
    // MARK: - Properties
    
    private(set) var stores = [CKRecord]()

    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    // MARK: - Actions
    
    // MARK: - Methods
    
    func configureCell(cell: StoreCell, atIndexPath indexPath: NSIndexPath) {
        
        let record = stores[indexPath.row]
        
        /*
        guard let product = Store(record: record) else { fatalError("Couldn't parse data") }
        
        cell.productNameLabel.text = product.name
        
        cell.productIdentifierLabel.text = product.productIdentifier
        
        cell.productImageActivityIndicator.hidden = false
        
        cell.productImageActivityIndicator.startAnimating()*/
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return stores.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.storeCell, forIndexPath: indexPath)!
        
        self.configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        searchBar.endEditing(true)
        
        let progressHUD = JGProgressHUD(style: .Dark)
        
        progressHUD.showInView(self.navigationController!.view)
        
        let text = searchBar.text ?? ""
        
        let predicate = NSPredicate(format: "name BEGINSWITH %@", text)
        
        let query = CKQuery(recordType: Store.recordType, predicate: predicate)
        
        CKContainer.defaultContainer().publicCloudDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            
            NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                
                guard let controller = self else { return }
                
                progressHUD.dismiss()
                
                guard error == nil else {
                    
                    controller.showErrorAlert((error! as NSError).localizedDescription)
                    
                    return
                }
                
                controller.stores = results!
                
                controller.tableView.reloadData()
            }
        }
    }
}

// MARK: - Supporting Types

final class StoreCell: UITableViewCell {
    
    @IBOutlet weak var storeNameLabel: UILabel!
    
    @IBOutlet weak var storeAddressLabel: UILabel!
    
    @IBOutlet weak var productImageActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var productImageView: UIImageView!
}