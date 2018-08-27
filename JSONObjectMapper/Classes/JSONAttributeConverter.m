#import "JSONAttributeConverter.h"
#import "JSONObjectMapper.h"

NSString *const JSONDateTransformerName = @"DateTransformer";
static NSString *const JSONValueTransformerKey = @"JSONValueTransformer";

@interface JSONAttributeConverter ()

@property (nonatomic, readonly) NSMutableDictionary *valueTransformers;

@end

@implementation JSONAttributeConverter

+ (NSNumberFormatter *)numberFormatter {
    static NSNumberFormatter *numberFormatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    });
    
    return numberFormatter;
}

- (instancetype)init {
    if (self = [super init]) {
        _valueTransformers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setValueTransformer:(NSValueTransformer *)valueTransformer forName:(NSString *)name {
    self.valueTransformers[name] = valueTransformer;
}

- (NSValueTransformer *)valueTransformerForAttribute:(NSAttributeDescription *)attribute {
    NSString *valueTransformerName = attribute.userInfo[JSONValueTransformerKey];
    if (valueTransformerName != nil) {
        NSValueTransformer *valueTransformer = self.valueTransformers[valueTransformerName];
        NSAssert(valueTransformer != nil, @"Value transformer not found: %@", valueTransformerName);
        return valueTransformer;
    }
    return nil;
}

- (NSDate *)dateFromJSONString:(NSString *)JSONString {
    NSValueTransformer *dateTransformer = self.valueTransformers[JSONDateTransformerName];
    NSAssert(dateTransformer != nil, @"Date transformer is not set");
    return [dateTransformer transformedValue:JSONString];
}

- (id)convertedJSONValue:(id)JSONValue forAttribute:(NSAttributeDescription *)attribute {
    NSValueTransformer *valueTransformer = [self valueTransformerForAttribute:attribute];
    if (valueTransformer != nil) {
        return [valueTransformer transformedValue:JSONValue];
    }
    
    if ([JSONValue isKindOfClass:[NSString class]]) {
        switch (attribute.attributeType) {
            case NSBooleanAttributeType:
                return @([JSONValue boolValue]);
            case NSInteger16AttributeType:
            case NSInteger32AttributeType:
            case NSInteger64AttributeType:
                return @([JSONValue integerValue]);
            case NSFloatAttributeType:
            case NSDoubleAttributeType:
                return @([JSONValue doubleValue]);
            case NSDateAttributeType: {
                return [self dateFromJSONString:JSONValue];
            }
            default:
                return JSONValue;
        }
    }
    if ([JSONValue isKindOfClass:[NSNumber class]]) {
        switch (attribute.attributeType) {
            case NSStringAttributeType:
                return [JSONValue stringValue];
            default:
                return JSONValue;
        }
    }
    return nil;
}

@end
