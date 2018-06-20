# JSONObjectMapper

[![Version](https://img.shields.io/cocoapods/v/JSONObjectMapper.svg?style=flat)](http://cocoapods.org/pods/JSONObjectMapper)
[![License](https://img.shields.io/cocoapods/l/JSONObjectMapper.svg?style=flat)](http://cocoapods.org/pods/JSONObjectMapper)
[![Platform](https://img.shields.io/cocoapods/p/JSONObjectMapper.svg?style=flat)](http://cocoapods.org/pods/JSONObjectMapper)

## Introduction

JSONObjectMapper can efficiently map JSON objects to corresponding Core Data managed objects by using your custom mapping definitions. It frees you from writing the same boilerplate code over and over again.

It's also fast. Unlike some other implementations, rather than fetch each individual object as needed while JSON is being processed, this mapper converts it into an intermediate internal representation and then fetches the necessary objects by ID grouped by entity, which is a lot more efficient.

## Installation

JSONObjectMapper is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'JSONObjectMapper'
```

## Example

In order to use JSONObjectMapper, you need to modify your model classes (subclasses of `NSManagedObject`) to return some metadata about their entities that describes how to map JSON properties to Core Data entity attributes and relationsihps. For instance, to avoid creation of duplicate objects, each entity should have a "primary key" attribute, and JSON objects mapped to this entity should also contain a non-null value for the primary key.

Here is an example of how to add mapping support to a class:

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

## Custom attribute transformers

If you want to perform some additional conversion of attribute values on many model classes, one way is to use custom value transformers (subclasses of `NSValueTransformer`). You can register value transformers on your `JSONObjectMapper` instance and refer to them in your Core Data model via User Defined Attributes using `JSONValueTransformer` as the key and the name of your transformer class as the value.

![Screenshot](https://github.com/sryze/JSONObjectMapper/blob/master/model-attributes-transformer.png)

For instance, if you're using an API that returns relative file URLs everywhere and you want to convert them to absolute URLs you could do it like this:

```objective-c
@interface FileURLTransformer : NSValueTransformer

- (instancetype)initWithBaseURL:(NSURL *)baseURL;

@interface FileURLTransformer ()

@property (nonatomic, readonly) NSURL *baseURL;

@end

@implementation FileURLTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (instancetype)initWithBaseURL:(NSURL *)baseURL {
    if (self = [super init]) {
        _baseURL = baseURL;
    }
    return self;
}

- (id)transformedValue:(id)value {
    NSString *relativeURLString = value;
    if (relativeURLString.length != 0) {
        return [NSURL URLWithString:relativeURLString relativeToURL:self.baseURL];
    }
    return nil;
}

@end
```

And then somewhere during initialization of your mapper:

```objective-c
[objectMapper setValueTransformer:fileURLTransformer forName:@"FileURLTransformer"];
```

## Author

Sergey Zolotarev, sryze@protonmail.com

## Changelog

### 0.1.1

Updated the README with more information and examples

### 0.1.0

Initial release

## License

JSONObjectMapper is available under the MIT license. See the LICENSE file for more info.
