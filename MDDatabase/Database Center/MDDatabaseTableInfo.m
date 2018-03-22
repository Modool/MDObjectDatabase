//
//  MDDatabaseTableInfo.m
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/29.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDatabaseTableInfo.h"

#import "MDPropertyAttributes.h"

#import "MDDatabaseColumn+Private.h"
#import "MDDatabaseDescriptor+Private.h"
#import "MDDatabaseObject.h"

@interface MDDatabaseTableInfo ()

@property (nonatomic, copy, readonly) NSDictionary<NSString *, MDDatabaseColumn *> *columnMapping;

@property (nonatomic, copy, readonly) NSDictionary<NSString *, MDDatabaseIndex *> *indexeMapping;

@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *propertyMapping;

@end

@implementation MDDatabaseTableInfo

+ (instancetype)infoWithTableName:(NSString *)tableName class:(Class)class error:(NSError **)error;{
    if (![class respondsToSelector:@selector(primaryProperty)] && ![class respondsToSelector:@selector(primaryProperties)]) {
        if (error) *error = [NSError errorWithDomain:MDDatabaseErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Class %@ didn't respond selector %@ or %@", class, NSStringFromSelector(@selector(primaryProperty)), NSStringFromSelector(@selector(primaryProperties))]}];
        return nil;
    }
    
    NSSet<NSString *> *primaryProperties = [class respondsToSelector:@selector(primaryProperties)] ? [class primaryProperties] : nil;
    primaryProperties = [class respondsToSelector:@selector(primaryProperty)] ? ([class primaryProperty] ? [NSSet setWithObject:[class primaryProperty]] : nil) : primaryProperties;
    if (!primaryProperties || ![primaryProperties count]) {
        if (error) *error = [NSError errorWithDomain:MDDatabaseErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"None of primary keys for table %@ of class %@", tableName, class]}];
        return nil;
    }
    
    BOOL respondAutoincrement = [class respondsToSelector:@selector(autoincrement)];
    BOOL autoincrement = respondAutoincrement ? ([class autoincrement] && primaryProperties && [primaryProperties count] == 1) : NO;
    
    BOOL respondMapping = [class respondsToSelector:@selector(tableMapping)];
    NSArray<MDPropertyAttributes *> *attributes = MDPropertyAttributesForClass(class, respondMapping);
    NSDictionary *propertyMapping = nil;
    if (respondMapping) {
        propertyMapping = [class tableMapping];
        attributes = [self _attributes:attributes fitlerByPropertyNames:[propertyMapping allKeys]];
    } else {
        propertyMapping = [self _propertyMappingFromPropertyAttributes:attributes];
    }
    
    NSMutableDictionary<NSString *, MDDatabaseColumn *> *columnMapping = [[NSMutableDictionary alloc] init];
    for (MDPropertyAttributes *attribute  in attributes) {
        NSString *propertyName = [attribute name];
        NSString *columnName = propertyMapping[propertyName];
        BOOL primary = [primaryProperties containsObject:propertyName];
        
        MDDatabaseColumn *column = [MDDatabaseColumn columnWithName:columnName propertyName:propertyName primary:primary autoincrement:(primary && autoincrement) attribute:attribute];
        if (!column) {
            if (error) *error = [NSError errorWithDomain:MDDatabaseErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to reference property %@ with column %@ for table %@ of class %@", propertyName, columnName, tableName, class]}];
            return nil;
        }
        
        columnMapping[propertyName] = column;
    }
    
    NSArray<MDDatabaseIndex *> *indexes = [class respondsToSelector:@selector(indexes)] ? [class indexes] : nil;
    NSArray<NSString *> *indexNames = [indexes valueForKey:@"name"];
    NSDictionary *indexesMapping = [NSDictionary dictionaryWithObjects:indexes forKeys:indexNames];
    
    MDDatabaseTableInfo *info = [self new];
    
    info->_class = class;
    info->_tableName = tableName;
    info->_primaryProperties = [primaryProperties copy];
    
    info->_columnMapping = [columnMapping copy];
    info->_indexeMapping = [indexesMapping copy];
    info->_propertyMapping = [propertyMapping copy];
    
    return info;
}

#pragma mark - accessor

- (NSArray<NSString *> *)columnNames{
    return [[self columnMapping] allKeys];
}

- (NSArray<MDDatabaseColumn *> *)columns{
    return [[self columnMapping] allValues];
}

- (NSArray<NSString *> *)indexNames{
    return [[self indexeMapping] allKeys];
}

- (NSArray<MDDatabaseIndex *> *)indexes{
    return [[self indexeMapping] allValues];
}

#pragma mark - protected

- (MDDatabaseColumn *)columnForKey:(id)key;{
    NSSet<NSString *> *primaryProperties = [self primaryProperties];
    NSParameterAssert([primaryProperties count]);
    NSParameterAssert([primaryProperties count] == 1 || ([primaryProperties count] > 1 && (key && (id)key != [NSNull null])));
    
    if ((!key || key == [NSNull null]) && [primaryProperties count] == 1) {
        key = [primaryProperties anyObject];
    }
    NSParameterAssert(key);
    
    MDDatabaseColumn *column = self.columnMapping[key];
    NSParameterAssert(column);
    
    return column;
}

- (MDDatabaseIndex *)indexForKeys:(NSSet<NSString *> *)keys;{
    NSParameterAssert(keys && [keys count]);
    
    for (MDDatabaseIndex *index in [self indexes]) {
        if ([[index propertyNames] isEqual:keys]) return index;
    }
    return nil;
}

- (MDDatabaseIndex *)indexForConditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;{
    NSParameterAssert(conditions && [conditions count]);
    NSMutableSet<NSString *> *keys = [NSMutableSet new];
    for (MDDatabaseConditionDescriptor *condition in conditions) {
        id key = [condition key];
        if ((!key || key == [NSNull null]) && [[self primaryProperties] count] == 1) {
            key = [[self primaryProperties] anyObject];
        }
        
        [keys addObject:key];
    }
    return [self indexForKeys:keys];
}

#pragma mark - private

+ (NSDictionary *)_propertyMappingFromPropertyAttributes:(NSArray<MDPropertyAttributes *> *)attributes {
    NSMutableDictionary<NSString *, NSString *> *mapping = [NSMutableDictionary<NSString *, NSString *> new];
    
    for (MDPropertyAttributes *attribute in attributes) {
        NSString *propertyName = [attribute name];
        NSParameterAssert(propertyName);
        
        if ([[mapping allKeys] containsObject:[attribute name]]) continue;
        
        mapping[propertyName] = propertyName;
    }
    
    return [mapping copy];
}

+ (NSArray<MDPropertyAttributes *> *)_attributes:(NSArray<MDPropertyAttributes *> *)attributes fitlerByPropertyNames:(NSArray<NSString *> *)propertyNames{
    NSMutableDictionary<NSString *, MDPropertyAttributes *> *properties = [NSMutableDictionary<NSString *, MDPropertyAttributes *> new];
    
    for (MDPropertyAttributes *attribute in attributes) {
        NSParameterAssert([attribute name]);
        
        if (![propertyNames containsObject:[attribute name]]) continue;
        if ([[properties allKeys] containsObject:[attribute name]]) continue;
        
        properties[[attribute name]] = attribute;
    }
    return [properties allValues];
}

@end
