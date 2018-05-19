#import "JSONObjectMapping.h"
#import "JSONRelationshipMapping.h"
#import "JSONRelationshipMappingPrivate.h"

@implementation JSONRelationshipMapping

+ (instancetype)mappingWithJSONKey:(NSString *)JSONKey {
    return [[self alloc] initWithJSONKey:JSONKey];
}

+ (instancetype)mappingWithJSONKey:(NSString *)JSONKey destinationEntityName:(NSString *)entityName {
    return [[self alloc] initWithJSONKey:JSONKey destinationEntityName:entityName];
}

- (instancetype)initWithJSONKey:(NSString *)JSONKey {
    if (self = [super init]) {
        _JSONKey = JSONKey;
    }
    return self;
}

- (instancetype)initWithJSONKey:(NSString *)JSONKey destinationEntityName:(NSString *)entityName {
    if (self = [super init]) {
        _JSONKey = JSONKey;
        _destinationEntityName = entityName;
    }
    return self;
}

- (instancetype)initWithJSONPrimaryKey:(NSString *)JSONPrimaryKey {
    if (self = [super init]) {
        _JSONKey = JSONPrimaryKey;
    }
    return self;
}

- (NSString *)debugDescription {
    NSMutableArray<NSString *> *descriptionPieces = [NSMutableArray array];
    
    [descriptionPieces addObject:[NSString stringWithFormat:@"JSONKey: %@", self.JSONKey]];
    
    if (self.inlineMapping != nil) {
        [descriptionPieces addObject:
         [NSString stringWithFormat:@"inlineMapping: %@", self.inlineMapping.debugDescription]];
    }
    
    if (self.destinationMapping != nil) {
        [descriptionPieces addObject:
         [NSString stringWithFormat:@"destinationMapping: %@", self.destinationMapping.debugDescription]];
    }
    
    return [NSMutableString stringWithFormat:@"%@ (%@)",
            super.debugDescription,
            [descriptionPieces componentsJoinedByString:@"; "]];
}

@end
