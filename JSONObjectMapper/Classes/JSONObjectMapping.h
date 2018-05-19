#import <CoreData/CoreData.h>

typedef void (^JSONObjectPostprocessBlock)(__kindof NSManagedObject *object, NSDictionary *JSONDictionary);

@class JSONAttributeMapping;
@class JSONRelationshipMapping;

/// JSONObjectMapping defines how JSON properties are mapped to managed objects. The contain a map (dictionary)
/// where keys represent properties (attributes and relationships) of a Core Data entity and values represent
/// properties of a JSON object mapped to that entity.
///
/// An example of a simple property mapping may look like this:
///
/// JSONObjectMapping *simpleMapping = [JSONObjectMapping mappingWithDictionary:@{
///     @"remoteID": @"id",
///     @"name": @"name",
///     @"itemDescription": @"description"
/// }];
///
/// Note that managed objects can't have attributes named after built-in NSObject properties such as "description",
/// hance the property is named "itemDescription" here.
///
/// There are generally two types of property mappings: simple mappings and mappings with parent (compound) mappings.
/// Simple mappings are just that - simple. You've seen one example of a simple mapping above.
///
/// Compound mappings are mappings consisting of a base mapping and a sub-mapping. The base mapping is referred to
/// as the parent mapping. You can define compound mappings like so:
///
/// JSONObjectMapping *complexMapping = [JSONObjectMapping mappingWithParentMapping:simpleMapping dictionary:@{
///     @"numberOfBananas": @"banana_count"
/// }];
///
/// In this example we used the previous mapping as the parent mapping. This means that complexMapping wiill inherit
/// all of the properties defined in simpleMapping. Extracting properties in a parent mapping may be useful two or
/// more entities the share same properties (think of class inhertance).
///
/// \see JSONRelationshipMapping
///
@interface JSONObjectMapping : NSObject

@property (nonatomic, readonly) NSDictionary<NSString *, id> *properties;
@property (nonatomic) JSONObjectPostprocessBlock postprocessBlock;

+ (instancetype)mappingWithDictionary:(NSDictionary<NSString *, id> *)properties;
+ (instancetype)mappingWithParentMapping:(JSONObjectMapping *)parentMapping
                              dictionary:(NSDictionary<NSString *, id> *)selfProperties;

@property (nonatomic, readonly) NSArray<JSONAttributeMapping *> *attributeMappings;
@property (nonatomic, readonly) NSDictionary<NSString *, NSArray<JSONAttributeMapping *> *>
    *attributeMappingsByName;

@property (nonatomic, readonly) NSArray<JSONRelationshipMapping *> *relationshipMappings;
@property (nonatomic, readonly) NSDictionary<NSString *, NSArray<JSONRelationshipMapping *> *>
    *relationshipMappingsByName;

- (instancetype)initWithDictionary:(NSDictionary<NSString *, id> *)properties;
- (instancetype)initWithParentMapping:(JSONObjectMapping *)parentMapping
                           dictionary:(NSDictionary<NSString *, id> *)selfProperties;

@end
