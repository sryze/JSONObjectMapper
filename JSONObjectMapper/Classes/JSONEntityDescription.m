#import "JSONEntityDescription.h"
#import "JSONMappingProtocol.h"
#import "JSONObjectMapping.h"

@implementation JSONEntityDescription

+ (JSONObjectMapping *)objectMappingForEntityClass:(Class)entityClass {
    if ([(id)entityClass respondsToSelector:@selector(defaultMapping)]) {
        return [(id)entityClass defaultMapping];
    }
    return nil;
}

+ (NSString *)primaryKeyForEntityClass:(Class)entityClass {
    if ([(id)entityClass respondsToSelector:@selector(primaryKey)]) {
        return [(id)entityClass primaryKey];
    }
    return nil;
}

- (instancetype)initWithManagedEntity:(NSEntityDescription *)managedEntity entityClass:(Class)entityClass {
    if (self = [super init]) {
        _name = managedEntity.name;
        _managedEntity = managedEntity;
        _primaryKey = [JSONEntityDescription primaryKeyForEntityClass:entityClass];
        _defaultMapping = [JSONEntityDescription objectMappingForEntityClass:entityClass];
        _entityClass = entityClass;
    }
    return self;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@ (name: %@, managedEntity: %@, primaryKey: %@, defaultMapping: %@, entityClass: %@)",
            super.debugDescription,
            self.name.debugDescription,
            self.managedEntity.debugDescription,
            self.primaryKey.debugDescription,
            self.defaultMapping.debugDescription,
            self.entityClass];
}

- (BOOL)validatePrimaryKey:(id)primaryKeyValue {
    if ([self.entityClass respondsToSelector:@selector(validatePrimaryKey:)]) {
        return [self.entityClass validatePrimaryKey:primaryKeyValue];
    }
    return YES;
}

@end
