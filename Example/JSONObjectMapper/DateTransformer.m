//
//  ViewController.h
//  JSONObjectMapperExample
//
//  Created by Sergey on 20/05/2018.
//  Copyright © 2018 Sergey. All rights reserved.
//

#import "DateTransformer.h"

@interface DateTransformer ()

@property (nonatomic, readonly) NSDateFormatter *dateFormatter;

@end

@implementation DateTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

- (instancetype)initWithDateFormatter:(NSDateFormatter *)dateFormatter {
    if (self = [super init]) {
        _dateFormatter = dateFormatter;
    }
    return self;
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)value {
    return [self.dateFormatter dateFromString:value];
}

- (id)reverseTransformedValue:(id)value {
    return [self.dateFormatter stringFromDate:value];
}

@end
