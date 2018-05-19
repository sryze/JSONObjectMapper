#import <Foundation/Foundation.h>

@interface NSDictionary (JSONKeyPath)

/// Safely extract a value from a dictionary with one or more levels of indirection returning nil
/// if the operation can't be performed (unlike the built-in \c valueForKePath: which would throw
/// an exception).
///
/// Current implementation supports only simple key paths like:
///
/// \c "key"
/// \c "key1.key2.key3"
///
/// Anything else may cause problems.
///
/// \param keyPath The key dot-separated path to get value at.
///
/// \return The value located at the specified key path or \c nil if one of the path components is
///         not found.
- (id)valueForJSONKeyPath:(NSString *)keyPath;

@end
