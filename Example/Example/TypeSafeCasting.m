//
//  ViewController.m
//  JSONObjectMapperExample
//
//  Created by Sergey on 20/05/2018.
//  Copyright © 2018 Sergey. All rights reserved.
//

#import "TypeSafeCasting.h"

#define VALUE_IF_OF_TYPE(value, type)  \
    ([value isKindOfClass:[type class]]) ? (type *)value : nil

@implementation NSObject (TypeSafeCasting)

- (NSArray *)asArray {
    return VALUE_IF_OF_TYPE(self, NSArray);
}

- (NSDictionary *)asDictionary {
    return VALUE_IF_OF_TYPE(self, NSDictionary);
}

- (NSNumber *)asNumber {
    return VALUE_IF_OF_TYPE(self, NSNumber);
}

- (NSInteger)asInteger {
    NSNumber *numberValue = [self asNumber];
    if (numberValue != nil) {
        return numberValue.integerValue;
    }
    NSString *stringValue = [self asString];
    if (stringValue != nil) {
        return stringValue.integerValue;
    }
    return 0;
}

- (NSUInteger)asUnsignedInteger {
    NSNumber *numberValue = [self asNumber];
    if (numberValue != nil) {
        return numberValue.unsignedIntegerValue;
    }
    NSString *stringValue = [self asString];
    if (stringValue != nil) {
        return (NSUInteger)stringValue.integerValue;
    }
    return 0;
}

- (NSString *)asString {
    return VALUE_IF_OF_TYPE(self, NSString);
}

@end
