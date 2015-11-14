//
//  ProductsViewController.swift
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

final class ProductsViewController: UITableViewController, UISearchBarDelegate {
    
    // MARK: - IB Outlets
    
    // MARK: - Properties
    
    private(set) var products = [CKRecord]()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    // MARK: - Actions
    
    // MARK: - Methods
    
    func configureCell(cell: ProductCell, atIndexPath indexPath: NSIndexPath) {
        
        let record = products[indexPath.row]
        
        guard let product = Product(record: record) else { fatalError("Couldn't parse data") }
        
        cell.productNameLabel.text = product.name
        
        cell.productIdentifierLabel.text = product.identifier.value
        
        if let image = product.image {
            
            cell.productImageActivityIndicator.hidden = false
            
            cell.productImageActivityIndicator.startAnimating()
            
            // load image
        }
        else {
            
            cell.productImageActivityIndicator.stopAnimating()
            
            cell.productImageActivityIndicator.hidden = true
            
            cell.productImageView.image = R.image.storeImage!
        }
        
        
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return products.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.productCell, forIndexPath: indexPath)!
        
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
        
        let query = CKQuery(recordType: Product.recordType, predicate: predicate)
        
        CKContainer.defaultContainer().publicCloudDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            
            NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                
                guard let controller = self else { return }
                
                progressHUD.dismiss()
                
                guard error == nil else {
                    
                    controller.showErrorAlert((error! as NSError).localizedDescription)
                    
                    return
                }
                
                controller.products = results!
                
                controller.tableView.reloadData()
            }
        }
    }
}

// MARK: - Supporting Types

final class ProductCell: UITableViewCell {
    
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBOutlet weak var productIdentifierLabel: UILabel!
    
    @IBOutlet weak var productImageActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var productImageView: UIImageView!
}

