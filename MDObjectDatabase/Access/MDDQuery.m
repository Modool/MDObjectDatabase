//
//  MDDQuery.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDQuery.h"
#import "MDDQuery+Private.h"
#import "MDDColumn.h"
#import "MDDTableInfo.h"
#import "MDDIndex.h"
#import "MDDItem.h"
#import "MDDDescription.h"
#import "MDDRange.h"
#import "MDDSort.h"
#import "MDDConditionSet+Private.h"

@implementation MDDQuery
@dynamic tableInfo;

+ (instancetype)queryWithSorts:(NSArray<MDDSort *> *)sorts;{
    return [self queryWithPropertys:nil conditionSet:nil sorts:sorts];
}

+ (instancetype)queryWithSorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range;{
    return [self queryWithPropertys:nil conditionSet:nil sorts:nil range:range];
}

+ (instancetype)queryWithConditionSet:(MDDConditionSet *)conditionSet;{
    return [self queryWithPropertys:nil conditionSet:conditionSet sorts:nil];
}

+ (instancetype)queryWithConditionSet:(MDDConditionSet *)conditionSet range:(NSRange)range;{
    return [self queryWithPropertys:nil conditionSet:conditionSet sorts:nil range:range];
}

+ (instancetype)queryWithProperty:(MDDItem *)property;{
    NSParameterAssert(property);
    return [self queryWithPropertys:[NSSet setWithObject:property]];
}

+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property;{
    return [self queryWithPropertys:property conditionSet:nil sorts:nil];
}

+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property range:(NSRange)range;{
    return [self queryWithPropertys:property conditionSet:nil sorts:nil range:range];
}

+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property sorts:(NSArray<MDDSort *> *)sorts;{
    return [self queryWithPropertys:property conditionSet:nil sorts:sorts];
}

+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range;{
    return [self queryWithPropertys:property conditionSet:nil sorts:sorts range:range];
}

+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property conditionSet:(MDDConditionSet *)conditionSet;{
    return [self queryWithPropertys:property conditionSet:conditionSet sorts:nil];
}

+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts;{
    return [self queryWithPropertys:property conditionSet:conditionSet sorts:sorts range:NSRangeZore];
}

+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range;{
    return [self queryWithPropertys:property set:nil conditionSet:conditionSet sorts:sorts range:range];
}

+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range objectClass:(Class<MDDObject>)objectClass;{
    return [self queryWithPropertys:property set:nil conditionSet:conditionSet sorts:sorts range:range transform:^id(NSDictionary *result) {
        return [objectClass objectWithDictionary:result];
    }];
}

+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range transform:(id (^)(NSDictionary *result))transform;{
    return [self queryWithPropertys:property set:nil conditionSet:conditionSet sorts:sorts range:range transform:transform];
}

+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property set:(MDDSet *)set;{
    return [self queryWithPropertys:property set:set conditionSet:nil];
}

+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet;{
    return [self queryWithPropertys:property set:set conditionSet:conditionSet sorts:nil];
}

+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts;{
    return [self queryWithPropertys:property set:set conditionSet:conditionSet sorts:sorts range:NSRangeZore];
}

+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range;{
    return [self queryWithPropertys:property set:set conditionSet:conditionSet sorts:sorts range:range transform:nil];
}

+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range objectClass:(Class<MDDObject>)objectClass;{
    return [self queryWithPropertys:property set:set conditionSet:conditionSet sorts:sorts range:range transform:^id(NSDictionary *result) {
        return [objectClass objectWithDictionary:result];
    }];
}

+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range transform:(id (^)(NSDictionary *result))transform;{
    MDDQuery *descriptor = [[self alloc] init];

    descriptor->_set = set;
    descriptor->_range = range;
    descriptor->_conditionSet = conditionSet;
    
    descriptor->_property = [property copy];
    descriptor->_sorts = [sorts copy];
    descriptor->_transform = [transform copy];
    
    return descriptor;
}

- (id)transformValue:(NSDictionary *)value;{
    if (_transform) return _transform(value);
    
    return value;
}

- (NSString *)description{
    return [[self dictionaryWithValuesForKeys:@[@"tableInfo", @"set", @"conditionSet", @"range", @"property", @"sorts"]] description];
}

#pragma mark - accessor

- (MDDDescription *)SQLDescription{
    NSMutableArray *values = [NSMutableArray array];
    NSMutableArray<NSString *> *columns = [NSMutableArray<NSString *> array];
    
    NSMutableSet<MDDTableInfo> *tableInfos = [NSMutableSet<MDDTableInfo> set];
    [tableInfos unionSet:[[self conditionSet] mutableTableInfos]];
    
    for (MDDItem *property in [self property]) {
        MDDDescription *description = [property SQLDescription];
        if ([property tableInfo]) [tableInfos addObject:[property tableInfo]];
        
        [columns addObject:[description SQL]];
        [values addObjectsFromArray:[description values]];
    }
    
    NSString *property = [columns componentsJoinedByString:@", "];
    property = [property length] ? property : @" * ";
    
    MDDIndex *index = [[self conditionSet] index];
    NSString *indexString = index ? [NSString stringWithFormat:@" INDEXED BY %@ ", [index name]] : @"";
    
    MDDDescription *description = [[self set] SQLDescription];
    NSString *tableSet = nil;
    if (description) {
        tableSet = [description SQL];
        [values addObjectsFromArray:[description values]];
    } else {
        tableSet = [[[tableInfos allObjects] valueForKey:@MDDKeyPath(MDDTableInfo, name)] componentsJoinedByString:@" , "];
    }
    NSMutableString *SQL = [NSMutableString stringWithFormat:@" SELECT %@ FROM %@ %@ ", property, tableSet, indexString];
    
    description = [[self conditionSet] SQLDescription];
    if ([description SQL]) {
        [SQL appendFormat:@" WHERE %@ ", [description SQL]];
        [values addObjectsFromArray:description.values];
    }
    
    description = [MDDSort descriptionWithSorts:[self sorts]];
    if ([description SQL]) {
        [SQL appendFormat:@" ORDER BY %@ ", [description SQL] ?: @""];
    }
    
    NSRange range = [self range];
    if (range.location || range.length) {
        range.length = range.length ?: INT_MAX;
        [SQL appendFormat:@" LIMIT %lu OFFSET %ld ", (unsigned long)range.length, (unsigned long)range.location];
    }
    
    return [MDDDescription descriptionWithSQL:SQL values:values];
}

@end
