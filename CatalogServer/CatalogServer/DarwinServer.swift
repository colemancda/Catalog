//
//  DarwinServer.swift
//  CoreCerraduraServer
//
//  Created by Alsey Coleman Miller on 11/12/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import Foundation
import SwiftFoundation
import CoreModel
import CoreData
import NetworkObjects
import CoreCatalog
import RoutingHTTPServer

/*
@objc public final class Server: NSObject {
    
    public static func startServer() {
        
        do { try HTTPServer.start() }
            
        catch { fatalError("Could not start HTTP Server: \(error)") }
        
        print("Started server on port \(HTTPServer.port())")
    }
}*/

public func StoreForRequest(request: RequestMessage) -> CoreModel.Store {
    
    // create a new managed object context
    let managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    
    managedObjectContext.undoManager = nil
    
    // setup persistent store coordinator
    managedObjectContext.persistentStoreCoordinator = PersistentStoreCoordinator
    
    guard let store = CoreDataStore(model: Model.entities, managedObjectContext: managedObjectContext, resourceIDAttributeName: CoreDataResourceIDAttributeName)
        else { fatalError("Could not create Store for request: \(request)") }
    
    return store
}

public let PersistentStoreCoordinator: NSPersistentStoreCoordinator = {
    
    let managedObjectModel = ManagedObjectModel()
    
    // add resource ID attribute
    managedObjectModel.addResourceIDAttribute(CoreDataResourceIDAttributeName)
    
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    
    do { try persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: ServerSQLiteFileURL, options: nil) }
        
    catch { fatalError("Could not create NSPersistentStoreCoordinator: \(error)") }
    
    return persistentStoreCoordinator
    }()

public let HTTPServer: RoutingHTTPServer = {
    
    let HTTPServer = RoutingHTTPServer()
    
    HTTPServer.setPort(UInt16(8080))
    
    let handler = { (routeRequest: RouteRequest!, routeResponse: RouteResponse!) -> Void in
        
        // create request
        var httpRequest = Server.HTTP.Request()
        
        httpRequest.headers = routeRequest.headers as! [String: String]
        
        httpRequest.URI = routeRequest.url().relativeString!
        
        httpRequest.method = SwiftFoundation.HTTP.Method(rawValue: routeRequest.method())!
        
        // add body
        if let jsonString = NSString(data: routeRequest.body(), encoding: NSUTF8StringEncoding),
            let jsonValue = JSON.Value(string: jsonString as String),
            let jsonObject = jsonValue.objectValue {
                
                httpRequest.body = jsonObject
        }
        
        // process request
        let httpResponse = ServerManager.sharedManager.server.input(httpRequest)
        
        routeResponse.statusCode = httpResponse.statusCode
        
        for (header, value) in httpResponse.headers {
            
            routeResponse.setHeader(header, value: value)
        }
        
        if httpResponse.body.count > 0 {
            
            routeResponse.respondWithData(NSData(bytes: httpResponse.body))
        }
    }
    
    // add handlers
    
    let instancePathExpression = "/:entity/:id"
    
    HTTPServer.get(instancePathExpression, withBlock: handler)
    
    HTTPServer.put(instancePathExpression, withBlock: handler)
    
    HTTPServer.delete(instancePathExpression, withBlock: handler)
    
    // create handler
    
    HTTPServer.post("/:entity", withBlock: handler)
    
    // search handler
    
    HTTPServer.post("/search/:entity", withBlock: handler)
    
    // function handler
    
    HTTPServer.post("/:entity/:id/:function", withBlock: handler)
    
    return HTTPServer
}()

