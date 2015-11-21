//
//  NewStoreViewController.swift
//  CatalogAdmin
//
//  Created by Alsey Coleman Miller on 11/20/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import Foundation
import UIKit
import CoreCatalog
import CloudKit
import CloudKitStore
import JGProgressHUD

final class NewStoreViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var countryTextField: UITextField!
    
    @IBOutlet weak var stateTextField: UITextField!
    
    @IBOutlet weak var cityTextField: UITextField!
    
    @IBOutlet weak var districtTextField: UITextField!
    
    @IBOutlet weak var streetTextField: UITextField!
    
    @IBOutlet weak var officeNumberTextField: UITextField!
    
    @IBOutlet weak var directionsNoteTextField: UITextField!
    
    @IBOutlet weak var imageTableViewCell: UITableViewCell!
    
    @IBOutlet weak var locationTableViewCell: UITableViewCell!
    
    // MARK: - Properties
    
    let progressHUD = JGProgressHUD(style: .Dark)
    
    private(set) var storeImageData: NSData?
    
    private(set) var location: Location?
    
    // MARK: - Actions
    
    @IBAction func cancel(sender: AnyObject? = nil) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func done(sender: AnyObject? = nil) {
        
        // validate and collect values
        guard let values = self.validate() else { return }
        
        // show HUD
        progressHUD.showInView(self.navigationController!.view!)
        
        progressHUD.interactionType = .BlockTouchesOnHUDView
        
        tableView.scrollEnabled = false
        
        // create store
        CloudKitStore.sharedStore.create(Store.recordType, values: values) { [weak self] (response: ErrorValue<Store>) -> () in
            
            MainQueue {
                
                guard let controller = self else { return }
                
                controller.tableView.scrollEnabled = true
                
                switch response {
                    
                case let .Error(error):
                    
                    controller.progressHUD.dismissAnimated(false)
                    
                    controller.showErrorAlert(ErrorText(error))
                    
                case .Value(_):
                    
                    controller.progressHUD.dismiss()
                    
                    controller.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func setImage(sender: AnyObject? = nil) {
        
        let pickerController = UIImagePickerController()
        
        pickerController.delegate = self
        
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        
        if cell == imageTableViewCell {
            
            self.setImage()
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage ??
            info[UIImagePickerControllerOriginalImage] as? UIImage
            else { fatalError("No Image selected?") }
        
        let compressedImageData = UIImageJPEGRepresentation(image, 0.3)
        
        self.storeImageData = compressedImageData
        
        self.imageTableViewCell.accessoryType = .Checkmark
        
        self.imageTableViewCell.detailTextLabel?.text = ""
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    private func validate() -> [String: CKRecordValue]? {
        
        var values = [String: CKRecordValue]()
        
        guard let name = nameTextField.text where Store.Validate.name(name),
            let description = descriptionTextField.text where Store.Validate.text(description),
            let phoneNumber = phoneNumberTextField.text where Store.Validate.phoneNumber(phoneNumber),
            let email = emailTextField.text where Store.Validate.email(email),
            let country = countryTextField.text where country != "",
            let state = stateTextField.text where state != "",
            let city = cityTextField.text where city != "",
            let district = districtTextField.text where district != "",
            let street = streetTextField.text where street != "",
            let directionsNote = directionsNoteTextField.text where directionsNote != ""
            else { showErrorAlert(LocalizedText.InvalidValues.localizedString); return nil }
        
        values[Store.CloudKitField.name.rawValue] = name
        values[Store.CloudKitField.text.rawValue] = description
        values[Store.CloudKitField.phoneNumber.rawValue] = phoneNumber
        values[Store.CloudKitField.country.rawValue] = country
        values[Store.CloudKitField.state.rawValue] = state
        values[Store.CloudKitField.district.rawValue] = district
        values[Store.CloudKitField.street.rawValue] = street
        values[Store.CloudKitField.directionsNote.rawValue] = directionsNote
        
        if let officeNumber = officeNumberTextField.text where officeNumber != "" {
            
            values[Store.CloudKitField.officeNumber.rawValue] = officeNumber
        }
        
        guard let imageData = self.storeImageData else { showErrorAlert(LocalizedText.ImageRequired.localizedString); return nil }
        
        values[Store.CloudKitField.image.rawValue] = imageData
        
        // TODO: Add location
        
        return values
    }
}