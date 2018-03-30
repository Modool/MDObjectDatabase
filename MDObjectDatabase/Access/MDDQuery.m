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
    return [self queryWithKeys:nil conditionSet:nil sorts:sorts];
}

+ (instancetype)queryWithSorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range;{
    return [self queryWithKeys:nil conditionSet:nil sorts:nil range:range];
}

+ (instancetype)queryWithConditionSet:(MDDConditionSet *)conditionSet;{
    return [self queryWithKeys:nil conditionSet:conditionSet sorts:nil];
}

+ (instancetype)queryWithConditionSet:(MDDConditionSet *)conditionSet range:(NSRange)range;{
    return [self queryWithKeys:nil conditionSet:conditionSet sorts:nil range:range];
}

+ (instancetype)queryWithKey:(MDDKey *)key;{
    NSParameterAssert(key);
    return [self queryWithKeys:[NSSet setWithObject:key]];
}

+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys;{
    return [self queryWithKeys:keys conditionSet:nil sorts:nil];
}

+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys range:(NSRange)range;{
    return [self queryWithKeys:keys conditionSet:nil sorts:nil range:range];
}

+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys sorts:(NSArray<MDDSort *> *)sorts;{
    return [self queryWithKeys:keys conditionSet:nil sorts:sorts];
}

+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range;{
    return [self queryWithKeys:keys conditionSet:nil sorts:sorts range:range];
}

+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys conditionSet:(MDDConditionSet *)conditionSet;{
    return [self queryWithKeys:keys conditionSet:conditionSet sorts:nil];
}

+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts;{
    return [self queryWithKeys:keys conditionSet:conditionSet sorts:sorts range:NSRangeZore];
}

+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range;{
    return [self queryWithKeys:keys set:nil conditionSet:conditionSet sorts:sorts range:range];
}

+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range objectClass:(Class<MDDObject>)objectClass;{
    return [self queryWithKeys:keys set:nil conditionSet:conditionSet sorts:sorts range:range transform:^id(NSDictionary *result) {
        return [objectClass objectWithDictionary:result];
    }];
}

+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range transform:(id (^)(NSDictionary *result))transform;{
    return [self queryWithKeys:keys set:nil conditionSet:conditionSet sorts:sorts range:range transform:transform];
}

+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys set:(MDDSet *)set;{
    return [self queryWithKeys:keys set:set conditionSet:nil];
}

+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet;{
    return [self queryWithKeys:keys set:set conditionSet:conditionSet sorts:nil];
}

+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts;{
    return [self queryWithKeys:keys set:set conditionSet:conditionSet sorts:sorts range:NSRangeZore];
}

+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range;{
    return [self queryWithKeys:keys set:set conditionSet:conditionSet sorts:sorts range:range transform:nil];
}

+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range objectClass:(Class<MDDObject>)objectClass;{
    return [self queryWithKeys:keys set:set conditionSet:conditionSet sorts:sorts range:range transform:^id(NSDictionary *result) {
        return [objectClass objectWithDictionary:result];
    }];
}

+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range transform:(id (^)(NSDictionary *result))transform;{
    MDDQuery *descriptor = [[self alloc] init];

    descriptor->_set = set;
    descriptor->_range = range;
    descriptor->_conditionSet = conditionSet;
    
    descriptor->_keys = [keys copy];
    descriptor->_sorts = [sorts copy];
    descriptor->_transform = [transform copy];
    
    return descriptor;
}

- (id)transformValue:(NSDictionary *)value;{
    if (_transform) return _transform(value);
    
    return value;
}

- (NSString *)description{
    return [[self dictionaryWithValuesForKeys:@[@"tableInfo", @"set", @"conditionSet", @"range", @"keys", @"sorts"]] description];
}

#pragma mark - accessor

- (MDDDescription *)SQLDescription{
    NSMutableArray *values = [NSMutableArray array];
    NSMutableArray<NSString *> *columns = [NSMutableArray<NSString *> array];
    
    NSMutableSet<MDDTableInfo *> *tableInfos = [NSMutableSet set];
    [tableInfos unionSet:[[self conditionSet] mutableTableInfos]];
    
    for (MDDKey *key in [self keys]) {
        MDDKey *_key = key;
        MDDDescription *description = [_key SQLDescription];
        if ([_key tableInfo]) [tableInfos addObject:[_key tableInfo]];
        
        [columns addObject:[description SQL]];
        [values addObjectsFromArray:[description values]];
    }
    
    NSString *keys = [columns componentsJoinedByString:@", "];
    keys = [keys length] ? keys : @" * ";
    
    MDDIndex *index = [[self conditionSet] index];
    NSString *indexString = index ? [NSString stringWithFormat:@" INDEXED BY %@ ", [index name]] : @"";
    
    MDDDescription *description = [[self set] SQLDescription];
    NSString *tableSet = nil;
    if (description) {
        tableSet = [description SQL];
        [values addObjectsFromArray:[description values]];
    } else {
        tableSet = [[[tableInfos allObjects] valueForKey:@"tableName"] componentsJoinedByString:@" , "];
    }
    NSMutableString *SQL = [NSMutableString stringWithFormat:@" SELECT %@ FROM %@ %@ ", keys, tableSet, indexString];
    
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
