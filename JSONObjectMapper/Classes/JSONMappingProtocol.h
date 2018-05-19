@class JSONObjectMapping;

/// The protocol to which NSManagedObject subclasses should conform to allow their instances to be
/// mapped from incoming JSON data.
///
/// \see JSONObjectMapper
///
@protocol JSONMappingProtocol <NSObject>

@optional

/// Returns the property mapping to be used to map incoming JSON to managed objects.
///
/// \return The default property mapping for entities of this class.
+ (JSONObjectMapping *)defaultMapping;

/// Returns the name of the primary key attribute.
///
/// \return The name of entity's primary key.
+ (NSString *)primaryKey;

/// Validates values of entity's primary keys.
///
/// This method allows you to filter out JSON objects with invalid primary key values. Such objects
/// get discarded by the JSON mapper.
///
/// This usually may happen with ID key relationships where the returned ID takes some pre-defined
/// invalid value to indicate the absence of the relationship.
///
/// \param primaryKeyValue The primary value to validate.
///
/// \return \c YES is the value is a valid primary key, \c NO otherwise.
+ (BOOL)validatePrimaryKey:(id)primaryKeyValue;

@end
