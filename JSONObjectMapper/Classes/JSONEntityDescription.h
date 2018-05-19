#import <CoreData/CoreData.h>

@class JSONObjectMapping;

@interface JSONEntityDescription : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSEntityDescription *managedEntity;
@property (nonatomic, readonly) NSString *primaryKey;
@property (nonatomic, readonly) JSONObjectMapping *defaultMapping;
@property (nonatomic, readonly) Class entityClass;

- (instancetype)initWithManagedEntity:(NSEntityDescription *)managedEntity entityClass:(Class)entityClass;

- (BOOL)validatePrimaryKey:(id)primaryKeyValue;

@end
