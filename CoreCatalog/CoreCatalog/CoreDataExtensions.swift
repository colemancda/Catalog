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
    
    func findOrCreateEntity<T: NSManagedObject>(entity: NSEntityDescription, withResourceID resourceID: String) throws -> T {
        
        // get cached resource...
        
        let fetchRequest = NSFetchRequest(entityName: entity.name!)
        
        fetchRequest.fetchLimit = 1
        
        fetchRequest.includesSubentities = false
        
        // create predicate
        
        fetchRequest.predicate = NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: CoreDataResourceIDAttributeName), rightExpression: NSExpression(forConstantValue: resourceID), modifier: NSComparisonPredicateModifier.DirectPredicateModifier, type: NSPredicateOperatorType.EqualToPredicateOperatorType, options: NSComparisonPredicateOptions.NormalizedPredicateOption)
        
        fetchRequest.returnsObjectsAsFaults = false
        
        // fetch
        
        let results = try self.executeFetchRequest(fetchRequest) as! [T]
        
        let resource: T
        
        if let firstResult = results.first {
            
            resource = firstResult
        }
            
        // create cached resource if not found
        else {
            
            // create a new entity
            let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: self)
            
            // set resource ID
            (newManagedObject).setValue(resourceID, forKey: CoreDataResourceIDAttributeName)
            
            resource = newManagedObject as! T
        }
        
        return resource
    }
}

internal extension NSManagedObject {
    
    /// Wraps primitive accessor. 
    func getValue<T: AnyObject>(key: String) -> T? {
        
        self.willAccessValueForKey(key)
        let value = self.primitiveValueForKey(key) as? T
        self.didAccessValueForKey(key)
        
        return value
    }
    
    /// Get an array from a to-many relationship.
    func arrayValueForToManyRelationship(relationship key: String) -> [NSManagedObject]? {
        
        // assert relationship exists
        assert(self.entity.relationshipsByName[key] != nil, "Relationship \(key) doesnt exist on \(self.entity.name)")
        
        // get relationship
        let relationship = self.entity.relationshipsByName[key]!
        
        // assert that relationship is to-many
        assert(relationship.toMany, "Relationship \(key) on \(self.entity.name) is not to-many")
        
        let value: AnyObject? = self.valueForKey(key)
        
        if value == nil {
            
            return nil
        }
        
        // ordered set
        if relationship.ordered {
            
            let orderedSet = value as! NSOrderedSet
            
            return orderedSet.array as? [NSManagedObject]
        }
        
        // set
        let set = value as! NSSet
        
        return set.allObjects as? [NSManagedObject]
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
}




