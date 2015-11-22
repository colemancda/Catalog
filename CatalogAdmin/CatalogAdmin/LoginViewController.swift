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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidDisappear(true)
        
        CloudKitStore.sharedStore.cloudDatabase .fetchUserRecordIDWithCompletionHandler { (<#CKRecordID?#>, <#NSError?#>) -> Void in
            
            
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        
        
    }
    
}