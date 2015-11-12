//
//  Model.swift
//  CoreCatalog
//
//  Created by Alsey Coleman Miller on 11/11/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import CoreModel

public struct Model {
    
    public static let entities: CoreModel.Model = {
       
        var model = CoreModel.Model()
        
        model[Store.entityName]     = Store.entity
        model[Image.entityName]     = Image.entity
        model[Listing.entityName]   = Listing.entity
        model[Product.entityName]   = Product.entity
        
        return model
    }()
}

// MARK: - Store

public extension Model {
    
    public struct Store {
        
        public static let entityName = "Store"
        
        public static let entity: Entity = {
           
            var entity = Entity()
            
            entity.attributes[Attribute.Name.name]              = Attribute.Name.property
            entity.attributes[Attribute.Text.name]              = Attribute.Text.property
            entity.attributes[Attribute.PhoneNumber.name]       = Attribute.PhoneNumber.property
            entity.attributes[Attribute.Country.name]           = Attribute.Country.property
            entity.attributes[Attribute.State.name]             = Attribute.State.property
            entity.attributes[Attribute.City.name]              = Attribute.City.property
            entity.attributes[Attribute.District.name]          = Attribute.District.property
            entity.attributes[Attribute.Street.name]            = Attribute.Street.property
            entity.attributes[Attribute.OfficeNumber.name]      = Attribute.OfficeNumber.property
            entity.attributes[Attribute.DirectionsNote.name]    = Attribute.DirectionsNote.property
            entity.attributes[Attribute.Email.name]             = Attribute.Email.property
            entity.attributes[Attribute.Password.name]          = Attribute.Password.property
            
            entity.relationships[Relationship.Image.name]       = Relationship.Image.property
            entity.relationships[Relationship.Listings.name]    = Relationship.Listings.property
            
            return entity
        }()
        
        public struct Attribute {
            
            public static let Name = (name: "name", property: CoreModel.Attribute(type: .String))
            
            public static let Text = (name: "text", property: CoreModel.Attribute(type: .String))
            
            public static let PhoneNumber = (name: "phoneNumber", property: CoreModel.Attribute(type: .String))
            
            public static let Country = (name: "country", property: CoreModel.Attribute(type: .String))
            
            public static let State = (name: "state", property: CoreModel.Attribute(type: .String))
            
            public static let City = (name: "city", property: CoreModel.Attribute(type: .String))
            
            public static let District = (name: "district", property: CoreModel.Attribute(type: .String))
            
            public static let Street = (name: "street", property: CoreModel.Attribute(type: .String))
            
            public static let OfficeNumber = (name: "officeNumber", property: CoreModel.Attribute(type: .String))
            
            public static let DirectionsNote = (name: "directionsNote", property: CoreModel.Attribute(type: .String))
            
            public static let Email = (name: "email", property: CoreModel.Attribute(type: .String))
            
            public static let Password = (name: "password", property: CoreModel.Attribute(type: .String))
        }
        
        public struct Relationship {
            
            public static let Image: (name: String, property: CoreModel.Relationship) = {
                
                let property = CoreModel.Relationship(type: RelationshipType.ToOne,
                    destinationEntityName: Model.Image.entityName,
                    inverseRelationshipName: "store")
                
                return (name: "image", property: property)
            }()
            
            public static let Listings: (name: String, property: CoreModel.Relationship) = {
                
                let property = CoreModel.Relationship(type: RelationshipType.ToMany,
                    destinationEntityName: Model.Listing.entityName,
                    inverseRelationshipName: "store")
                
                return (name: "listings", property: property)
            }()
        }
    }
}

// MARK: - Image

public extension Model {
    
    public struct Image {
        
        public static let entityName = "Image"
        
        public static let entity: Entity = {
            
            var entity = Entity()
            
            entity.attributes[Attribute.Data.name]              = Attribute.Data.property
            
            entity.relationships[Relationship.Product.name]     = Relationship.Product.property
            entity.relationships[Relationship.Store.name]       = Relationship.Store.property
            
            return entity
        }()
        
        public struct Attribute {
            
            public static let Data = (name: "data", property: CoreModel.Attribute(type: .Data))
        }
        
        public struct Relationship {
            
            public static let Product: (name: String, property: CoreModel.Relationship) = {
                
                let property = CoreModel.Relationship(type: RelationshipType.ToOne,
                    destinationEntityName: Model.Product.entityName,
                    inverseRelationshipName: "image")
                
                return (name: "product", property: property)
            }()
            
            public static let Store: (name: String, property: CoreModel.Relationship) = {
                
                let property = CoreModel.Relationship(type: RelationshipType.ToOne,
                    destinationEntityName: Model.Store.entityName,
                    inverseRelationshipName: "image")
                
                return (name: "store", property: property)
            }()
        }
    }
}

// MARK: - Listing

public extension Model {
    
    public struct Listing {
        
        public static let entityName = "Listing"
        
        public static let entity: Entity = {
            
            var entity = Entity()
            
            entity.attributes[Attribute.Currency.name]          = Attribute.Currency.property
            entity.attributes[Attribute.Price.name]             = Attribute.Price.property
            
            entity.relationships[Relationship.Product.name]     = Relationship.Product.property
            entity.relationships[Relationship.Store.name]       = Relationship.Store.property
            
            return entity
            
        }()
        
        public struct Attribute {
            
            public static let Currency = (name: "currency", property: CoreModel.Attribute(type: .String))
            
            public static let Price = (name: "price", property: CoreModel.Attribute(type: .Number(.Double)))
        }
        
        public struct Relationship {
            
            public static let Product: (name: String, property: CoreModel.Relationship) = {
                
                let property = CoreModel.Relationship(type: RelationshipType.ToOne,
                    destinationEntityName: Model.Product.entityName,
                    inverseRelationshipName: "listings")
                
                return (name: "product", property: property)
            }()
            
            public static let Store: (name: String, property: CoreModel.Relationship) = {
                
                let property = CoreModel.Relationship(type: RelationshipType.ToOne,
                    destinationEntityName: Model.Store.entityName,
                    inverseRelationshipName: "listings")
                
                return (name: "store", property: property)
            }()
        }
    }
}

// MARK: - Product

public extension Model {
    
    public struct Product {
        
        public static let entityName = "Product"
        
        public static let entity: Entity = {
            
            var entity = Entity()
            
            entity.attributes[Attribute.Name.name]              = Attribute.Name.property
            entity.attributes[Attribute.ProductIdentifier.name] = Attribute.ProductIdentifier.property
            
            entity.relationships[Relationship.Image.name]       = Relationship.Image.property
            entity.relationships[Relationship.Listings.name]    = Relationship.Listings.property
            
            return entity
        }()
        
        public struct Attribute {
            
            public static let Name = (name: "name", property: CoreModel.Attribute(type: .String))
            
            public static let ProductIdentifier = (name: "productIdentifier", property: CoreModel.Attribute(type: .String))
        }
        
        public struct Relationship {
            
            public static let Image: (name: String, property: CoreModel.Relationship) = {
                
                let property = CoreModel.Relationship(type: RelationshipType.ToOne,
                    destinationEntityName: Model.Image.entityName,
                    inverseRelationshipName: "product")
                
                return (name: "image", property: property)
            }()
            
            public static let Listings: (name: String, property: CoreModel.Relationship) = {
                
                let property = CoreModel.Relationship(type: RelationshipType.ToMany,
                    destinationEntityName: Model.Listing.entityName,
                    inverseRelationshipName: "product")
                
                return (name: "listings", property: property)
            }()
        }
    }
}




