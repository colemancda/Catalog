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
import JTSImage

final class StoresViewController: UITableViewController {
    
    // MARK: - Properties
    
    private(set) var stores = [Store]()
    
    private(set) var didSearch = false
    
    // MARK: Views
    
    lazy var emptySearchView: EmptyView = {
        
        let emptyView = EmptyView.fromNib()
        
        emptyView.label.text = LocalizedText.EmptyStoreSearch.localizedString
        
        emptyView.emptyImageView.image = R.image.emptySearch!
        
        return emptyView
    }()
    
    lazy var emptyResultsView: EmptyView = {
        
        let emptyView = EmptyView.fromNib()
        
        emptyView.label.text = LocalizedText.EmptyStoreResult.localizedString
        
        emptyView.emptyImageView.image = R.image.emptyStores!
        
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
    
    func configureCell(cell: StoreCell, atIndexPath indexPath: NSIndexPath) {
        
        let stores = self.stores
        
        let store = stores[indexPath.row]
        
        cell.storeNameLabel.text = store.name
        
        var addressText = store.street + ", " + store.district + ", " + store.city
        
        if let storeNumber = store.officeNumber {
            
            addressText += " - " + LocalizedText.Store.localizedString + " " + storeNumber
        }
        
        cell.storeAddressLabel.text = addressText
        
        if let imageIdentifier = store.image {
            
            cell.storeImageActivityIndicator.hidden = false
            
            cell.storeImageActivityIndicator.startAnimating()
            
            cell.storeImageView.image = nil
            
            cell.tapGestureRecognizer = nil
            
            // load image
            
            CKContainer.defaultContainer().publicCloudDatabase.fetchRecordWithID(imageIdentifier.toRecordID(), completionHandler: { (record, error) in
                
                NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                    
                    guard let controller = self where controller.stores == stores  else { return }
                    
                    guard error == nil else {
                        
                        print("Couldn't load store image. (\(error))")
                        
                        cell.storeImageActivityIndicator.stopAnimating()
                        
                        cell.storeImageActivityIndicator.hidden = true
                        
                        cell.storeImageView.image = R.image.storeImage!
                        
                        return
                    }
                    
                    controller.loadImageOperationQueue.addOperationWithBlock { [weak self] in
                        
                        guard let catalogImage = Image(record: record!) else { fatalError("Could not parse") }
                        
                        let image = UIImage(data: NSData(bytes: catalogImage.data))!
                        
                        NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                            
                            guard let controller = self where controller.stores == stores  else { return }
                            
                            cell.storeImageView.image = image
                            
                            cell.storeImageActivityIndicator.stopAnimating()
                            
                            cell.storeImageActivityIndicator.hidden = true
                            
                            // setup tap gesture
                            if cell.tapGestureRecognizer == nil {
                                
                                cell.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "imageTapped:")
                                
                                cell.storeImageView.addGestureRecognizer(cell.tapGestureRecognizer!)
                            }
                        }
                    }
                }
            })
        }
        else {
            
            cell.storeImageActivityIndicator.stopAnimating()
            
            cell.storeImageActivityIndicator.hidden = true
            
            cell.storeImageView.image = R.image.productPlaceholder!
            
            cell.tapGestureRecognizer = nil
        }
    }
    
    func updateEmptyView() {
        
        // empty results view
        if stores.count == 0 {
            
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
        
        return stores.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.storeCell, forIndexPath: indexPath)!
        
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
        
        let predicate = NSPredicate(format: "%K BEGINSWITH %@", Store.CloudKitField.name.rawValue, text)
        
        let query = CKQuery(recordType: Store.recordType, predicate: predicate)
        
        let sort = NSSortDescriptor(key: Store.CloudKitField.name.rawValue, ascending: true)
        
        query.sortDescriptors = [sort]
        
        CKContainer.defaultContainer().publicCloudDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            
            NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                
                guard let controller = self else { return }
                
                progressHUD.dismiss()
                
                guard error == nil else {
                    
                    controller.showErrorAlert((error! as NSError).localizedDescription)
                    
                    return
                }
                
                guard let stores = Store.fromCloudKit(results!) else {
                    
                    controller.showErrorAlert(LocalizedText.InvalidServerResponse.localizedString)
                    
                    return
                }
                
                controller.stores = stores
                
                controller.tableView.reloadData()
                
                controller.updateEmptyView()
            }
        }
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
            
        case R.segue.showStore:
            
            let store = self.stores[self.tableView.indexPathForSelectedRow!.row]
            
            let destinationVC = segue.destinationViewController as! StoreViewController
            
            destinationVC.store = store
            
        default: fatalError("Unknown Segue: \(segue.identifier)")
        }
    }
}

// MARK: - Supporting Types

final class StoreCell: UITableViewCell {
    
    @IBOutlet weak var storeNameLabel: UILabel!
    
    @IBOutlet weak var storeAddressLabel: UILabel!
    
    @IBOutlet weak var storeImageActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var storeImageView: UIImageView!
    
    var tapGestureRecognizer: UITapGestureRecognizer?
}
