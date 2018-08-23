//
//  Post.m
//  JSONObjectMapperExample
//
//  Created by Sergey on 20/05/2018.
//  Copyright © 2018 Sergey. All rights reserved.
//

#import <JSONObjectMapper/JSONObjectMapping.h>
#import <JSONObjectMapper/JSONRelationshipMapping.h>
#import "Post.h"

@implementation Post

@dynamic postID;
@dynamic content;
@dynamic rating;
@dynamic viewCount;
@dynamic author;
@dynamic comments;

+ (JSONObjectMapping *)defaultMapping {
    return [JSONObjectMapping mappingWithDictionary:@{
        @"postID": @"post_id",
        @"content": @"content",
        @"rating": @"rating",
        @"viewCount": @"view_count",
        @"author": [JSONRelationshipMapping mappingWithJSONKey:@"author_id"],
        @"comments": [JSONRelationshipMapping mappingWithJSONKey:@"comments"]
    }];
}

+ (NSString *)primaryKey {
    return @"postID";
}

@end
