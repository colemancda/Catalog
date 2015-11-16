//
//  CoreDataExtensions.swift
//  CoreCatalog
//
//  Created by Alsey Coleman Miller on 11/11/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CoreData

internal extension NSManagedObjectContext {
    
    /// Wraps the block to allow for error throwing.
    @available(OSX 10.7, *)
    func performErrorBlockAndWait(block: () throws -> Void) throws {
        
        var blockError: ErrorType?
        
        self.performBlockAndWait {
            
            do { try block() }
            
            catch { blockError = error }
            
            return
        }
        
        if let error = blockError {
            
            throw error
        }
        
        return
    }
    
    func findOrCreateEntity(entityName: String, withResourceID resourceID: String) throws -> NSManagedObject {
        
        guard let foundEntity = try findEntity(entityName, withResourceID: resourceID) else {
            
            // create cached resource if not found... 
            
            // create a new entity
            let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: self)
            
            // set resource ID
            (newManagedObject).setValue(resourceID, forKey: CoreDataResourceIDAttributeName)
            
            return newManagedObject
        }
        
        return foundEntity
    }
    
    func findEntity(entityName: String, withResourceID resourceID: String) throws -> NSManagedObject? {
        
        // get entity
        guard let entity = self.persistentStoreCoordinator?.managedObjectModel.entitiesByName[entityName]
            else { fatalError("Unknown Entity: \(entityName)") }
        
        // get cached resource...
        
        let fetchRequest = NSFetchRequest(entityName: entity.name!)
        
        fetchRequest.fetchLimit = 1
        
        fetchRequest.includesSubentities = false
        
        // create predicate
        
        fetchRequest.predicate = NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: CoreDataResourceIDAttributeName), rightExpression: NSExpression(forConstantValue: resourceID), modifier: NSComparisonPredicateModifier.DirectPredicateModifier, type: NSPredicateOperatorType.EqualToPredicateOperatorType, options: NSComparisonPredicateOptions.NormalizedPredicateOption)
        
        fetchRequest.returnsObjectsAsFaults = false
        
        // fetch
        
        let results = try self.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        
        return results.first
    }
}

internal extension NSManagedObject {
    
    // Convenience Setters
    
    func set<T: RawRepresentable where T.RawValue: StringLiteralConvertible>(value: AnyObject?, _ rawKey: T) {
        
        let key = String(rawKey)
        
        self.setValue(value, forKey: key)
    }
    
    func setManagedObject<T: RawRepresentable where T.RawValue: StringLiteralConvertible>(entityName: String, _ identifier: String?, _ rawKey: T, _ context: NSManagedObjectContext) throws {
        
        let key = String(rawKey.rawValue)
        
        guard let identifier = identifier else {
            
            self.setValue(nil, forKey: key)
        }
        
        let managedObject = try context.findOrCreateEntity(entityName, withResourceID: identifier)
        
        self.setValue(managedObject, forKey: key)
    }
    
    subscript(key: String) -> AnyObject? {
        
        get { valueForKey(key) }
        
        set { setValue(newValue, forKey: key) }
    }
    
    func willCache() {
        
        self.setValue(true, forKey: CoreDataCachedAttributeName)
    }
    
    func getIdentifier<T: RawRepresentable where T.RawValue: StringLiteralConvertible>(rawKey: T) -> String? {
        
        let key = String(rawKey.rawValue)
        
        guard let destinationManagedObject = self[key] as? NSManagedObject
            else { return nil }
        
        guard let identifier = destinationManagedObject[CoreDataResourceIDAttributeName] as? String
            else { fatalError("Identifier nil on \(destinationManagedObject)") }
        
        return identifier
    }
    
    /// Wraps primitive accessor. 
    func getValue<Value: AnyObject, Key: RawRepresentable where Key.RawValue: StringLiteralConvertible>(rawKey: Key) -> Value? {
        
        let key = String(rawKey.rawValue)
        
        let value = self.valueForKey(key)
        
        return value as? Value
    }
    
    /// Get an array from a to-many relationship.
    func arrayValueForToManyRelationship(relationship key: String) -> [NSManagedObject] {
        
        // assert relationship exists
        assert(self.entity.relationshipsByName[key] != nil, "Relationship \(key) doesnt exist on \(self.entity.name)")
        
        // get relationship
        let relationship = self.entity.relationshipsByName[key]!
        
        // assert that relationship is to-many
        assert(relationship.toMany, "Relationship \(key) on \(self.entity.name) is not to-many")
        
        let value: AnyObject? = self.valueForKey(key)
        
        if value == nil {
            
            return []
        }
        
        // ordered set
        if relationship.ordered {
            
            let orderedSet = value as! NSOrderedSet
            
            return orderedSet.array as! [NSManagedObject]
        }
        
        // set
        let set = value as! NSSet
        
        return set.allObjects as! [NSManagedObject]
    }
    
    /// Wraps the ```-valueForKey:``` method in the context's queue.
    func valueForKey<T: AnyObject>(key: String, managedObjectContext: NSManagedObjectContext) -> T? {
        
        var value: AnyObject?
        
        managedObjectContext.performBlockAndWait { () -> Void in
            
            value = self.valueForKey(key)
        }
        
        guard value != nil else { return nil }
        
        guard let castedValue = value as? T
            else { fatalError("Could not cast value \(value) to \(T.self)") }
        
        return castedValue
    }
}

internal extension NSManagedObjectModel {
    
    /// Programatically adds a unique resource identifier attribute to each entity in the managed object model.
    func addResourceIDAttribute(resourceIDAttributeName: String) {
        
        // add a resourceID attribute to managed object model
        for (_, entity) in self.entitiesByName {
            
            if entity.superentity == nil {
                
                // create new (runtime) attribute
                let resourceIDAttribute = NSAttributeDescription()
                resourceIDAttribute.attributeType = NSAttributeType.StringAttributeType
                resourceIDAttribute.name = resourceIDAttributeName
                resourceIDAttribute.optional = false
                
                // add to entity
                entity.properties.append(resourceIDAttribute)
            }
        }
    }
    
    func addCachedAttribute(attributeName: String) {
        
        // add a resourceID attribute to managed object model
        for (_, entity) in self.entitiesByName {
            
            if entity.superentity == nil {
                
                // create new (runtime) attribute
                let resourceIDAttribute = NSAttributeDescription()
                resourceIDAttribute.attributeType = NSAttributeType.BooleanAttributeType
                resourceIDAttribute.name = attributeName
                resourceIDAttribute.optional = true
                
                // add to entity
                entity.properties.append(resourceIDAttribute)
            }
        }
    }
}


