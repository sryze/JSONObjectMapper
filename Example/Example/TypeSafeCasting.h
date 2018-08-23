//
//  ViewController.m
//  JSONObjectMapperExample
//
//  Created by Sergey on 20/05/2018.
//  Copyright © 2018 Sergey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (TypeSafeCasting)

@property (nonatomic, readonly) NSArray *asArray;
@property (nonatomic, readonly) NSDictionary *asDictionary;
@property (nonatomic, readonly) NSNumber *asNumber;
@property (nonatomic, readonly) NSInteger asInteger;
@property (nonatomic, readonly) NSUInteger asUnsignedInteger;
@property (nonatomic, readonly) NSString *asString;

@end
