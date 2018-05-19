#import "JSONAttributeConverter.h"
#import "JSONAttributeMapping.h"
#import "JSONEntityDescription.h"
#import "JSONMappingContext.h"
#import "JSONMappingModel.h"
#import "JSONObjectMapper.h"
#import "JSONRelationshipMapping.h"
#import "NSDictionary+JSONKeyPath.h"

// #define LOG_MAPPING_TIME

#ifndef DEBUG
    #define NSLog(...)
#endif

@interface JSONObjectMapperDelegateWrapper : NSObject <JSONObjectMapperDelegate>

@property (weak, nonatomic) id<JSONObjectMapperDelegate> delegate;

@end

@implementation JSONObjectMapperDelegateWrapper

- (BOOL)objectMapper:(JSONObjectMapper *)objectMapper
        willSetValue:(id)value
        forAttribute:(NSAttributeDescription *)attribute
            ofObject:(__kindof NSManagedObject *)object {
    id<JSONObjectMapperDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(objectMapper:willSetValue:forAttribute:ofObject:)]) {
        return [delegate objectMapper:objectMapper willSetValue:value forAttribute:attribute ofObject:object];
    }
    return YES;
}

- (BOOL)objectMapper:(JSONObjectMapper *)objectMapper
        willSetValue:(id)value
     forRelationship:(NSRelationshipDescription *)relationship
            ofObject:(__kindof NSManagedObject *)object {
    id<JSONObjectMapperDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(objectMapper:willSetValue:forRelationship:ofObject:)]) {
        return [delegate objectMapper:objectMapper willSetValue:value forRelationship:relationship ofObject:object];
    }
    return YES;
}

@end

@interface JSONObjectMapper ()

@property (nonatomic, readonly) JSONMappingModel *mappingModel;
@property (nonatomic, readonly) JSONObjectMapperDelegateWrapper *delegateWrapper;
@property (nonatomic, readonly) JSONAttributeConverter *attributeConverter;

@end

@implementation JSONObjectMapper

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    if (self = [super init]) {
        _managedObjectContext = managedObjectContext;
        NSManagedObjectModel *managedObjectModel = managedObjectContext.persistentStoreCoordinator.managedObjectModel;
        _mappingModel = [[JSONMappingModel alloc] initWithManagedObjectModel:managedObjectModel];
        _attributeConverter = [[JSONAttributeConverter alloc] init];
        _delegateWrapper = [[JSONObjectMapperDelegateWrapper alloc] init];
    }
    return self;
}

- (void)setValueTransformer:(NSValueTransformer *)valueTransformer forName:(NSString *)name {
    [self.attributeConverter setValueTransformer:valueTransformer forName:name];
}

- (void)setDelegate:(id<JSONObjectMapperDelegate>)delegate {
    _delegate = delegate;
    _delegateWrapper.delegate = delegate;
}

- (void)setValue:(id)value
    forAttribute:(NSAttributeDescription *)attribute
        ofObject:(NSManagedObject *)object {
    if ([self.delegateWrapper objectMapper:self willSetValue:value forAttribute:attribute ofObject:object]) {
        [object setValue:value forKey:attribute.name];
    }
}

- (void)setValue:(id)value
 forRelationship:(NSRelationshipDescription *)relationship
        ofObject:(NSManagedObject *)object {
    if ([self.delegateWrapper objectMapper:self willSetValue:value forRelationship:relationship ofObject:object]) {
        [object setValue:value forKey:relationship.name];
    }
}

- (__kindof NSManagedObject *)mapDictionary:(id)dictionary toEntityClass:(Class)entityClass {
    JSONEntityDescription *entity = [self.mappingModel entityForClass:entityClass];
    return [self mapDictionary:dictionary
                 toEntityClass:entityClass
                        object:nil
                       mapping:entity.defaultMapping];
}

- (void)mapDictionary:(id)dictionary toObject:(NSManagedObject *)object mapping:(JSONObjectMapping *)mapping {
    JSONEntityDescription *entity = [self.mappingModel entityForManagedEntity:object.entity];
    [self mapDictionary:dictionary toEntityClass:nil object:object mapping:mapping ?: entity.defaultMapping];
}

- (__kindof NSManagedObject *)mapDictionary:(id)dictionary
                              toEntityClass:(Class)entityClass
                                     object:(NSManagedObject *)existingObject
                                    mapping:(JSONObjectMapping *)mapping {
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        JSONEntityDescription *entity = [self.mappingModel entityForClass:entityClass];
        return [self mapObject:dictionary toEntity:entity object:existingObject mapping:mapping];
    } else {
        NSLog(@"JSONObjectMapper: Expected JSON to be a dictionary but got %@", [dictionary class]);
        return nil;
    }
}

- (NSArray<__kindof NSManagedObject *> *)mapArray:(id)array toEntityClass:(Class)entityClass {
    JSONEntityDescription *entity = [self.mappingModel entityForClass:entityClass];
    return [self mapArray:array toEntityClass:entityClass mapping:entity.defaultMapping];
}

