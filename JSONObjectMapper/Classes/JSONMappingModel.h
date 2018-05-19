#import <CoreData/CoreData.h>

@class JSONEntityDescription;

@interface JSONMappingModel : NSObject

@property (nonatomic, readonly) NSArray<JSONEntityDescription *> *entities;
@property (nonatomic, readonly) NSDictionary<NSString *, JSONEntityDescription *> *entitiesByName;

- (instancetype)initWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel;

- (JSONEntityDescription *)entityForClass:(Class)entityClass;
- (JSONEntityDescription *)entityForManagedEntity:(NSEntityDescription *)managedEntity;

@end
