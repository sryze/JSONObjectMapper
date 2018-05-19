#import "JSONAttributeMapping.h"
#import "JSONObjectMapping.h"
#import "JSONRelationshipMapping.h"
#import "JSONRelationshipMappingPrivate.h"

@interface JSONObjectMapping ()

@property (nonatomic, readonly) NSMutableArray<JSONAttributeMapping *> *mutableAttributeMappings;
@property (nonatomic, readonly) NSMutableDictionary<NSString *, NSArray<JSONAttributeMapping *> *>
    *mutableAttributeMappingsByName;
@property (nonatomic, readonly) NSMutableArray<JSONRelationshipMapping *> *mutableRelationshipMappings;
@property (nonatomic, readonly) NSMutableDictionary<NSString *, NSArray<JSONRelationshipMapping *> *>
    *mutableRelationshipMappingsByName;

@end

@implementation JSONObjectMapping

+ (instancetype)mappingWithDictionary:(NSDictionary<NSString *, id> *)properties {
    return [[JSONObjectMapping alloc] initWithDictionary:properties];
}

+ (instancetype)mappingWithParentMapping:(JSONObjectMapping *)parentMapping
                              dictionary:(NSDictionary<NSString *, id> *)selfProperties {
    return [[JSONObjectMapping alloc] initWithParentMapping:parentMapping dictionary:selfProperties];
}

- (instancetype)initWithDictionary:(NSDictionary<NSString *, id> *)properties {
    if (self = [super init]) {
        _properties = properties;
        _mutableAttributeMappings = [NSMutableArray array];
        _mutableAttributeMappingsByName = [NSMutableDictionary dictionary];
        _mutableRelationshipMappings = [NSMutableArray array];
        _mutableRelationshipMappingsByName = [NSMutableDictionary dictionary];
        [self configureProperties];
    }
    return self;
}

- (instancetype)initWithParentMapping:(JSONObjectMapping *)parentMapping
                           dictionary:(NSDictionary<NSString *, id> *)selfProperties {
    NSMutableDictionary<NSString *, id> *properties = [parentMapping.properties mutableCopy];
    [selfProperties enumerateKeysAndObjectsUsingBlock:^(id key, id obj, __unused BOOL *stop) {
        properties[key] = obj;
    }];
    return [self initWithDictionary:properties];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@ (properties: %@)",
            super.debugDescription,
            self.properties.debugDescription];
}

- (NSArray<JSONAttributeMapping *> *)attributeMappings {
    return [self.mutableAttributeMappings copy];
}

- (NSDictionary<NSString *, NSArray<JSONAttributeMapping *> *> *)attributeMappingsByName {
    return [self.mutableAttributeMappingsByName copy];
}

- (NSArray<JSONRelationshipMapping *> *)relationshipMappings {
    return [self.mutableRelationshipMappings copy];
}

- (NSDictionary<NSString *,NSArray<JSONRelationshipMapping *> *> *)relationshipMappingsByName {
    return [self.mutableRelationshipMappingsByName copy];
}

- (void)configureProperties {
    [self.properties enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, id JSONProperty, __unused BOOL *stop) {
        if ([JSONProperty isKindOfClass:[NSString class]]) {
            JSONAttributeMapping *attributeMapping =
                [[JSONAttributeMapping alloc] initWithAttributeName:propertyName JSONKey:JSONProperty];
            
            [self.mutableAttributeMappings addObject:attributeMapping];
            self.mutableAttributeMappingsByName[propertyName] = @[attributeMapping];
            
            return;
        }
        
        if ([JSONProperty isKindOfClass:[JSONAttributeMapping class]]) {
            JSONAttributeMapping *attributeMapping = JSONProperty;
            
            [self.mutableAttributeMappings addObject:attributeMapping];
            self.mutableAttributeMappingsByName[propertyName] = @[attributeMapping];
            
            return;
        }

        if ([JSONProperty isKindOfClass:[JSONRelationshipMapping class]]) {
            JSONRelationshipMapping *relationshipMapping = JSONProperty;
            relationshipMapping.relationshipName = propertyName;
            
            [self.mutableRelationshipMappings addObject:relationshipMapping];
            self.mutableRelationshipMappingsByName[propertyName] = @[relationshipMapping];
            
            return;
        }

        if ([JSONProperty isKindOfClass:[NSArray class]]) {
            // There are cases where you need to define multiple mappings for the same property.
            //
            // For example, when JSON may contain either an ID (in which case you want an identity
            // mapping) or a full object (ordinary relationship).
            //
            // You can do so by grouping both mappings in an array like this:
            //
            // {
            //     @"property": @[
            //         [JSONRelationshipMapping mappingWithJSONKey:@"other_object"],
            //         [JSONRelationshipMapping mappingWithJSONKey:@"other_object_id")]
            //     ]
            // }
            NSMutableArray<JSONAttributeMapping *> *attributeMappings = [NSMutableArray array];
            NSMutableArray<JSONRelationshipMapping *> *relationshipMappings = [NSMutableArray array];
            
            for (id value in JSONProperty) {
                if ([value isKindOfClass:[NSString class]]) {
                    JSONAttributeMapping *attributeMapping =
                        [[JSONAttributeMapping alloc] initWithAttributeName:propertyName JSONKey:value];
                    
                    [self.mutableAttributeMappings addObject:attributeMapping];
                    [attributeMappings addObject:attributeMapping];
                    
                    continue;
                }
                
                if ([value isKindOfClass:[JSONRelationshipMapping class]]) {
                    JSONRelationshipMapping *relationshipMapping = value;
                    relationshipMapping.relationshipName = propertyName;
                    
                    [self.mutableRelationshipMappings addObject:relationshipMapping];
                    [relationshipMappings addObject:relationshipMapping];
                    
                    continue;
                }
                
                NSAssert(NO, @"Unsupported JSON mapping type %@", [value class]);
            }
            
            NSAssert(attributeMappings.count > 0 || relationshipMappings.count > 0,
                     @"A property cannot have both an attribute and relationship mapping");
            
            self.mutableAttributeMappingsByName[propertyName] = [attributeMappings copy];
            self.mutableRelationshipMappingsByName[propertyName] = [relationshipMappings copy];
            
            return;
        }

        NSAssert(NO, @"The dictionary passed to JSONObjectMapping initializer must contain either key paths"
                      " or relationship mappings");
    }];
}

@end