- (NSArray<__kindof NSManagedObject *> *)mapArray:(id)array
                                    toEntityClass:(Class)entityClass
                                          mapping:(JSONObjectMapping *)mapping {
    if ([array isKindOfClass:[NSArray class]]) {
        JSONEntityDescription *entity = [self.mappingModel entityForClass:entityClass];
        return [self mapObject:array toEntity:entity object:nil mapping:mapping];
    } else {
        NSLog(@"JSONObjectMapper: Expected JSON to be an array but got %@", [array class]);
        return nil;
    }
}

- (id)mapObject:(id)JSON
       toEntity:(JSONEntityDescription *)entity
         object:(NSManagedObject *)existingObject
        mapping:(JSONObjectMapping *)mapping {
#ifdef LOG_MAPPING_TIME
    NSDate *startDate = [NSDate date];
#endif
    
    if (existingObject != nil) {
        NSAssert([JSON isKindOfClass:[NSDictionary class]], @"JSON must be dictionary");
        NSAssert(entity == nil || [existingObject.entity isEqual:entity], @"Entities must match");
        entity = [self.mappingModel entityForManagedEntity:existingObject.entity];
    }
    
    JSONMappingContext *mappingContext = [[JSONMappingContext alloc]
                                          initWithManagedObjectContext:self.managedObjectContext
                                          mappingModel:self.mappingModel
                                          attributeConverter:self.attributeConverter
                                          entity:entity
                                          mapping:mapping
                                          managedbject:existingObject];
    [mappingContext addObjectsFromJSON:JSON];
    [mappingContext fetchManagedObjects];
    
    JSONBucket *rootBucket = mappingContext.rootBucket;
    NSMutableArray<JSONObject *> *objects = [NSMutableArray arrayWithArray:rootBucket.objects];
    
    while (objects.count > 0) {
        JSONObject *object = objects.lastObject;
        [objects removeLastObject];
        
        JSONBucket *bucket = object.bucket;
        
        for (JSONLink *link in object.links) {
            NSArray<JSONObject *> *destinationObjects = link.destinationBucket.objects;
            [objects addObjectsFromArray:destinationObjects];
            
            NSRelationshipDescription *relationship =
                bucket.entity.managedEntity.relationshipsByName[link.name];
            NSAssert(relationship != nil, @"Invalid link");
            NSManagedObject *managedObject = object.managedObject;
            
            if (relationship.toMany) {
                id destinationManagedObjects = (relationship.ordered
                                                ? [NSMutableOrderedSet orderedSet]
                                                : [NSMutableSet set]);
                for (JSONObject *destinationObject in destinationObjects) {
                    [destinationManagedObjects performSelector:@selector(addObject:)
                                                    withObject:destinationObject.managedObject];
                }
                [self setValue:destinationManagedObjects forRelationship:relationship ofObject:managedObject];
            } else {
                JSONObject *destinationObject = destinationObjects.firstObject;
                [self setValue:destinationObject.managedObject forRelationship:relationship ofObject:managedObject];
            }
        }
        
        if (object.JSONDictionary == nil) {
            continue;
        }
        
        for (JSONAttributeMapping *attributeMapping in bucket.mapping.attributeMappings) {
            NSString *attributeName = attributeMapping.attributeName;
            NSAttributeDescription *attribute =
                bucket.entity.managedEntity.attributesByName[attributeName];
            
            NSAssert(attribute != nil, @"Entity \"%@\" is missing attribute \"%@\" which is present in mapping",
                     bucket.entity.name, attributeName);
            
            id value;
            if (attributeMapping.valueBlock != nil) {
                value = attributeMapping.valueBlock(object.managedObject, object.JSONDictionary);
            } else {
                id JSONValue = [object.JSONDictionary valueForJSONKeyPath:attributeMapping.JSONKey];
                if (JSONValue != nil && JSONValue != [NSNull null]) {
                    value = [self.attributeConverter convertedJSONValue:JSONValue forAttribute:attribute];
                }
            }
            
            if (value == nil) {
                continue;
            }
            if (value == [NSNull null]) {
                value = nil;
            }
            
            [self setValue:value forAttribute:attribute ofObject:object.managedObject];
        }
        
        JSONObjectPostprocessBlock postprocessBlock = bucket.mapping.postprocessBlock;
        if (postprocessBlock != nil) {
            postprocessBlock(object.managedObject, object.JSONDictionary);
        }
    }
    
    id result = nil;
    
    if ([JSON isKindOfClass:[NSArray class]]) {
        NSMutableArray<NSManagedObject *> *managedObjects = [NSMutableArray array];
        for (JSONObject *object in rootBucket.objects) {
            if (object.managedObject != nil) {
                [managedObjects addObject:object.managedObject];
            }
        }
        result = managedObjects;
    }
    
    if ([JSON isKindOfClass:[NSDictionary class]]) {
        JSONObject *object = rootBucket.objects.firstObject;
        result = object.managedObject;
    }
    
#ifdef LOG_MAPPING_TIME
    NSLog(@"JSONObjectMapper: Mapping time: %f", [[NSDate date] timeIntervalSinceDate:startDate]);
#endif
    
    return result;
}

@end
