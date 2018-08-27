@class JSONObjectMapping;

@protocol JSONMappingProtocol <NSObject>

@optional

/// Returns the default JSON mapping for the class.
///
/// You can use this method as a convenient place to define your mappings in most situations. If you need to use
/// a custom mapping in some cases you can override the default mapping by passing a custom mapping parameter to
/// \c JSONObjectMapper.
///
/// \return The default mapping.
+ (JSONObjectMapping *)defaultMapping;

/// Returns the name of the primary key attribute for the class.
///
/// Although this method is optional, it is a good idea to specify a primary key attribute for each entity in order
/// to avoid creation of duplicate objects.
///
/// \return The name of the primary key attribute.
+ (NSString *)primaryKey;

/// Validates primary key values.
///
/// This method allows you to filter out JSON objects with invalid primary key values (i.e. such objects will be
/// ignored). It may be necessary for dealing with by-ID relationships where the ID may be set to some pre-defined
/// invalid value to indicate the absence of the relationship (i.e. for badly designed web APIs).
///
/// \param primaryKeyValue The primary key value to validate.
///
/// \return \c YES is the value is a valid primary key, \c NO otherwise.
+ (BOOL)validatePrimaryKey:(id)primaryKeyValue;

@end
