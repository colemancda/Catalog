//
//  StoreViewController.swift
//  Catalog
//
//  Created by Alsey Coleman Miller on 11/15/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CloudKit
import CoreCatalog
import SwiftFoundation
import MessageUI
import JGProgressHUD
import CoreLocation

final class StoreViewController: UITableViewController, MFMailComposeViewControllerDelegate, CLLocationManagerDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var storeImageView: UIImageView!
    
    @IBOutlet weak var descriptionCell: UITableViewCell!
    
    @IBOutlet weak var phoneNumberCell: StoreFieldCell!
    
    @IBOutlet weak var emailCell: StoreFieldCell!
    
    @IBOutlet weak var addressCell: StoreFieldCell!
    
    @IBOutlet weak var directionsNoteCell: StoreFieldCell!
    
    // MARK: - Properties
    
    var didLoad = false
    
    var store: Store! {
        
        didSet {
            
            if self.isViewLoaded() {
                
                self.configureUI()
            }
        }
    }
    
    var mapRegionSpan = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
    
    // MARK: - Private Properties
    
    private lazy var geocoder = CLGeocoder()
    
    private lazy var locationManager: CLLocationManager = {
       
        let locationManager = CLLocationManager()
        
        locationManager.delegate = self
    }()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard self.store != nil else { fatalError("Store must be set") }
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // setup UI
        self.configureUI()
        
        didLoad = true
    }
    
    // MARK: - Methods
    
    func configureUI() {
        
        let store = self.store
        
        self.navigationItem.title = store.name
        
        self.descriptionCell.textLabel!.text = store.text
        
        self.phoneNumberCell.fieldValueLabel.text = store.phoneNumber
        
        self.emailCell.fieldValueLabel.text = store.email
        
        self.directionsNoteCell.fieldValueLabel.text = store.directionsNote
        
        var addressText = ""
        
        if let storeNumber = store.officeNumber {
            
            addressText += LocalizedText.Store.localizedString + " \(storeNumber)" + "\n"
        }
        
        addressText += store.street + "\n"
        addressText += store.district + "\n"
        addressText += store.city + "\n"
        addressText += store.state + "\n"
        addressText += store.country + "\n"
        
        self.addressCell.fieldValueLabel.text = addressText
        
        if let coordinate = store.location?.toFoundation() {
            
            self.setMapCoordinate(coordinate)
        }
        else {
            
            let addressString = store.street + ", " + store.district + ", " + store.city + ", " + store.state + ", " + store.country
            
            self.geocoder.geocodeAddressString(addressString) { [weak self] (placemarks, error) in
                
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    
                    guard let controller = self else { return }
                    
                    guard error == nil else {
                        
                        controller.showErrorAlert((error! as NSError).localizedDescription)
                        
                        return
                    }
                    
                    let geocodedPlacemark = placemarks!.first
                    
                    let coordinate = geocodedPlacemark!.location!.coordinate
                    
                    controller.setMapCoordinate(coordinate)
                }
            }
        }
    }
    
    func setMapCoordinate(coordinate: CLLocationCoordinate2D) {
        
        let region = MKCoordinateRegion(center: coordinate, span: self.mapRegionSpan)
        
        self.mapView.setRegion(region, animated: didLoad)
    }
    
    func openPlacemarkInMaps(placemark: MKPlacemark) {
        
        let mapItem = MKMapItem(placemark: placemark)
        
        mapItem.name = store.name
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        
        let currentLocationMapItem = MKMapItem.mapItemForCurrentLocation()
        
        MKMapItem.openMapsWithItems([currentLocationMapItem, mapItem], launchOptions: launchOptions)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 62
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let store = self.store
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if cell === phoneNumberCell {
            
            let callURL = "tel://" + store.phoneNumber
            
            UIApplication.sharedApplication().openURL(NSURL(string: callURL)!)
        }
        
        else if cell === emailCell {
            
            if MFMailComposeViewController.canSendMail() {
                
                let composeVC = MFMailComposeViewController()
                
                composeVC.setToRecipients([store.email])
                
                composeVC.mailComposeDelegate = self
                
                self.presentViewController(composeVC, animated: true, completion: nil)
            }
            else {
                
                self.showErrorAlert(LocalizedText.SetupEmailErrorDescription.localizedString)
            }
        }
        
        else if cell === addressCell {
            
            if let coordinate = store.location?.toFoundation() {
                
                let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
                
                self.openPlacemarkInMaps(placemark)
            }
                
            // use geocoder
            else {
                
                let addressString = store.street + ", " + store.district + ", " + store.city + ", " + store.state + ", " + store.country
                
                let progressHUD = JGProgressHUD(style: .Dark)
                
                progressHUD.showInView(self.view)
                
                tableView.scrollEnabled = false
                
                self.geocoder.geocodeAddressString(addressString) { [weak self] (placemarks, error) in
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                     
                        guard let controller = self else { return }
                        
                        controller.tableView.scrollEnabled = true
                        
                        guard error == nil else {
                            
                            progressHUD.dismissAnimated(false)
                            
                            controller.showErrorAlert((error! as NSError).localizedDescription)
                            
                            return
                        }
                        
                        guard let geocodedPlacemark = placemarks!.first else {
                            
                            progressHUD.dismissAnimated(false)
                            
                            controller.showErrorAlert(LocalizedText.CouldNotOpenAddressWithMaps.localizedString)
                            
                            return
                        }
                        
                        progressHUD.dismiss()
                        
                        let placemark = MKPlacemark(coordinate: geocodedPlacemark.location!.coordinate, addressDictionary: geocodedPlacemark.addressDictionary as? [String: AnyObject])
                        
                        controller.openPlacemarkInMaps(placemark)
                    }
                }
            }
        }
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - Supporting Types

final class StoreFieldCell: UITableViewCell {
    
    @IBOutlet weak var fieldTitleLabel: UILabel!
    
    @IBOutlet weak var fieldValueLabel: UILabel!
}

