# JSONObjectMapper

[![Version](https://img.shields.io/cocoapods/v/JSONObjectMapper.svg?style=flat)](http://cocoapods.org/pods/JSONObjectMapper)
[![License](https://img.shields.io/cocoapods/l/JSONObjectMapper.svg?style=flat)](http://cocoapods.org/pods/JSONObjectMapper)
[![Platform](https://img.shields.io/cocoapods/p/JSONObjectMapper.svg?style=flat)](http://cocoapods.org/pods/JSONObjectMapper)

## Usage

How to add mapping support to your Core Data entity class:

```objective-c
// In the most basic case, all you need to do is implement these two methods
// of the JSONMappingProtocol protocol:

+ (JSONObjectMapping *)defaultMapping {
    // Return an object mapping that consists of attribute and relationship
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
    // Return the key which you use to uniquely identify objects in the Core
    // Data store. This is used by the mapper to decide whether it needs to
    // create a new object or update an existing one.
    return @"postID";
}

@end
```

How to map JSON data to Core Data objects (new or existing objects):

```objective-c
    JSONObjectMapper *objectMapper = [[JSONObjectMapper alloc]
                                      initWithManagedObjectContext:self.managedObjectContext];
    ...

    NSURLSession *session = NSURLSession.sharedSession;
    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:SomeAPIURL]
                                        completionHandler:^(NSData *data,
                                                            NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"Error fetching data from API: %@", error);
            return;
        }
        
        NSError *JSONError;
        NSDictionary *responseDictionary =
            [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
        NSLog(@"API response: %@", responseDictionary);
        if (JSONError != nil) {
            NSLog(@"Could not parse JSON data: %@", JSONError);
            return;
        }
        
        NSArray<Post *> *posts = [objectMapper mapArray:responseDictionary[@"posts"]
                                          toEntityClass:Post.class];
        ...
    }];
    [task resume];
```

See the [example](Example/JSONObjectMapper) project for a complete example.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

JSONObjectMapper is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'JSONObjectMapper'
```

## Author

Sergey Zolotarev, sryze01@gmail.com

## License

JSONObjectMapper is available under the MIT license. See the LICENSE file for more info.
