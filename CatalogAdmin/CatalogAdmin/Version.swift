//
//  Version.swift
//  Vistage
//
//  Created by Alsey Coleman Miller on 10/22/15.
//  Copyright © 2015 Vistage. All rights reserved.
//

import Foundation

/** Version of the app. */
public let AppVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String

/** Build of the app. */
public let AppBuild = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String