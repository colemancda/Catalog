//
//  ServerManager.swift
//  CoreCerraduraServer
//
//  Created by Alsey Coleman Miller on 9/20/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import SwiftFoundation
import CoreModel
import NetworkObjects
import CoreCatalog

public final class ServerManager: ServerDataSource, ServerDelegate {
    
    public static let sharedManager = ServerManager()
    
    // MARK: - Properties
    
    public lazy var server: NetworkObjects.Server.HTTP = NetworkObjects.Server.HTTP(model: Model.entities, dataSource: self, delegate: self)
    
    // MARK: - ServerDataSource
    
    public func server<T : ServerType>(server: T, storeForRequest request: RequestMessage) -> CoreModel.Store {
        
        return StoreForRequest(request)
    }
    
    public func server<T : ServerType>(server: T, newResourceIDForEntity entity: String) -> String {
        
        return NewResourceID(entity)
    }
    
    public func server<T : ServerType>(server: T, functionsForEntity entity: String) -> [String] {
        
        return []
    }
    
    public func server<T : ServerType>(server: T, performFunction functionName: String, forResource resource: Resource, recievedJSON: JSONObject?, context: Server.RequestContext) -> (Int, JSONObject?) {
        
        return (HTTP.StatusCode.OK.rawValue, nil)
    }
    
    // MARK: - ServerDelegate
    
    public func server<T : ServerType>(server: T, statusCodeForRequest context: Server.RequestContext) -> Int  {
        
        // get user authentication
        
        if let _ = context.requestMessage.metadata[RequestHeader.Authorization.rawValue] {
            
            let authenticatedUser: Resource
            
            do {
                guard let resource = try AuthenticateWithHeader(RequestHeader.Authorization.rawValue, identifierHeader: RequestHeader.Store.rawValue,
                    identifierKey: Model.Store.Attribute.Username.name,
                    secretKey: Model.Password.Attribute.Password.name,
                    entityName: Model.Store.entityName,
                    context: context)
                    
                else { return HTTP.StatusCode.Unauthorized.rawValue }
                
                authenticatedUser = resource
            }
            
            catch {
                
                self.server(self.server, didEncounterInternalError: error, context: context)
                
                return HTTP.StatusCode.InternalServerError.rawValue
            }
            
            // set in user info
            context.userInfo[ServerUserInfoKey.AuthenticatedUser.rawValue] = authenticatedUser
        }
        
        // check if authentication is required
        
        let statusCode: Int
        
        do {
            
            switch context.requestMessage.request {
                
            case let .Get(resource):
                
                let serverModelType = ServerModelForEntity(resource.entityName)
                
                statusCode = try serverModelType.canGet(resource.resourceID, context: context)
                
            case let .Delete(resource):
                
                let serverModelType = ServerModelForEntity(resource.entityName)
                
                statusCode = try serverModelType.canDelete(resource.resourceID, context: context)
                
            case let .Edit(resource, changes):
                
                let serverModelType = ServerModelForEntity(resource.entityName)
                
                statusCode = try serverModelType.canEdit(changes, resourceID: resource.resourceID, context: context)
                
            case let .Create(entityName, initialValues):
                
                let serverModelType = ServerModelForEntity(entityName)
                
                statusCode = try serverModelType.canCreate(initialValues ?? ValuesObject(), context: context)
                
            case let .Search(fetchRequest):
                
                let serverModelType = ServerModelForEntity(fetchRequest.entityName)
                
                statusCode = try serverModelType.canPerformFetchRequest(fetchRequest, context: context)
                
            case .Function(_):
                
                return HTTP.StatusCode.OK.rawValue
            }
        }
        
        catch {
            
            self.server(self.server, didEncounterInternalError: error, context: context)
            
            return HTTP.StatusCode.InternalServerError.rawValue
        }
        
        return statusCode
    }
    
    public func server<T : ServerType>(server: T, willCreateResource resource: Resource, initialValues: ValuesObject, context: Server.RequestContext) -> ValuesObject {
        
        return initialValues
    }
    
    public func server<T : ServerType>(server: T, willPerformRequest context: Server.RequestContext, var withResponse responseMessage: ResponseMessage) -> ResponseMessage {
        
        // log
    }
    
    public func server<T : ServerType>(server: T, didEncounterInternalError error: ErrorType, context: Server.RequestContext) {
        
        print("Internal Server Error: \(error)")
    }
}


// MARK: - Supporting Types

public enum ServerUserInfoKey: String {
    
    case AuthenticatedUser
}

