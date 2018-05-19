//
//  User.h
//  JSONObjectMapperExample
//
//  Created by Sergey on 20/05/2018.
//  Copyright © 2018 Sergey. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <JSONObjectMapper/JSONMappingProtocol.h>

@class Comment;
@class Post;

@interface User : NSManagedObject <JSONMappingProtocol>

@property (nonatomic) NSNumber *userID;
@property (nonatomic) NSString *username;
@property (nonatomic) NSString *email;
@property (nonatomic) NSOrderedSet<Post *> *posts;
@property (nonatomic) NSOrderedSet<Comment *> *comments;

@end
