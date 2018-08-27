#import <CoreData/CoreData.h>
#import "JSONObjectMapping.h"
#import "JSONRelationshipMapping.h"

extern NSString *const JSONDateTransformerName;

@class JSONObjectMapper;

@protocol JSONObjectMapperDelegate <NSObject>

/// This method is called when a relationship is about to be set to a new value.
///
/// \return If returns \YES, the property will be set to the new value. Otherwise, the property
///         is left unchanged.
- (BOOL)objectMapper:(JSONObjectMapper *)objectMapper
        willSetValue:(id)value
        forAttribute:(NSAttributeDescription *)attribute
            ofObject:(__kindof NSManagedObject *)object;

/// This method is called when a relationship is about to be set to a new value.
///
/// \return If returns \YES, the property will be set to the new value. Otherwise, the property
///         is left unchanged.
- (BOOL)objectMapper:(JSONObjectMapper *)objectMapper
        willSetValue:(id)value
     forRelationship:(NSRelationshipDescription *)relationship
            ofObject:(__kindof NSManagedObject *)object;

@end

/// JSONObjectMapper maps JSON objects and arrays to managed objects.
///
/// \see JSONMappingProtocol
///
@interface JSONObjectMapper : NSObject

/// The managed object context for storing mapped managed objects.
@property (nonatomic) NSManagedObjectContext *managedObjectContext;

/// The delegate.
@property (weak, nonatomic) id<JSONObjectMapperDelegate> delegate;

/// Initializes a \c JSONObjectMapper with the specified managed object context.
///
/// \param managedObjectContext The managed object context that should be used for creating
///        and fetching managed objects during the mapping process.
///
/// \return The newly initialized mapper.
- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

/// Registers a value transformer to use for mapping attributes of types supported by the transformer.
///
/// \param valueTransformer The transformer to register within the receiver.
/// \param name The name under which the transformer is registered. Use the same name as you use in
/// in the entity properties.
- (void)setValueTransformer:(NSValueTransformer *)valueTransformer forName:(NSString *)name;

/// Maps a JSON dictionary to a new or existing managed object.
///
/// \param dictionary The JSON dictionary (an "object" in JSON terms) to map from.
/// \param entityClass The \c NSManagedObject subclass corresponding the the entity to which
///        the JSON object will be mapped.
///
/// \return A managed object to which the JSON was mapped to. This can be an existing managed
///         object, identified by the primary key defined by its entity class, or a new object if
///         no objects exist with such primary key.
- (__kindof NSManagedObject *)mapDictionary:(id)dictionary toEntityClass:(Class)entityClass;

/// Maps a JSON dictionary to an existing managed object.
///
/// \param dictionary The JSON dictionary (an "object" in JSON terms) to map from.
/// \param object An existing managed object to which the JSON dictionary will be mapped.
/// \param mapping An optional mapping to use instead of the default mapping.
- (void)mapDictionary:(id)dictionary toObject:(NSManagedObject *)object mapping:(JSONObjectMapping *)mapping;

/// Maps a JSON array to an array of managed objects.
///
/// \param array The JSON array to map from.
/// \param entityClass The \c NSManagedObject subclass corresponding the the entity to which
///        the JSON object will be mapped.
///
/// \return An array of managed objects to which the JSON array was mapped to. The objects in the
///         array can be existing objects, identified by the primary key defined by the entityt
///         class, or newly created objects.
- (NSArray<__kindof NSManagedObject *> *)mapArray:(id)array toEntityClass:(Class)entityClass;

/// Maps a JSON array to an array of managed objects.
///
/// Unlike -[JSONObjectMapper mapArray:toEntityClass:], this method allows you to
/// specify your own property mapping, i.e. override the canonical property mapping defined by
/// the entity class.
///
/// \param array The JSON array to map from.
/// \param entityClass The \c NSManagedObject subclass corresponding the the entity to which
///        the JSON object will be mapped.
/// \param mapping A property mapping to use for mapping.
///
/// \return An array of managed objects to which the JSON array was mapped to. The objects in the
///         array can be existing objects, identified by the primary key defined by the entityt
///         class, or newly created objects.
- (NSArray<__kindof NSManagedObject *> *)mapArray:(id)array
                                    toEntityClass:(Class)entityClass
                                          mapping:(JSONObjectMapping *)mapping;

@end
