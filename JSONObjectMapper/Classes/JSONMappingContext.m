#import "JSONAttributeConverter.h"
#import "JSONAttributeMapping.h"
#import "JSONEntityDescription.h"
#import "JSONMappingContext.h"
#import "JSONMappingModel.h"
#import "JSONObjectMapping.h"
#import "JSONRelationshipMapping.h"
#import "NSDictionary+JSONKeyPath.h"

#ifndef DEBUG
    #define NSLog(...)
#endif

@interface JSONObject ()

@property (nonatomic) NSMutableArray<JSONLink *> *mutableLinks;
@property (nonatomic) NSManagedObject *managedObject;

@end

@interface JSONBucket ()

@property (nonatomic, readonly) NSMutableDictionary<NSString *, JSONBucket *> *mutableChildBuckets;
@property (nonatomic, readonly) NSMutableArray<JSONObject *> *mutableObjects;

@end

@interface JSONMappingContext ()

@property (nonatomic) JSONBucket *rootBucket;
@property (nonatomic) NSMutableArray<JSONBucket *> *allBuckets;

@end

@implementation JSONLink

- (instancetype)initWithName:(NSString *)name
                sourceObject:(JSONObject *)sourceObject
           destinationBucket:(JSONBucket *)destinationBucket {
    if (self = [super init]) {
        _name = name;
        _sourceObject = sourceObject;
        _destinationBucket = destinationBucket;
    }
    return self;
}

@end

@implementation JSONObject

- (instancetype)initWithBucket:(JSONBucket *)bucket
                JSONDictionary:(NSDictionary<NSString *, id> *)JSONDictionary
               primaryKeyValue:(id)primaryKeyValue {
    if (self = [super init]) {
        _bucket = bucket;
        _JSONDictionary = JSONDictionary;
        _primaryKeyValue = primaryKeyValue;
        _mutableLinks = [NSMutableArray array];
    }
    return self;
}

- (NSArray<JSONLink *> *)links {
    return [self.mutableLinks copy];
}

- (void)addLinkWithName:(NSString *)name destinationBucket:(JSONBucket *)destinationBucket {
    JSONLink *link = [[JSONLink alloc] initWithName:name sourceObject:self destinationBucket:destinationBucket];
    [self.mutableLinks addObject:link];
}

@end

@implementation JSONBucket

- (instancetype)initWithEntity:(JSONEntityDescription *)entity
                       mapping:(JSONObjectMapping *)mapping {
    if (self = [super init]) {
        _entity = entity;
        _mapping = mapping;
        _mutableChildBuckets = [NSMutableDictionary dictionary];
        _mutableObjects = [NSMutableArray array];
    }
    return self;
}

- (NSDictionary<NSString *, JSONBucket *> *)childBuckets {
    return [self.mutableChildBuckets copy];
}

- (NSArray<JSONObject *> *)objects {
    return [self.mutableObjects copy];
}

- (JSONObject *)objectWithJSONDictionary:(NSDictionary<NSString *, id> *)JSONDictionary
                         primaryKeyValue:(id)primaryKeyValue {
    return [[JSONObject alloc] initWithBucket:self
                               JSONDictionary:JSONDictionary
                              primaryKeyValue:primaryKeyValue];
}

- (void)addObject:(JSONObject *)object {
    [self.mutableObjects addObject:object];
}

- (NSString *)debugDescription {
    return [self recursiveDebugDescriptionWithDepth:0];
}

- (NSString *)recursiveDebugDescriptionWithDepth:(NSUInteger)depth {
    NSMutableString *description = [NSMutableString stringWithFormat:@"%@", self.entity.name];
    for (JSONBucket *childBucket in self.mutableChildBuckets) {
        NSString *childDescription = [childBucket recursiveDebugDescriptionWithDepth:depth + 1];
        [description appendFormat:@"%*s%@", (int)depth * 4, " ", childDescription];
    }
    return description;
}

@end

@implementation JSONMappingContext

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                mappingModel:(JSONMappingModel *)mappingModel
                          attributeConverter:(JSONAttributeConverter *)attributeConverter
                                      entity:(JSONEntityDescription *)rootEntity
                                     mapping:(JSONObjectMapping *)rootMapping
                                managedbject:(NSManagedObject *)rootManagedObject {
    if (self = [super init]) {
        _managedObjectContext = managedObjectContext;
        _mappingModel = mappingModel;
        _attributeConverter = attributeConverter;
        _rootEntity = rootEntity;
        _rootMapping = rootMapping;
        _rootManagedObject = rootManagedObject;
        _allBuckets = [NSMutableArray array];
        _rootBucket = [self bucketWithEntity:self.rootEntity mapping:self.rootMapping];
    }
    return self;
}

