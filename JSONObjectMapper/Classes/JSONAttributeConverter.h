#import <CoreData/CoreData.h>

@interface JSONAttributeConverter : NSObject

- (void)setValueTransformer:(NSValueTransformer *)valueTransformer forName:(NSString *)name;

- (id)convertedJSONValue:(id)JSONValue forAttribute:(NSAttributeDescription *)attribute;

@end
