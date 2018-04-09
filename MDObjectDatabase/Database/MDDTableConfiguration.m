//
//  MDDTableConfiguration.m
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/25.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDTableConfiguration.h"
#import "MDDTableConfiguration+Private.h"
#import "MDDErrorCode.h"

@implementation MDDTableConfiguration

+ (instancetype)configurationWithClass:(Class<MDDObject>)class primaryProperty:(NSString *)primaryProperty;{
    NSParameterAssert(class && primaryProperty);
    return [self configurationWithClass:class propertyMapper:nil primaryProperty:primaryProperty];
}

+ (instancetype)configurationWithClass:(Class<MDDObject>)class propertyMapper:(NSDictionary *)propertyMapper primaryProperty:(NSString *)primaryProperty;{
    return [self configurationWithClass:class name:NSStringFromClass(class) propertyMapper:propertyMapper primaryProperty:primaryProperty];
}

+ (instancetype)configurationWithClass:(Class<MDDObject>)class name:(NSString *)name propertyMapper:(NSDictionary *)propertyMapper primaryProperty:(NSString *)primaryProperty;{
    return [self configurationWithClass:class name:name propertyMapper:propertyMapper autoincrement:YES primaryProperty:primaryProperty];
}

+ (instancetype)configurationWithClass:(Class<MDDObject>)class name:(NSString *)name propertyMapper:(NSDictionary *)propertyMapper autoincrement:(BOOL)autoincrement primaryProperty:(NSString *)primaryProperty;{
    return [self configurationWithClass:class name:name propertyMapper:propertyMapper autoincrement:autoincrement primaryProperty:primaryProperty indexes:nil];
}

+ (instancetype)configurationWithClass:(Class<MDDObject>)class name:(NSString *)name propertyMapper:(NSDictionary *)propertyMapper autoincrement:(BOOL)autoincrement primaryProperty:(NSString *)primaryProperty indexes:(NSArray<MDDIndex *> *)indexes;{
    MDDTableConfiguration *configuration = [[self alloc] init];
    configuration->_objectClass = class;
    configuration->_name = [name copy];
    configuration->_propertyMapper = [propertyMapper copy];
    configuration->_autoincrement = autoincrement;
    configuration->_primaryProperties = primaryProperty ? [NSSet setWithObject:primaryProperty] : nil;
    configuration->_indexes = [indexes copy];
    return configuration;
}

+ (instancetype)configurationWithClass:(Class<MDDObject>)class primaryProperties:(NSSet<NSString *> *)primaryProperties;{
    return [self configurationWithClass:class propertyMapper:nil primaryProperties:primaryProperties];
}

+ (instancetype)configurationWithClass:(Class<MDDObject>)class propertyMapper:(NSDictionary *)propertyMapper primaryProperties:(NSSet<NSString *> *)primaryProperties;{
    return [self configurationWithClass:class name:NSStringFromClass(class) propertyMapper:propertyMapper primaryProperties:primaryProperties];
}

+ (instancetype)configurationWithClass:(Class<MDDObject>)class name:(NSString *)name propertyMapper:(NSDictionary *)propertyMapper primaryProperties:(NSSet<NSString *> *)primaryProperties;{
    return [self configurationWithClass:class name:name propertyMapper:propertyMapper primaryProperties:primaryProperties indexes:nil];
}

+ (instancetype)configurationWithClass:(Class<MDDObject>)class name:(NSString *)name propertyMapper:(NSDictionary *)propertyMapper primaryProperties:(NSSet<NSString *> *)primaryProperties indexes:(NSArray<MDDIndex *> *)indexes;{
    MDDTableConfiguration *configuration = [[self alloc] init];
    configuration->_objectClass = class;
    configuration->_name = [name copy];
    configuration->_propertyMapper = [propertyMapper copy];
    configuration->_primaryProperties = [primaryProperties copy];
    configuration->_indexes = [indexes copy];
    return configuration;
}

- (BOOL)addColumnConfiguration:(MDDColumnConfiguration *)columnConfiguration forProperty:(NSString *)property error:(NSError **)error;{
    NSParameterAssert(columnConfiguration && [property length]);
    if ([[self columnConfigurations] objectForKey:property]) {
        if (error) *error = [NSError errorWithDomain:MDDatabaseErrorDomain code:MDDErrorCodeColumnConfigurationExisted userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Exist column configuration for property %@ of table: %@", property, _name]}];
        return NO;
    }
    self.columnConfigurations[property] = columnConfiguration;
    return YES;
}

- (NSString *)description{
    return [[self dictionaryWithValuesForKeys:@[@"objectClass", @"name", @"propertyMapper", @"autoincrement", @"primaryProperty", @"indexes", @"primaryProperties"]] description];
}

@end