- (JSONBucket *)bucketWithEntity:(JSONEntityDescription *)entity mapping:(JSONObjectMapping *)mapping {
    JSONBucket *bucket = [[JSONBucket alloc] initWithEntity:entity mapping:mapping];
    [self.allBuckets addObject:bucket];
    return bucket;
}

- (void)addObjectsFromJSON:(id)JSON {
    NSMutableArray *nodes = [NSMutableArray arrayWithObject:JSON];
    NSMutableArray<JSONBucket *> *buckets = [NSMutableArray arrayWithObject:self.rootBucket];
    
    while (nodes.count > 0) {
        NSAssert(nodes.count == buckets.count, @"Each node corresponds to exactly one bucket reference");
        
        id nodeJSON = nodes.lastObject;
        [nodes removeLastObject];
        
        JSONBucket *bucket = buckets.lastObject;
        [buckets removeLastObject];
        
        if ([nodeJSON isKindOfClass:[NSArray class]]) {
            for (id childJSON in nodeJSON) {
                if ([childJSON isKindOfClass:[NSArray class]]) {
                    // Arrays of arrays are not supported.
                    continue;
                }
                [nodes addObject:childJSON];
                [buckets addObject:bucket];
            }
        }
        
        else if ([nodeJSON isKindOfClass:[NSDictionary class]]) {
            // Primary key must be processed before anything else is done here. DO NOT move this.
            NSString *primaryKey = bucket.entity.primaryKey;
            id primaryKeyValue = nil;

            if (primaryKey != nil) {
                NSArray<JSONAttributeMapping *> *primaryKeyMappings =
                    bucket.mapping.attributeMappingsByName[primaryKey];
                
                for (JSONAttributeMapping *primaryKeyMapping in primaryKeyMappings) {
                    NSAttributeDescription *primaryKeyAttribute =
                        bucket.entity.managedEntity.attributesByName[primaryKey];
                    
                    id JSONPrimaryKeyValue = [nodeJSON valueForJSONKeyPath:primaryKeyMapping.JSONKey];
                    id value =
                        [self.attributeConverter convertedJSONValue:JSONPrimaryKeyValue forAttribute:primaryKeyAttribute];
                    if (value == nil || value == [NSNull null]) {
                        continue;
                    }
                    
                    if (![bucket.entity validatePrimaryKey:value]) {
                        continue;
                    }
                    
                    primaryKeyValue = value;
                }
                
                if (primaryKeyValue == nil) {
                    NSLog(@"JSONObjectMapper: JSON dictionary for entity %@ doesn't contain value for primary key",
                          bucket.entity.name);
                    continue;
                }
            }
            
            JSONObject *object = [bucket objectWithJSONDictionary:nodeJSON
                                                  primaryKeyValue:primaryKeyValue];
            [bucket addObject:object];
            
            for (JSONRelationshipMapping *relationshipMapping in bucket.mapping.relationshipMappings) {
                NSString *relationshipName = relationshipMapping.relationshipName;
                NSRelationshipDescription *relationship =
                    bucket.entity.managedEntity.relationshipsByName[relationshipName];
                if (relationship == nil) {
                    continue;
                }
                
                id destinationJSON;
                JSONEntityDescription *destinationEntity;
                if (relationshipMapping.destinationEntityName != nil) {
                    destinationEntity = self.mappingModel.entitiesByName[relationshipMapping.destinationEntityName];
                } else {
                    // Automatically infer destination entity based on the managed object model.
                    NSEntityDescription *destinationManagedEntity = relationship.destinationEntity;
                    destinationEntity = [self.mappingModel entityForManagedEntity:destinationManagedEntity];
                }
                JSONObjectMapping *destinationMapping;
                
                if (relationshipMapping.inlineMapping != nil) {
                    destinationJSON = nodeJSON;
                    destinationMapping = relationshipMapping.inlineMapping;
                } else {
                    destinationJSON = [nodeJSON valueForJSONKeyPath:relationshipMapping.JSONKey];
                    destinationMapping = relationshipMapping.destinationMapping ?: destinationEntity.defaultMapping;
                }
                
                if (destinationJSON == nil || destinationMapping == nil) {
                    continue;
                }

                JSONBucket *destinationBucket =
                    [self bucketWithEntity:destinationEntity mapping:destinationMapping];
                [object addLinkWithName:relationshipName destinationBucket:destinationBucket];
                
                [nodes addObject:destinationJSON];
                [buckets addObject:destinationBucket];
            }
        }
        
        else if ([nodeJSON isKindOfClass:[NSString class]] || [nodeJSON isKindOfClass:[NSNumber class]]) {
            NSString *primaryKey = bucket.entity.primaryKey;
            NSAttributeDescription *primaryKeyAttribute =
                bucket.entity.managedEntity.attributesByName[primaryKey];
            
            id primaryKeyValue = [self.attributeConverter convertedJSONValue:nodeJSON
                                                                forAttribute:primaryKeyAttribute];
            if (![bucket.entity validatePrimaryKey:primaryKeyValue]) {
                continue;
            }
            
            JSONObject *object = [bucket objectWithJSONDictionary:nil primaryKeyValue:primaryKeyValue];
            [bucket addObject:object];
        }
    }
}

