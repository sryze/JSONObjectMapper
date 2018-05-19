#import <Foundation/Foundation.h>

@class JSONObjectMapping;

/// JSONRelationshipMapping maps Core Data relationships to JSON relationships. It's a powerful tool for re-creating
/// relationships between managed objects based on different kinds of JSON relationships: embedded objects or arrays,
/// objects with identity (ID) keys, or inline relationships (see below).
///
/// You create a relationship mapping by using one of the -init* methods or alternatively one of the corresponding
/// class methods.
///
/// There are four kinds of relationship mappings:
///
/// 1. Embedded relationship
///
/// This is the simplest one. In this relationship, related objects (destination objects) are embedded into source
/// object (the managed object whose properties are being mapped). Both source and destination objects are mapped
/// using their property mappings.
///
/// Example JSON data for an embedded realtionship:
///
/// {
///     "name": "John Smith",
///     "fruits": [
///     {
///         "id": "1",
///         "type": "Apple"
///     },
///     {
///         "id": "2",
///         "type": "Orange"
///     }]
/// }
///
/// 2. Relationship with ID key
///
/// In relationships with identity (ID) keys, destination objects' JSON is not directly embedded into the source
/// object's JSON. Rather, the source object referes to them indirectly via a (usually numeric) ID key, sometimes
/// called a foreign key.
///
/// "message": {
///     "text": "Hello World!",
///     "sender_id": 123
/// }
///
/// In this example "sender" is an ID relationship to another entity, probably called User or something.
///
/// 3. Relationship with inline properties
///
/// This is a special case of to-one ID relationship where apart from a destination object's ID the JSON may include
/// extra properties. This is best demonstrated with an example:
///
/// "issue": {
///     "id": "1",
///     "title": "Fix the backend",
///     "assigne_id": 100,
///     "assigne_name": "John Smith"
/// }
///
/// Though I have no idea why somebody would do that. Same JSON could also be expressed with a simple relationship:
///
/// "issue": {
///     "id": "1",
///     "title": "Fix the backend",
///     "assignee": {
///         "id": 100,
///         "name": "John Smith"
///     }
/// }
///
/// 4. Relationship with custom destination mapping
///
/// Sometimes it may be necessary to use a different property mapping for the destination object than the canonical
/// mapping defined by its class, perhaps becase some property has a different name in a relationship or for other
/// reasons (i.e. somebody couldn't properly design their server API).
///
/// That is basically what this type of relationship mapping is for. I can't be bothered to write an example here, I
/// think you get the idea by now. Besides, this class description is way longer than I expected.
///
/// \see JSONObjectMapping
///
@interface JSONRelationshipMapping : NSObject

@property (nonatomic, readonly) NSString *relationshipName;
@property (nonatomic, readonly) NSString *JSONKey;
@property (nonatomic, readonly) NSString *destinationEntityName;
@property (nonatomic) JSONObjectMapping *inlineMapping;
@property (nonatomic) JSONObjectMapping *destinationMapping;

+ (instancetype)mappingWithJSONKey:(NSString *)JSONKey;
+ (instancetype)mappingWithJSONKey:(NSString *)JSONKey destinationEntityName:(NSString *)entityName;

- (instancetype)initWithJSONKey:(NSString *)JSONKey;
- (instancetype)initWithJSONKey:(NSString *)JSONKey destinationEntityName:(NSString *)entityName;

@end
