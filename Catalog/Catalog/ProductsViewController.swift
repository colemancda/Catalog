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
import JTSImage

final class ProductsViewController: UITableViewController, UISearchBarDelegate {
    
    // MARK: - IB Outlets
    
    // MARK: - Properties
    
    private(set) var products = [CKRecord]()
    
    private(set) var didSearch = false
    
    // MARK: Views
    
    lazy var emptySearchView: EmptyView = {
        
        let emptyView = EmptyView.fromNib()
        
        emptyView.label.text = LocalizedText.EmptyProductSearch.localizedString
        
        emptyView.emptyImageView.image = R.image.emptySearch!
        
        return emptyView
    }()
    
    lazy var emptyResultsView: EmptyView = {
        
        let emptyView = EmptyView.fromNib()
        
        emptyView.label.text = LocalizedText.EmptyProductsResult.localizedString
        
        emptyView.emptyImageView.image = R.image.emptyProduct!
        
        return emptyView
    }()
    
    // MARK: - Private Properties
    
    private lazy var loadImageOperationQueue: NSOperationQueue = {
        
        let queue = NSOperationQueue()
        
        queue.name = "\(self) Load Image Queue"
        
        return queue
    }()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        self.updateEmptyView()
    }
    
    // MARK: - Actions
    
    @IBAction func imageTapped(sender: UIGestureRecognizer) {
        
        let imageView = sender.view as! UIImageView
        
        // create image info
        let imageInfo = JTSImageInfo()
        imageInfo.image = imageView.image!
        imageInfo.referenceRect = imageView.frame
        imageInfo.referenceView = imageView.superview
        imageInfo.referenceContentMode = imageView.contentMode
        
        // create image VC
        let imageVC = JTSImageViewController(imageInfo: imageInfo,
            mode: JTSImageViewControllerMode.Image,
            backgroundStyle: JTSImageViewControllerBackgroundOptions.Blurred)
        
        // present VC
        imageVC.showFromViewController(self, transition: JTSImageViewControllerTransition.FromOriginalPosition)
    }
    
    // MARK: - Methods
    
    func configureCell(cell: ProductCell, atIndexPath indexPath: NSIndexPath) {
        
        let products = self.products
        
        let record = products[indexPath.row]
        
        guard let product = Product(record: record) else { fatalError("Couldn't parse data") }
        
        cell.productNameLabel.text = product.name
        
        cell.productIdentifierLabel.text = product.identifier.value
        
        if let imageIdentifier = product.image {
            
            cell.productImageActivityIndicator.hidden = false
            
            cell.productImageActivityIndicator.startAnimating()
            
            cell.productImageView.image = nil
            
            cell.tapGestureRecognizer = nil
            
            // load image
            
            CKContainer.defaultContainer().publicCloudDatabase.fetchRecordWithID(imageIdentifier.toRecordID(), completionHandler: { (record, error) in
                
                NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                    
                    guard let controller = self where controller.products == products  else { return }
                    
                    guard error == nil else {
                        
                        print("Couldn't load product image. (\(error))")
                        
                        cell.productImageActivityIndicator.stopAnimating()
                        
                        cell.productImageActivityIndicator.hidden = true
                        
                        cell.productImageView.image = R.image.storeImage!
                        
                        return
                    }
                    
                    controller.loadImageOperationQueue.addOperationWithBlock { [weak self] in
                        
                        guard let catalogImage = Image(record: record!) else { fatalError("Could not parse") }
                        
                        let image = UIImage(data: NSData(bytes: catalogImage.data))!
                        
                        NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                            
                            guard let controller = self where controller.products == products  else { return }
                            
                            cell.productImageView.image = image
                            
                            cell.productImageActivityIndicator.stopAnimating()
                            
                            cell.productImageActivityIndicator.hidden = true
                            
                            // setup tap gesture
                            if cell.tapGestureRecognizer == nil {
                                
                                cell.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "imageTapped:")
                                
                                cell.productImageView.addGestureRecognizer(cell.tapGestureRecognizer!)
                            }
                        }
                    }
                }
            })
        }
        else {
            
            cell.productImageActivityIndicator.stopAnimating()
            
            cell.productImageActivityIndicator.hidden = true
            
            cell.productImageView.image = R.image.productPlaceholder!
            
            cell.tapGestureRecognizer = nil
        }
    }
    
    func updateEmptyView() {
        
        // empty results view
        if products.count == 0 {
            
            let emptyView: EmptyView
            
            if self.didSearch {
                
                emptyView = emptyResultsView
            }
            else {
                
                emptyView = emptySearchView
            }
            
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
        
        return products.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.productCell, forIndexPath: indexPath)!
        
        self.configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        self.didSearch = true
        
        searchBar.endEditing(true)
        
        let progressHUD = JGProgressHUD(style: .Dark)
        
        progressHUD.showInView(self.navigationController!.view)
        
        let text = searchBar.text ?? ""
        
        let predicate = NSPredicate(format: "%K BEGINSWITH %@", Product.CloudKitField.name.rawValue, text)
        
        let query = CKQuery(recordType: Product.recordType, predicate: predicate)
        
        let sort = NSSortDescriptor(key: Product.CloudKitField.name.rawValue, ascending: true)
        
        query.sortDescriptors = [sort]
        
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
                
                controller.updateEmptyView()
            }
        }
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
            
        case R.segue.showProductListings:
            
            let selectedProduct = products[tableView.indexPathForSelectedRow!.row]
            
            let destinationVC = segue.destinationViewController as! ProductListingsViewController
            
            destinationVC.product = selectedProduct
            
        default: fatalError("Segue not handled: \(segue.identifier!)")
        }
    }
}

// MARK: - Supporting Types

final class ProductCell: UITableViewCell {
    
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBOutlet weak var productIdentifierLabel: UILabel!
    
    @IBOutlet weak var productImageActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var productImageView: UIImageView!
    
    var tapGestureRecognizer: UITapGestureRecognizer?
}

