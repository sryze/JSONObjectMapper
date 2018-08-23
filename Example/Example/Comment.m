//
//  Comment.m
//  JSONObjectMapperExample
//
//  Created by Sergey on 20/05/2018.
//  Copyright © 2018 Sergey. All rights reserved.
//

#import <JSONObjectMapper/JSONObjectMapping.h>
#import <JSONObjectMapper/JSONRelationshipMapping.h>
#import "Comment.h"

@implementation Comment

@dynamic commentID;
@dynamic message;
@dynamic date;
@dynamic user;
@dynamic post;

+ (JSONObjectMapping *)defaultMapping {
    return [JSONObjectMapping mappingWithDictionary:@{
        @"commentID": @"comment_id",
        @"message": @"message",
        @"date": @"date",
        @"user": [JSONRelationshipMapping mappingWithJSONKey:@"user_id"]
    }];
}

+ (NSString *)primaryKey {
    return @"commentID";
}

@end
