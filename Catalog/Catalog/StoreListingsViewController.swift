//
//  StoreListingsViewController.swift
//  Catalog
//
//  Created by Alsey Coleman Miller on 11/15/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import CoreCatalog
import JGProgressHUD
import JTSImage

final class StoreListingsViewController: UITableViewController, UISearchBarDelegate {
    
    // MARK: - IB Outlets
    
    // MARK: - Properties
    
    var store: Identifier!
    
    private(set) var results = [Listing]()
    
    // MARK: Views
    
    let progressHUD = JGProgressHUD(style: .Dark)
    
    // MARK: - Private Properties
    
    private lazy var loadImageOperationQueue: NSOperationQueue = {
        
        let queue = NSOperationQueue()
        
        queue.name = "\(self) Load Image Queue"
        
        return queue
    }()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard store != nil else { fatalError("Store ID must be set") }
        
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
        
        let predicate = NSPredicate(format: "%K == %@", Listing.CloudKitField.store.rawValue, store.toRecordID())
        
        let query = CKQuery(recordType: Listing.recordType, predicate: predicate)
        
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
                
                // refresh UI
                controller.tableView.reloadData()
            }
        }
    }
    
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
    
    func configureCell(cell: ListingProductCell, atIndexPath indexPath: NSIndexPath) {
        
        let results = self.results
        
        let listing = results[indexPath.row]
        
        cell.listingPriceLabel.text = listing.priceString
        
        cell.productNameLabel.text = LocalizedText.Loading.localizedString
        
        cell.productIdentifierLabel.text = ""
        
        cell.userInteractionEnabled = false
        
        cell.productImageActivityIndicator.hidden = false
        
        cell.productImageActivityIndicator.startAnimating()
        
        cell.productImageView.image = nil
        
        cell.tapGestureRecognizer = nil
        
        // load product
        
        CKContainer.defaultContainer().publicCloudDatabase.fetchRecordWithID(listing.product.toRecordID()) { (record, error) in
            
            NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                
                guard let controller = self where controller.results == results  else { return }
                
                // enable cell
                cell.userInteractionEnabled = true
                
                guard error == nil, let record = record, let product = Product(record: record) else {
                    
                    print("Couldn't load store. (\(error))")
                    
                    cell.productNameLabel.text = LocalizedText.Error.localizedString
                    
                    cell.productIdentifierLabel.text = ""
                    
                    return
                }
                
                // configure cell
                
                cell.productNameLabel.text = product.name
                
                cell.productIdentifierLabel.text = product.identifier.value
                
                // load image
                
                if let imageIdentifier = product.image {
                    
                    cell.productImageActivityIndicator.hidden = false
                    
                    cell.productImageActivityIndicator.startAnimating()
                    
                    cell.productImageView.image = nil
                    
                    cell.tapGestureRecognizer = nil
                    
                    CKContainer.defaultContainer().publicCloudDatabase.fetchRecordWithID(imageIdentifier.toRecordID(), completionHandler: { (record, error) in
                        
                        NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                            
                            guard let controller = self where controller.results == results  else { return }
                            
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
                                    
                                    guard let controller = self where controller.results == results  else { return }
                                    
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.listingProductCell, forIndexPath: indexPath)!
        
        self.configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
}

// MARK: - Supporting Types

final class ListingProductCell: UITableViewCell {
    
    @IBOutlet weak var listingPriceLabel: UILabel!
    
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBOutlet weak var productIdentifierLabel: UILabel!
    
    @IBOutlet weak var productImageActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var productImageView: UIImageView!
    
    var tapGestureRecognizer: UITapGestureRecognizer?
}
