//
//  MDDViewConfiguration.m
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/30.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDViewConfiguration.h"
#import "MDDColumn.h"
#import "MDDErrorCode.h"
#import "MDDMacros.h"

@interface MDDViewConfiguration ()

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, MDDColumn *> *mutablePropertyColumns;

@end

@implementation MDDViewConfiguration

+ (instancetype)configurationWithClass:(Class<MDDObject>)class;{
    NSParameterAssert(class);
    return [self configurationWithClass:class name:NSStringFromClass(class)];
}

+ (instancetype)configurationWithClass:(Class<MDDObject>)class name:(NSString *)name;{
    NSParameterAssert(class && [name length]);
    return [self configurationWithClass:class name:name propertyMapper:nil];
}

+ (instancetype)configurationWithClass:(Class<MDDObject>)class name:(NSString *)name propertyMapper:(NSDictionary<NSString *, NSString *> *)propertyMapper;{
    NSParameterAssert(class && [name length]);
    return [self configurationWithClass:class name:name propertyMapper:propertyMapper propertyColumns:nil];
}

+ (instancetype)configurationWithClass:(Class<MDDObject>)class name:(NSString *)name propertyMapper:(NSDictionary<NSString *, NSString *> *)propertyMapper propertyColumns:(NSDictionary<NSString *, MDDColumn *> *)propertyColumns;{
    return [self configurationWithClass:class name:name propertyMapper:propertyMapper propertyColumns:propertyColumns conditionSet:nil];
}

+ (instancetype)configurationWithClass:(Class<MDDObject>)class name:(NSString *)name propertyMapper:(NSDictionary<NSString *, NSString *> *)propertyMapper propertyColumns:(NSDictionary<NSString *, MDDColumn *> *)propertyColumns conditionSet:(MDDConditionSet *)conditionSet;{
    NSParameterAssert(class && [name length]);
    MDDViewConfiguration *configuration = [[self alloc] init];
    
    configuration->_objectClass = class;
    configuration->_name = [name copy];
    configuration->_propertyMapper = [propertyMapper copy];
    configuration->_mutablePropertyColumns = [NSMutableDictionary dictionaryWithDictionary:propertyColumns ?: @{}];
    configuration->_conditionSet = conditionSet;
    
    return configuration;
}

#pragma mark - accessor

- (NSDictionary<NSString *,MDDColumn *> *)propertyColumns{
    return [[self mutablePropertyColumns] copy];
}

#pragma mark - public

- (BOOL)addColumn:(MDDColumn *)column asPropertyNamed:(NSString *)asPropertyName error:(NSError **)error;{
    NSParameterAssert(column && [asPropertyName length]);
    MDDColumn *existColumn = [[self mutablePropertyColumns] objectForKey:asPropertyName];
    if (existColumn) {
        if (*error) *error = [NSError errorWithDomain:MDDatabaseErrorDomain code:MDDErrorCodeViewColumnExist userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to add column: %@ as property: %@ for view: %@, because of the column is existed.", column, asPropertyName, _name]}];
        return NO;
    }
    self.mutablePropertyColumns[asPropertyName] = column;
    
    return YES;
}

@end