- (void)fetchManagedObjects {
    NSMutableArray<JSONBucket *> *buckets = [self.allBuckets mutableCopy];
    
    if (self.rootManagedObject != nil) {
        NSAssert(self.rootBucket.objects.count <= 1,
                 @"Root bucket with an existing managed object cannot contain more than one JSON object");
        self.rootBucket.objects.firstObject.managedObject = self.rootManagedObject;
        [buckets removeObject:self.rootBucket];
        
        NSAssert(self.rootBucket.entity.primaryKey != nil,
                 @"Mapping to existing object supporst only entities with primary key");
        [self.rootManagedObject setValue:self.rootBucket.objects.firstObject.primaryKeyValue
                                  forKey:self.rootEntity.primaryKey];
    }
    
    for (JSONEntityDescription *entity in self.mappingModel.entities) {
        NSMutableSet *PKValues = [NSMutableSet set];
        NSMutableArray<JSONObject *> *entityObjects = [NSMutableArray array];
        NSMutableDictionary<id, NSMutableArray<JSONObject *> *> *entityObjectsByPK = [NSMutableDictionary dictionary];
        
        //
        // Step 0: Collect all primary key values (PKs) referenced in the input JSON tree.
        //
        
        for (JSONBucket *bucket in buckets) {
            if (![bucket.entity.name isEqualToString:entity.name]) {
                continue;
            }
            
            for (JSONObject *object in bucket.objects) {
                [entityObjects addObject:object];
                
                id PK = object.primaryKeyValue;
                if (PK == nil) {
                    continue;
                }
                
                if (object.managedObject != nil) {
                    continue;
                }
    
                NSMutableArray *objectsForCurrentPK = entityObjectsByPK[PK];
                if (objectsForCurrentPK == nil) {
                    objectsForCurrentPK = [NSMutableArray array];
                    entityObjectsByPK[PK] = objectsForCurrentPK;
                }
                
                [entityObjectsByPK[PK] addObject:object];
                [PKValues addObject:object.primaryKeyValue];
            }
        }
        
        //
        // Step 1: Connect JSON objects with existing managed objects.
        //
        
        if (PKValues.count > 0) {
            NSArray *sortedPKValues = [PKValues.allObjects sortedArrayUsingSelector:@selector(compare:)];
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entity.name];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K IN %@", entity.primaryKey, sortedPKValues];
            fetchRequest.returnsObjectsAsFaults = NO;
            
            NSError *error;
            NSArray<NSManagedObject *> *existingManagedObjects =
                [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (error != nil) {
                NSLog(@"JSONMappingContext: Fetch request failed with error: %@", error);
                continue;
            }
            
            NSMutableSet *existingPKValues = [NSMutableSet set];
            
            for (NSManagedObject *managedObject in existingManagedObjects) {
                id PK = [managedObject valueForKey:entity.primaryKey];
                [existingPKValues addObject:PK];
                
                for (JSONObject *object in entityObjectsByPK[PK]) {
                    object.managedObject = managedObject;
                }
            }
            
            [PKValues minusSet:existingPKValues];
        }
        
        if (entity.primaryKey != nil) {
            
            //
            // Step 2: Create new managed objects for remaining JSON objects that have a PK.
            //
            
            if (PKValues.count > 0) {
                NSMutableArray<NSManagedObject *> *newManagedObjects = [NSMutableArray array];
                
                for (id PK in PKValues) {
                    NSManagedObject *managedObject = [[NSManagedObject alloc] initWithEntity:entity.managedEntity
                                                              insertIntoManagedObjectContext:self.managedObjectContext];
                    [managedObject setValue:PK forKey:entity.primaryKey];
                    [newManagedObjects addObject:managedObject];
                }
                
                for (NSManagedObject *managedObject in newManagedObjects) {
                    id PK = [managedObject valueForKey:entity.primaryKey];
                    
                    for (JSONObject *object in entityObjectsByPK[PK]) {
                        object.managedObject = managedObject;
                    }
                }
            }
        } else {
            
            //
            // Step 2 (alternative case): Create new managed objects for remaining JSON objects (without PKs).
            //
            
            for (JSONObject *object in entityObjects) {
                if (object.managedObject == nil) {
                    object.managedObject = [[NSManagedObject alloc] initWithEntity:entity.managedEntity
                                                    insertIntoManagedObjectContext:self.managedObjectContext];
                }
            }
        }
    }
}

@end
