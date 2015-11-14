//
//  EmptyView.swift
//  Catalog
//
//  Created by Alsey Coleman Miller on 11/14/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import Foundation
import UIKit

final class EmptyView: UIView {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var emptyImageView: UIImageView!
    
    // MARK: - Initialization
    
    static func fromNib() -> EmptyView {
        
        return UINib(nibName: "EmptyView", bundle: nil).instantiateWithOwner(nil, options: nil).first! as! EmptyView
    }
}