//
//  ProductListingsViewController.swift
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

final class ProductListingsViewController: UITableViewController, UISearchBarDelegate {
    
    // MARK: - IB Outlets
    
    // MARK: - Properties
    
    var product: CKRecord!
    
    private(set) var results = [Listing]()
    
    private(set) var cachedStores = [String: Store]()
    
    // MARK: Views
    
    let progressHUD = JGProgressHUD(style: .Dark)
    
    lazy var emptyView: EmptyView = {
        
        let emptyView = EmptyView.fromNib()
        
        emptyView.label.text = LocalizedText.EmptyProductListings.localizedString
        
        emptyView.emptyImageView.image = R.image.emptyStores!
        
        return emptyView
    }()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    // MARK: - Actions
    
    @IBAction func refreshData(sender: AnyObject? = nil) {
        
        let empty = (results.count == 0)
        
        if empty {
            
            progressHUD.showInView(self.navigationController!.view!)
            
            progressHUD.interactionType = .BlockTouchesOnHUDView
            
            tableView.scrollEnabled = false
        }
        
        let predicate = NSPredicate(format: "%K == %@", Listing.CloudKitField.product.rawValue, product)
        
        let query = CKQuery(recordType: Listing.recordType, predicate: predicate)
        
        let priceSort = NSSortDescriptor(key: Listing.CloudKitField.price.rawValue, ascending: true)
        
        query.sortDescriptors = [priceSort]
        
        CKContainer.defaultContainer().publicCloudDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            
            NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                
                guard let controller = self else { return }
                
                controller.refreshControl?.endRefreshing()
                
                if empty {
                    
                    controller.tableView.scrollEnabled = true
                }
                
                guard error == nil else {
                    
                    if empty {
                        
                        controller.progressHUD.dismissAnimated(false)
                    }
                    
                    controller.showErrorAlert((error! as NSError).localizedDescription)
                    
                    return
                }
                
                if empty {
                    
                    controller.progressHUD.dismiss()
                }
                
                var listings = [Listing]()
                
                for record in results! {
                    
                    guard let listing = Listing(record: record) else {
                        
                        controller.showErrorAlert(LocalizedText.InvalidServerResponse.localizedString)
                        
                        return
                    }
                    
                    listings.append(listing)
                }
                
                // set cache
                controller.results = listings
                controller.cachedStores = [String: Store]()
                
                // refresh UI
                controller.tableView.reloadData()
                controller.updateEmptyView()
            }
        }
    }
    
    // MARK: - Methods
    
    func configureCell(cell: ListingStoreCell, atIndexPath indexPath: NSIndexPath) {
        
        let results = self.results
        
        let listing = results[indexPath.row]
        
        cell.listingPriceLabel.text = listing.priceString
        
        cell.storeNameLabel.text = LocalizedText.Loading.localizedString
        
        cell.storeAddressLabel.text = ""
        
        cell.userInteractionEnabled = false
        
        // load store
        
        CKContainer.defaultContainer().publicCloudDatabase.fetchRecordWithID(listing.store.toRecordID()) { (record, error) in
            
            NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                
                guard let controller = self where controller.results == results  else { return }
                
                guard error == nil, let record = record, let store = Store(record: record) else {
                    
                    print("Couldn't load store. (\(error))")
                    
                    cell.storeNameLabel.text = LocalizedText.Error.localizedString
                    
                    cell.storeAddressLabel.text = ""
                    
                    return
                }
                
                // enable cell
                
                cell.userInteractionEnabled = true
                
                // save to cache
                
                controller.cachedStores[store.identifier.value] = store
                
                // configure cell
                
                cell.storeNameLabel.text = store.name
                
                var addressText = store.street + ", " + store.district + ", " + store.city
                
                if let storeNumber = store.officeNumber {
                    
                    addressText += " - " + LocalizedText.Store.localizedString + " " + storeNumber
                }
                
                cell.storeAddressLabel.text = addressText
            }
        }
    }
    
    func updateEmptyView() {
        
        // empty results view
        if results.count == 0 {
            
            tableView.scrollEnabled = false
            
            tableView.backgroundView = emptyView
            
            tableView.tableFooterView = UIView()
        }
        else {
            
            tableView.scrollEnabled = true
            
            tableView.tableFooterView = nil
            
            tableView.backgroundView = nil
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return results.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.listingStoreCell, forIndexPath: indexPath)!
        
        self.configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
            
        case R.segue.productListingShowStore:
            
            let selectedListing = self.results[tableView.indexPathForSelectedRow!.row]
            
            let store = self.cachedStores[selectedListing.store.value]!
            
            let destinationVC = segue.destinationViewController as! StoreViewController
            
            destinationVC.store = store
            
        default: fatalError("Unknown Segue: \(segue.identifier)")
        }
    }
}

// MARK: - Supporting Types

final class ListingStoreCell: UITableViewCell {
    
    @IBOutlet weak var listingPriceLabel: UILabel!
    
    @IBOutlet weak var storeNameLabel: UILabel!
    
    @IBOutlet weak var storeAddressLabel: UILabel!
}



