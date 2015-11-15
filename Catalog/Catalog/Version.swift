//
//  Version.swift
//  Catalog
//
//  Created by Alsey Coleman Miller on 11/14/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import Foundation

/** Version of the app. */
public let AppVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String

/** Build of the app. */
public let AppBuild = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String
