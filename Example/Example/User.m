//
//  User.m
//  JSONObjectMapperExample
//
//  Created by Sergey on 20/05/2018.
//  Copyright © 2018 Sergey. All rights reserved.
//

#import <JSONObjectMapper/JSONObjectMapping.h>
#import "User.h"

@implementation User

@dynamic userID;
@dynamic username;
@dynamic email;
@dynamic posts;
@dynamic comments;

+ (JSONObjectMapping *)defaultMapping {
    return [JSONObjectMapping mappingWithDictionary:@{
        @"userID": @"user_id",
        @"username": @"username",
        @"email": @"email"
    }];
}

+ (NSString *)primaryKey {
    return @"userID";
}

@end
