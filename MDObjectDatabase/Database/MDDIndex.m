//
//  MDDIndex.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/5.
//  Copyright © 2018年 modool. All rights reserved.
//

#import "MDDIndex.h"
#import "MDDIndex+Private.h"

#import "MDDTableInfo.h"
#import "MDDColumn.h"

NSString * const MDDatabaseCreateIndexSQL = @"CREATE %@ INDEX %@ on %@(%@)";
NSString * const MDDatabaseDropIndexSQL = @"DROP INDEX %@";

const NSUInteger MDDIndexMaximumPropertyNumber = 6;

@implementation MDDIndex

- (NSUInteger)hash{
    return [[self name] hash];
}

- (BOOL)isEqual:(MDDIndex *)object{
    if ([super isEqual:object]) return YES;
    if (self == object) return YES;
    if (![object isKindOfClass:[MDDIndex class]]) return NO;
    
    return [[object name] isEqual:[self name]];
}

+ (instancetype)indexWithPropertyName:(NSString *)propertyName;{
    return [self indexWithPropertyName:propertyName unique:NO];
}

+ (instancetype)indexWithPropertyName:(NSString *)propertyName unique:(BOOL)unique;{
    return [self indexWithName:nil propertyName:propertyName unique:unique];
}

+ (instancetype)indexWithName:(NSString *)name propertyName:(NSString *)propertyName;{
    return [self indexWithName:name propertyName:propertyName unique:NO];
}

+ (instancetype)indexWithName:(NSString *)name propertyName:(NSString *)propertyName unique:(BOOL)unique;{
    NSParameterAssert([name length] && [propertyName length]);
    MDDIndex *index = [[self alloc] init];
    index->_name = [name copy];
    index->_propertyNames = [NSSet setWithObject:propertyName];
    index->_unique = unique;
    
    return index;
}

+ (instancetype)indexWithPropertyNames:(NSSet<NSString *> *)propertyNames{
    return [self indexWithName:nil propertyNames:propertyNames];
}

+ (instancetype)indexWithName:(NSString *)name propertyNames:(NSSet<NSString *> *)propertyNames;{
    NSParameterAssert([name length] && [propertyNames count] && [propertyNames count] <= MDDIndexMaximumPropertyNumber);
    MDDIndex *index = [[self alloc] init];
    index->_name = [name copy];
    index->_propertyNames = [propertyNames copy];
    
    return index;
}

- (void)setTableInfo:(MDDTableInfo *)tableInfo{
    if (_tableInfo != tableInfo) {
        _tableInfo = tableInfo;
        _tableName = [tableInfo tableName];
        
        NSMutableArray<NSString *> *columnNames = [NSMutableArray array];
        for (NSString *propertyName in _propertyNames) {
            MDDColumn *column = [tableInfo columnForKey:propertyName];
            [columnNames addObject:[column name]];
        }
        _columnNames = [columnNames copy];
        _name = _name ?: [NSString stringWithFormat:@"index_of_%@_%@", _tableName, [columnNames componentsJoinedByString:@"_"]];
        
        //    @"CREATE %@ INDEX %@ on %@ (%@)"
        _creatingSQL = [NSString stringWithFormat:MDDatabaseCreateIndexSQL, _unique ? @"UNIQUE" : @"", _name, [tableInfo tableName], [columnNames componentsJoinedByString:@", "]];
    }
}

- (NSString *)description{
    return [[self dictionaryWithValuesForKeys:@[@"tableName", @"columnNames", @"creatingSQL"]] description];
}

@end

@implementation MDDLocalIndex
@synthesize droppingSQL = _droppingSQL;

- (NSUInteger)hash{
    return [[self name] hash];
}

- (BOOL)isEqual:(MDDLocalIndex *)object{
    if ([super isEqual:object]) return YES;
    if (self == object) return YES;
    if (![object isKindOfClass:[MDDLocalIndex class]]) return NO;
    
    return [[object name] isEqual:[self name]];
}

+ (instancetype)indexWithName:(NSString *)name tableName:(NSString *)tableName SQL:(NSString *)SQL;{
    NSParameterAssert([name length] && [tableName length] && [SQL length]);
    MDDLocalIndex *index = [[self alloc] init];
    index->_name = [name copy];
    index->_tableName = [tableName copy];
    index->_SQL = [SQL copy];
    
    return index;
}

- (NSString *)droppingSQL{
    if (!_droppingSQL) {
        _droppingSQL = [NSString stringWithFormat:MDDatabaseDropIndexSQL, _name];
    }
    return _droppingSQL;
}

- (NSString *)description{
    return [[self dictionaryWithValuesForKeys:@[@"tableName", @"columnNames", @"creatingSQL", @"droppingSQL"]] description];
}

@end
