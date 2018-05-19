#import <CoreData/CoreData.h>

@class JSONBucket;
@class JSONEntityDescription;
@class JSONMappingModel;
@class JSONObject;
@class JSONObjectMapping;
@class JSONRelationshipMapping;

@interface JSONLink : NSObject

@property (nonatomic) NSString *name;
@property (weak, nonatomic, readonly) JSONObject *sourceObject;
@property (nonatomic, readonly) JSONBucket *destinationBucket;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithName:(NSString *)name
                sourceObject:(JSONObject *)sourceObject
           destinationBucket:(JSONBucket *)destinationBucket NS_DESIGNATED_INITIALIZER;

@end

@interface JSONObject : NSObject

@property (weak, nonatomic, readonly) JSONBucket *bucket;
@property (nonatomic, readonly) NSDictionary<NSString *, id> *JSONDictionary;
@property (nonatomic, readonly) id primaryKeyValue;
@property (nonatomic, readonly) NSArray<JSONLink *> *links;

@property (nonatomic, readonly) NSManagedObject *managedObject;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithBucket:(JSONBucket *)bucket
                JSONDictionary:(NSDictionary<NSString *, id> *)JSONDictionary
               primaryKeyValue:(id)primaryKeyValue NS_DESIGNATED_INITIALIZER;

- (void)addLinkWithName:(NSString *)name destinationBucket:(JSONBucket *)destinationBucket;

@end

@interface JSONBucket : NSObject

@property (nonatomic, readonly) JSONEntityDescription *entity;
@property (nonatomic, readonly) JSONObjectMapping *mapping;

@property (nonatomic, readonly) NSDictionary<NSString *, JSONBucket *> *childBuckets;
@property (nonatomic, readonly) NSArray<JSONObject *> *objects;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithEntity:(JSONEntityDescription *)entity
                       mapping:(JSONObjectMapping *)mapping NS_DESIGNATED_INITIALIZER;

- (JSONObject *)objectWithJSONDictionary:(NSDictionary<NSString *, id> *)JSONDictionary
                         primaryKeyValue:(id)primaryKeyValue;

- (void)addObject:(JSONObject *)object;

@end

@interface JSONMappingContext : NSObject

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) JSONMappingModel *mappingModel;
@property (nonatomic, readonly) JSONAttributeConverter *attributeConverter;
@property (nonatomic, readonly) JSONEntityDescription *rootEntity;
@property (nonatomic, readonly) JSONObjectMapping *rootMapping;
@property (nonatomic, readonly) NSManagedObject *rootManagedObject;
@property (nonatomic, readonly) JSONBucket *rootBucket;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                mappingModel:(JSONMappingModel *)mappingModel
                          attributeConverter:(JSONAttributeConverter *)attributeConverter
                                      entity:(JSONEntityDescription *)rootEntity
                                     mapping:(JSONObjectMapping *)rootMapping
                                managedbject:(NSManagedObject *)rootManagedObject NS_DESIGNATED_INITIALIZER;

- (void)addObjectsFromJSON:(id)JSON;
- (void)fetchManagedObjects;

@end
