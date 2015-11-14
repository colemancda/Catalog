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
        
        cell.productIdentifierLabel.text = product.productIdentifier
        
        cell.productImageActivityIndicator.hidden = false
        
        cell.productImageActivityIndicator.startAnimating()
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
        
        
    }
}

// MARK: - Supporting Types

final class ProductCell: UITableViewCell {
    
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBOutlet weak var productIdentifierLabel: UILabel!
    
    @IBOutlet weak var productImageActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var productImageView: UIImageView!
}

