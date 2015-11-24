//
//  LoginViewController.swift
//  CatalogAdmin
//
//  Created by Alsey Coleman Miller on 11/22/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import Foundation
import UIKit
import CoreCatalog
import CloudKit
import CloudKitStore
import JGProgressHUD

/// View Controller for displaying the Stores.
final class LoginViewController: UITableViewController {
    
    // MARK: - Properties
    
    var userID: CKRecordID?
    
    // MARK: - Loading
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidDisappear(true)
        
        self.fetchUser()
    }

    // MARK: - Private Methods
    
    private func fetchUser() {
        
        CloudKitContainer.fetchUserRecordIDWithCompletionHandler { (recordID, error) -> Void in
            
            MainQueue {
             
                // error
                guard error == nil else {
                    
                    let localizedText = error!.localizedDescription
                    
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"),
                        message: localizedText,
                        preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Retry", comment: "Retry"), style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                        
                        self.fetchUser()
                        
                        alert.dismissViewControllerAnimated(true, completion: nil)
                    }))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    return
                }
                
                self.userID = recordID
                
                // segue
                self.performSegueWithIdentifier(R.segue.login, sender: self)
            }
        }
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
            
        case R.segue.login:
            
            let destinationVC = segue.destinationViewController as! StoresViewController
            
            destinationVC.userID = self.userID!.recordName
            
        default: return
        }
    }
}

