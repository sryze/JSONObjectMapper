#import <CoreData/CoreData.h>

typedef id (^JSONAttributeValueBlock)(NSManagedObject *object, NSDictionary *JSONDictionary);

/// JSONAttributeMapping defines a mapping between an attribute and a corresponding JSON property.
///
@interface JSONAttributeMapping : NSObject

@property (nonatomic, readonly) NSString *attributeName;
@property (nonatomic, readonly) NSString *JSONKey;
@property (nonatomic, readonly) JSONAttributeValueBlock valueBlock;

+ (instancetype)mappingWithAttributeName:(NSString *)attributeName JSONKey:(NSString *)JSONKey;
+ (instancetype)mappingWithAttributeName:(NSString *)attributeName valueBlock:(JSONAttributeValueBlock)valueBlock;

- (instancetype)initWithAttributeName:(NSString *)attributeName JSONKey:(NSString *)JSONKey;
- (instancetype)initWithAttributeName:(NSString *)attributeName valueBlock:(JSONAttributeValueBlock)valueBlock;

@end
