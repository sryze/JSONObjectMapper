# JSONObjectMapper

[![Version][version]][pod]
[![License][license]][pod]
[![Platform][platform]][pod]

## Introduction

JSONObjectMapper can efficiently map JSON objects to corresponding Core Data 
managed objects by using your custom mapping definitions. It frees you from 
writing the same boilerplate code over and over again.

It's also pretty fast. Unlike some other implementations, rather than fetch 
each individual object as needed while JSON is being processed, this mapper 
converts it into an intermediate internal representation and then fetches the 
necessary objects in "buckets" (grouped by entity), which is a lot more 
efficient.

## Installation

JSONObjectMapper is available through [CocoaPods](http://cocoapods.org). To 
install it, simply add the following line to your Podfile:

```ruby
pod 'JSONObjectMapper'
```

## Swift

JSONObjectMapper can be used by Swift code. In order to make it work you need
to perfrom these stesp:

1. Add a bridging header to your project with the following import statement:

   ```objc
   #include <JSONObjectMapper/JSONObjectMapper.h>
   ```

   This will make JSONObjectMapper classes visible to your Swift code.
   
2. Mark your entity classes with `@objc(ClassName)` where `ClassName` is the
   class name that you set in the entity properties in your Core Data model.

[ExampleSwift](ExampleSwift) contains a complete example written in Swift.

## Example

In order to use JSONObjectMapper, you need to modify your model classes 
(subclasses of `NSManagedObject`) to return some metadata about their entities 
that describes how to map JSON properties to Core Data entity attributes and 
relationsihps. For instance, to avoid creation of duplicate objects, each 
entity should have a **primary key** attribute, and JSON objects mapped to this
entity should also contain a non-null value for the key.

Here is an example of how to add mapping support to a class:

```objective-c
// In general, you will implement these two methods of the JSONMappingProtocol protocol:

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

How to map JSON data to managed objects:

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

If you want to perform some additional conversion of attribute values on many 
model classes, one way is to use custom value transformers (subclasses of 
`NSValueTransformer`). You can register value transformers on your 
`JSONObjectMapper` instance and refer to them in your Core Data model via User 
Defined Attributes using `JSONValueTransformer` as the key and the name of your 
transformer class as the value.

![Screenshot][screenshot]

For instance, if you're using an API that returns relative file URLs everywhere 
and you want to convert them to absolute URLs you could do it like this:

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

JSONObjectMapper is available under the MIT license. See the LICENSE file for 
more info.

[pod]: http://cocoapods.org/pods/JSONObjectMapper
[version]: https://img.shields.io/cocoapods/v/JSONObjectMapper.svg?style=flat
[license]: https://img.shields.io/cocoapods/l/JSONObjectMapper.svg?style=flat
[platform]: https://img.shields.io/cocoapods/p/JSONObjectMapper.svg?style=flat
[screenshot]: https://github.com/sryze/JSONObjectMapper/blob/master/model-attributes-transformer.png
