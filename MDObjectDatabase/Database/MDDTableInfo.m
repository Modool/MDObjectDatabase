//
//  MDDTableInfo.m
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/29.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDTableInfo.h"
#import "MDDTableInfo+Private.h"

#import "MDPropertyAttributes.h"

#import "MDDColumn+Private.h"
#import "MDDTableConfiguration+Private.h"
#import "MDDObject.h"
#import "MDDIndex.h"
#import "MDDConditionSet.h"
#import "MDDErrorCode.h"

@implementation MDDTableInfo
@synthesize objectClass = _objectClass, name = _name, primaryProperties = _primaryProperties, propertyColumnMapper = _propertyColumnMapper, columnPropertyMapper = _columnPropertyMapper, columnMapper = _columnMapper;

+ (instancetype)infoWithConfiguration:(MDDTableConfiguration *)configuration error:(NSError **)error;{
    Class<MDDObject> objectClass = [configuration objectClass];
    NSString *name = [configuration name];
    
    NSSet<NSString *> *primaryProperties = [configuration primaryProperties];
    if (!primaryProperties || ![primaryProperties count]) {
        if (error) *error = [NSError errorWithDomain:MDDatabaseErrorDomain code:MDDErrorCodeNonePrimaryProperty userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"None of primary property for table %@ of class %@", name, objectClass]}];
        return nil;
    }
    
    MDDTableInfo *info = [[self alloc] init];
    info->_objectClass = objectClass;
    info->_name = [name copy];
    info->_primaryProperties = [primaryProperties copy];
    
    BOOL autoincrement = [configuration autoincrement];
    NSDictionary *propertyMapper = [configuration propertyMapper];
    NSSet<MDPropertyAttributes *> *attributes = nil;
    if ([propertyMapper count]) {
        attributes = [NSSet setWithArray:MDPropertyAttributesNamed(objectClass, [propertyMapper allKeys])];
    } else {
        attributes = [NSSet setWithArray:MDPropertyAttributesForClass(objectClass, NO)];
        NSArray<MDPropertyAttributes *> *attributesArray = [attributes allObjects];
        NSArray<NSString *> *names = [attributesArray valueForKey:@MDDKeyPath(MDPropertyAttributes, name)];
        propertyMapper = [NSDictionary dictionaryWithObjects:names forKeys:names];
    }
    
    NSMutableDictionary<NSString *, MDDColumn *> *columnMapper = [[NSMutableDictionary alloc] init];
    for (MDPropertyAttributes *attribute  in attributes) {
        NSString *propertyName = [attribute name];
        NSString *columnName = propertyMapper[propertyName];
        BOOL primary = [primaryProperties containsObject:propertyName];
        
        MDDColumn *column = [MDDColumn columnWithName:columnName propertyName:propertyName primary:primary autoincrement:(primary && autoincrement) attribute:attribute tableInfo:info];
        column.configuration = configuration.columnConfigurations[propertyName];
        
        if (!column) {
            if (error) *error = [NSError errorWithDomain:MDDatabaseErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to reference property %@ with column %@ for table %@ of class %@", propertyName, columnName, name, objectClass]}];
            return nil;
        }
        columnMapper[columnName] = column;
    }
    
    NSArray<MDDIndex *> *indexes = [configuration indexes];
    NSArray<NSString *> *indexNames = [indexes valueForKey:@MDDKeyPath(MDDIndex, name)];
    NSDictionary *indexesMapping = [NSDictionary dictionaryWithObjects:indexes forKeys:indexNames];
    
    info->_columnMapper = [columnMapper copy];
    info->_indexMapper = [indexesMapping copy];
    info->_propertyColumnMapper = [propertyMapper copy];
    info->_columnPropertyMapper = [NSDictionary dictionaryWithObjects:[propertyMapper allKeys] forKeys:[propertyMapper allValues]];
    
    return info;
}

- (NSUInteger)hash{
    return [[self objectClass] hash] ^ [[self name] hash];
}

- (BOOL)isEqual:(MDDTableInfo *)object{
    if ([super isEqual:object]) return YES;
    if (![object isKindOfClass:[MDDTableInfo class]]) return NO;
    
    return [self objectClass] == [object objectClass] && [[self name] isEqualToString:[object name]];
}

- (NSString *)description{
    return [[self dictionaryWithValuesForKeys:@[@"objectClass", @"name", @"primaryProperties", @"columnMapper", @"indexMapper", @"propertyColumnMapper"]] description];
}

#pragma mark - accessor

- (NSArray<NSString *> *)columnNames{
    return [[self columnMapper] allKeys];
}

- (NSArray<MDDColumn *> *)columns{
    return [[self columnMapper] allValues];
}

- (NSArray<NSString *> *)indexNames{
    return [[self indexMapper] allKeys];
}

- (NSArray<MDDIndex *> *)indexes{
    return [[self indexMapper] allValues];
}

#pragma mark - protected

- (MDDColumn *)columnForProperty:(id)property;{
    NSSet<NSString *> *primaryProperties = [self primaryProperties];
    NSParameterAssert([primaryProperties count]);
    NSParameterAssert([primaryProperties count] == 1 || ([primaryProperties count] > 1 && (property && (id)property != [NSNull null])));
    
    if ((!property || property == [NSNull null]) && [primaryProperties count] == 1) {
        property = [primaryProperties anyObject];
    }
    NSParameterAssert(property);
    NSString *columnName = self.propertyColumnMapper[property];
    
    MDDColumn *column = self.columnMapper[columnName];
    NSParameterAssert(column);
    
    return column;
}

- (MDDIndex *)indexForPropertys:(NSSet<NSString *> *)property;{
    NSParameterAssert(property && [property count]);
    
    for (MDDIndex *index in [self indexes]) {
        if ([[index propertyNames] isEqual:property]) return index;
    }
    return nil;
}

- (MDDIndex *)indexForConditionSet:(MDDConditionSet *)conditionSet;{
    NSParameterAssert(conditionSet);
    NSArray *allKeys = [conditionSet allPropertysIgnoreMultipleTable:YES];
    if (![allKeys count]) return nil;
    
    NSMutableSet<NSString *> *properties = [NSMutableSet set];
    for (id property in allKeys) {
        NSString *keyString = property;
        if ((!property || property == [NSNull null]) && [[self primaryProperties] count] == 1) {
            keyString = [[self primaryProperties] anyObject];
        }
        
        [properties addObject:keyString];
    }
    return [self indexForPropertys:properties];
}

#pragma mark - private

+ (NSArray<MDPropertyAttributes *> *)_attributes:(NSArray<MDPropertyAttributes *> *)attributes fitlerByPropertyNames:(NSArray<NSString *> *)propertyNames{
    NSMutableDictionary<NSString *, MDPropertyAttributes *> *properties = [NSMutableDictionary<NSString *, MDPropertyAttributes *> dictionary];
    
    for (MDPropertyAttributes *attribute in attributes) {
        NSParameterAssert([attribute name]);
        
        if (![propertyNames containsObject:[attribute name]]) continue;
        if ([[properties allKeys] containsObject:[attribute name]]) continue;
        
        properties[[attribute name]] = attribute;
    }
    return [properties allValues];
}

@end
