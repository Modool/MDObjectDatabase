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
#import "MDDConfiguration+Private.h"
#import "MDDObject.h"
#import "MDDIndex.h"
#import "MDDConditionSet.h"
#import "MDDErrorCode.h"

@implementation MDDTableInfo

+ (instancetype)infoWithConfiguration:(MDDConfiguration *)configuration error:(NSError **)error;{
    Class<MDDObject> class = [configuration objectClass];
    NSString *tableName = [configuration tableName];
    
    NSSet<NSString *> *primaryProperties = [configuration primaryProperties];
    if (!primaryProperties || ![primaryProperties count]) {
        if (error) *error = [NSError errorWithDomain:MDDatabaseErrorDomain code:MDDErrorCodeNonePrimaryKey userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"None of primary keys for table %@ of class %@", tableName, class]}];
        return nil;
    }
    BOOL autoincrement = [configuration autoincrement];
    NSDictionary *propertyMapper = [configuration propertyMapper];
    NSSet<MDPropertyAttributes *> *attributes = nil;
    if ([propertyMapper count]) {
        attributes = [NSSet setWithArray:MDPropertyAttributesNamed(class, [propertyMapper allKeys])];
    } else {
        attributes = [NSSet setWithArray:MDPropertyAttributesForClass(class, NO)];
        NSArray<MDPropertyAttributes *> *attributesArray = [attributes allObjects];
        NSArray<NSString *> *names = [attributesArray valueForKey:@"name"];
        propertyMapper = [NSDictionary dictionaryWithObjects:names forKeys:names];
    }
    
    NSMutableDictionary<NSString *, MDDColumn *> *columnMapper = [[NSMutableDictionary alloc] init];
    for (MDPropertyAttributes *attribute  in attributes) {
        NSString *propertyName = [attribute name];
        NSString *columnName = propertyMapper[propertyName];
        BOOL primary = [primaryProperties containsObject:propertyName];
        
        MDDColumn *column = [MDDColumn columnWithName:columnName propertyName:propertyName primary:primary autoincrement:(primary && autoincrement) attribute:attribute];
        column.configuration = configuration.columnConfigurations[propertyName];
        
        if (!column) {
            if (error) *error = [NSError errorWithDomain:MDDatabaseErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to reference property %@ with column %@ for table %@ of class %@", propertyName, columnName, tableName, class]}];
            return nil;
        }
        columnMapper[columnName] = column;
    }
    
    NSArray<MDDIndex *> *indexes = [configuration indexes];
    NSArray<NSString *> *indexNames = [indexes valueForKey:@"name"];
    NSDictionary *indexesMapping = [NSDictionary dictionaryWithObjects:indexes forKeys:indexNames];
    
    MDDTableInfo *info = [[self alloc] init];
    
    info->_objectClass = class;
    info->_tableName = [tableName copy];
    info->_primaryProperties = [primaryProperties copy];
    
    info->_columnMapper = [columnMapper copy];
    info->_indexMapper = [indexesMapping copy];
    info->_propertyColumnMapper = [propertyMapper copy];
    info->_columnPropertyMapper = [NSDictionary dictionaryWithObjects:[propertyMapper allKeys] forKeys:[propertyMapper allValues]];
    
    return info;
}

- (NSUInteger)hash{
    return [[self objectClass] hash] ^ [[self tableName] hash];
}

- (BOOL)isEqual:(MDDTableInfo *)object{
    if ([super isEqual:object]) return YES;
    if (![object isKindOfClass:[MDDTableInfo class]]) return NO;
    
    return [self objectClass] == [object objectClass] && [[self tableName] isEqualToString:[object tableName]];
}

- (NSString *)description{
    return [[self dictionaryWithValuesForKeys:@[@"objectClass", @"tableName", @"primaryProperties", @"columnMapper", @"indexMapper", @"propertyColumnMapper"]] description];
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

- (MDDColumn *)columnForKey:(id)key;{
    NSSet<NSString *> *primaryProperties = [self primaryProperties];
    NSParameterAssert([primaryProperties count]);
    NSParameterAssert([primaryProperties count] == 1 || ([primaryProperties count] > 1 && (key && (id)key != [NSNull null])));
    
    if ((!key || key == [NSNull null]) && [primaryProperties count] == 1) {
        key = [primaryProperties anyObject];
    }
    NSParameterAssert(key);
    NSString *columnName = self.propertyColumnMapper[key];
    
    MDDColumn *column = self.columnMapper[columnName];
    NSParameterAssert(column);
    
    return column;
}

- (MDDIndex *)indexForKeys:(NSSet<NSString *> *)keys;{
    NSParameterAssert(keys && [keys count]);
    
    for (MDDIndex *index in [self indexes]) {
        if ([[index propertyNames] isEqual:keys]) return index;
    }
    return nil;
}

- (MDDIndex *)indexForConditionSet:(MDDConditionSet *)conditionSet;{
    NSParameterAssert(conditionSet);
    NSArray *allKeys = [conditionSet allKeysIgnoreMultipleTable:YES];
    if (![allKeys count]) return nil;
    
    NSMutableSet<NSString *> *keys = [NSMutableSet set];
    for (id key in allKeys) {
        NSString *keyString = key;
        if ((!key || key == [NSNull null]) && [[self primaryProperties] count] == 1) {
            keyString = [[self primaryProperties] anyObject];
        }
        
        [keys addObject:keyString];
    }
    return [self indexForKeys:keys];
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
