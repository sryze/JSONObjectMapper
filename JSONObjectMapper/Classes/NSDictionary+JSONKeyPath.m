#import "NSDictionary+JSONKeyPath.h"

@implementation NSDictionary (JSONKeyPath)

- (id)valueForJSONKeyPath:(NSString *)keyPath {    
    id value = self;
    id result;
    
    NSUInteger length = keyPath.length;
    NSUInteger start = 0;
    NSUInteger location = 0;
    
    while (location < length) {
        NSString *key;
        NSRange searchRange = NSMakeRange(start, length - start);
        
        location = [keyPath rangeOfString:@"." options:(NSStringCompareOptions)0 range:searchRange].location;
        if (location != NSNotFound) {
            key = [keyPath substringWithRange:NSMakeRange(start, location - start)];
        } else {
            key = [keyPath substringFromIndex:start];
        }
        
        value = value[key];
        result = value;
        
        if (value == nil || ![value isKindOfClass:[NSDictionary class]]) {
            break;
        }
        
        start = location + 1;
    }
    
    return result;
}

@end
