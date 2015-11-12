//
//  File.swift
//  CoreCatalogServer
//
//  Created by Alsey Coleman Miller on 11/12/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation

public let ServerApplicationSupportFolderURL: NSURL = {
    
    let folderURL = try! NSFileManager.defaultManager().URLForDirectory(.ApplicationSupportDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false).URLByAppendingPathComponent("CatalogServer")
    
    let fileExists = NSFileManager.defaultManager().fileExistsAtPath(folderURL.path!, isDirectory: nil)
    
    if fileExists == false {
        
        // create directory
        try! NSFileManager.defaultManager().createDirectoryAtURL(folderURL, withIntermediateDirectories: true, attributes: nil)
    }
    
    return folderURL
}()

public let ServerSQLiteFileURL = ServerApplicationSupportFolderURL.URLByAppendingPathComponent("data.sqlite")