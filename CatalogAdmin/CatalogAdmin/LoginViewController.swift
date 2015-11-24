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
final class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    var userID: CKRecordID?
    
    let progressHUD = JGProgressHUD(style: .Dark)
    
    // MARK: - Loading
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidDisappear(true)
        
        self.fetchUser()
    }

    // MARK: - Private Methods
    
    private func fetchUser() {
        
        // show HUD
        progressHUD.showInView(self.view)
        
        progressHUD.minimumDisplayTime = 2.0
        
        CloudKitContainer.fetchUserRecordIDWithCompletionHandler { [weak self] (recordID, error) in
                        
            MainQueue {
                
                guard let controller = self else { return }
             
                // error
                guard error == nil else {
                    
                    controller.progressHUD.dismissAnimated(false)
                    
                    let localizedText = error!.localizedDescription
                    
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"),
                        message: localizedText,
                        preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Retry", comment: "Retry"), style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                        
                        controller.fetchUser()
                        
                        alert.dismissViewControllerAnimated(true, completion: nil)
                    }))
                    
                    controller.presentViewController(alert, animated: true, completion: nil)
                    
                    return
                }
                
                controller.progressHUD.dismiss()
                
                controller.userID = recordID
                
                // segue
                controller.performSegueWithIdentifier(R.segue.login, sender: self)
            }
        }
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
            
        case R.segue.login:
            
            let navigationController = segue.destinationViewController as! UINavigationController
            
            let destinationVC = navigationController.topViewController as! StoresViewController
            
            destinationVC.userID = self.userID!
            
        default: return
        }
    }
}

