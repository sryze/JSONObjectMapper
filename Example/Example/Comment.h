//
//  Comment.h
//  JSONObjectMapperExample
//
//  Created by Sergey on 20/05/2018.
//  Copyright © 2018 Sergey. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <JSONObjectMapper/JSONMappingProtocol.h>

@class Post;
@class User;

@interface Comment : NSManagedObject <JSONMappingProtocol>

@property (nonatomic) NSNumber *commentID;
@property (nonatomic) NSString *message;
@property (nonatomic) NSDate *date;
@property (nonatomic) User *user;
@property (nonatomic) Post *post;

@end
