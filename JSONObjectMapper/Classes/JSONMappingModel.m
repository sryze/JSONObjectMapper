#import "JSONEntityDescription.h"
#import "JSONMappingModel.h"
#import "JSONMappingProtocol.h"

static Class ClassFromEntity(NSEntityDescription *entity) {
    return NSClassFromString(entity.managedObjectClassName);
}

@interface JSONMappingModel ()

@property (nonatomic) NSMutableArray<JSONEntityDescription *> *mutableEntities;
@property (nonatomic) NSMutableDictionary<NSString *, JSONEntityDescription *> *mutableEntitiesByName;

@end

@implementation JSONMappingModel

- (instancetype)initWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel {
    if (self = [super init]) {
        _mutableEntities = [NSMutableArray array];
        _mutableEntitiesByName = [NSMutableDictionary dictionary];

        for (NSEntityDescription *managedEntity in managedObjectModel.entities) {
            Class entityClass = ClassFromEntity(managedEntity);
            NSAssert(entityClass != nil, @"Could not find class for entity \"%@\"", managedEntity.name);
            
            if (![entityClass conformsToProtocol:@protocol(JSONMappingProtocol)]) {
                continue;
            }

            JSONEntityDescription *JSONEntity = [[JSONEntityDescription alloc] initWithManagedEntity:managedEntity
                                                                                         entityClass:entityClass];
            [_mutableEntities addObject:JSONEntity];
            _mutableEntitiesByName[JSONEntity.name] = JSONEntity;
        }
    }
    return self;
}

- (NSArray<JSONEntityDescription *> *)entities {
    return [self.mutableEntities copy];
}

- (NSDictionary<NSString *, JSONEntityDescription *> *)entitiesByName {
    return [self.mutableEntitiesByName copy];
}

- (JSONEntityDescription *)entityForClass:(Class)entityClass {
    return self.mutableEntitiesByName[NSStringFromClass(entityClass)];
}

- (JSONEntityDescription *)entityForManagedEntity:(NSEntityDescription *)managedEntity {
    return self.mutableEntitiesByName[managedEntity.name];
}

@end
