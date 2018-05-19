//
//  Post.h
//  JSONObjectMapperExample
//
//  Created by Sergey on 20/05/2018.
//  Copyright © 2018 Sergey. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <JSONObjectMapper/JSONMappingProtocol.h>

@class Comment;
@class User;

@interface Post : NSManagedObject <JSONMappingProtocol>

@property (nonatomic) NSNumber *postID;
@property (nonatomic) NSString *content;
@property (nonatomic) NSNumber *rating;
@property (nonatomic) NSNumber *viewCount;
@property (nonatomic) User *author;
@property (nonatomic) NSOrderedSet<Comment *> *comments;

@end
