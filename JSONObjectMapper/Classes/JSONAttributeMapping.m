#import "JSONAttributeMapping.h"

@implementation JSONAttributeMapping

+ (instancetype)mappingWithAttributeName:(NSString *)attributeName JSONKey:(NSString *)JSONKey {
    return [[self alloc] initWithAttributeName:attributeName JSONKey:(NSString *)JSONKey];
}

+ (instancetype)mappingWithAttributeName:(NSString *)attributeName valueBlock:(JSONAttributeValueBlock)valueBlock {
    return [[self alloc] initWithAttributeName:attributeName valueBlock:valueBlock];
}

- (instancetype)initWithAttributeName:(NSString *)attributeName JSONKey:(NSString *)JSONKey {
    if (self = [super init]) {
        _attributeName = attributeName;
        _JSONKey = JSONKey;
    }
    return self;
}

- (instancetype)initWithAttributeName:(NSString *)attributeName valueBlock:(JSONAttributeValueBlock)valueBlock {
    if (self = [super init]) {
        _attributeName = attributeName;
        _valueBlock = valueBlock;
    }
    return self;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@ (attributeName: %@, JSONKey: %@)",
            super.debugDescription,
            self.attributeName.debugDescription,
            self.JSONKey.debugDescription];
}

@end
