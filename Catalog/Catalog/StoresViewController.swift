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
    
    private(set) var didSearch = false
    
    // MARK: Views
    
    lazy var emptySearchView: EmptyView = {
        
        let emptyView = EmptyView.fromNib()
        
        emptyView.label.text = LocalizedText.EmptyProductSearch.localizedString
        
        emptyView.emptyImageView.image = R.image.storeImage!
        
        return emptyView
    }()
    
    lazy var emptyResultsView: EmptyView = {
        
        let emptyView = EmptyView.fromNib()
        
        emptyView.label.text = LocalizedText.EmptyProductsResult.localizedString
        
        emptyView.emptyImageView.image = R.image.storeImage!
        
        return emptyView
    }()

    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        self.updateFooter()
    }
    
    // MARK: - Actions
    
    // MARK: - Methods
    
    func configureCell(cell: StoreCell, atIndexPath indexPath: NSIndexPath) {
        
        let record = stores[indexPath.row]
        
        guard let store = Store(record: record) else { fatalError("Couldn't parse data") }
        
        cell.storeNameLabel.text = store.name
        
        var addressText = store.street + ", " + store.district + ", " + store.city + ", " + store.state + ", " + store.country
        
        if let storeNumber = store.officeNumber {
            
            addressText += " - " + LocalizedText.Store.localizedString + " " + storeNumber
        }
        
        cell.storeAddressLabel.text = addressText
        
        if let image = store.image {
            
            cell.storeImageActivityIndicator.hidden = false
            
            cell.storeImageActivityIndicator.startAnimating()
            
            // load image
            
            CKContainer.defaultContainer().publicCloudDatabase.fetchRecordWithID(image.toRecordID(), completionHandler: { [weak cell] (record, error) in
                
                guard let cell = cell else { return }
                
                
                
            })
        }
        else {
            
            cell.storeImageActivityIndicator.stopAnimating()
            
            cell.storeImageActivityIndicator.hidden = true
            
            cell.storeImageView.image = R.image.storeImage!
        }
    }
    
    func updateFooter() {
        
        // empty results view
        if stores.count == 0 {
            
            if self.didSearch {
                
                tableView.tableFooterView = emptyResultsView
            }
            else {
                
                tableView.tableFooterView = emptySearchView
            }
            
            tableView.scrollEnabled = false
            
            tableView.tableFooterView?.frame = tableView.frame
        }
        else {
            
            tableView.scrollEnabled = true
            
            tableView.tableFooterView = nil
        }
        
        self.tableView.reloadData()
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
    
    @IBOutlet weak var storeImageActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var storeImageView: UIImageView!
}
