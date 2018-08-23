//
//  ViewController.m
//  JSONObjectMapperExample
//
//  Created by Sergey on 20/05/2018.
//  Copyright © 2018 Sergey. All rights reserved.
//

#import <JSONObjectMapper/JSONObjectMapper.h>
#import "Comment.h"
#import "DateTransformer.h"
#import "Post.h"
#import "TypeSafeCasting.h"
#import "User.h"
#import "ViewController.h"

static NSString *const SomeAPIURL = @"https://gist.githubusercontent.com/sryze/fd6ce4e472e261e3ad56f5b8bcf8d091/raw/9c0a1ba1c02f38ec7831ede4ea60537943838ae5/api.json";

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    JSONObjectMapper *objectMapper = [[JSONObjectMapper alloc] initWithManagedObjectContext:self.managedObjectContext];

    // Register a date transformer. You have to define a DateTransformer if you're mapping NSDate
    // properties from JSON.
    //
    // Other types of transformers (custom transformers) are supported as well - use the Core Data model
    // editor to set them via user-defined attributes on those entity attributes that you want to transform.
    //
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    DateTransformer *dateTransformer = [[DateTransformer alloc] initWithDateFormatter:dateFormatter];
    [objectMapper setValueTransformer:dateTransformer forName:@"DateTransformer"];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
    configuration.URLCache = nil;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:SomeAPIURL]
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"Error fetching data from API: %@", error);
            return;
        }
        
        NSError *JSONError;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
        NSLog(@"API response: %@", responseDictionary);
        if (JSONError != nil) {
            NSLog(@"Could not parse JSON data: %@", JSONError);
            return;
        }
        
        NSArray<Post *> *posts = [objectMapper
                                  mapArray:[responseDictionary[@"posts"] asArray] toEntityClass:Post.class];
        [objectMapper mapArray:[responseDictionary[@"users"] asArray] toEntityClass:User.class];
        
        // After mapping both posts and users, post and comment objects are actually connected to user objects (through
        // the author_id and user_id relationship in JSON, or author and user in the Core Data model).
        for (Post *post in posts) {
            NSLog(@"Post: postID=%@, content=%@, rating=%@, viewCount=%@, users.count=%d",
                  post.postID, post.content, post.rating, post.viewCount, 0);
            for (Comment *comment in post.comments) {
                NSLog(@"- Comment: commentId=%@, message=%@, date=%@, user=%@",
                      comment.commentID, comment.message, comment.date, comment.user.username);
            }
        }
    }];
    [task resume];
}

@end
