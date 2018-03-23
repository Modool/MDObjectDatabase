//
//  MDDQuery.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDQuery.h"
#import "MDDDescriptor+Private.h"

#import "MDDColumn.h"
#import "MDDTableInfo.h"
#import "MDDIndex.h"

@implementation MDDQuery

+ (instancetype)query;{
    return [self queryWithKeys:nil sorts:nil conditionSet:nil];
}

+ (instancetype)queryWithSorts:(NSArray<MDDSort *> *)sorts;{
    return [self queryWithKeys:nil sorts:sorts conditionSet:nil];
}

+ (instancetype)queryWithConditionSet:(MDDConditionSet *)conditionSet;{
    return [self queryWithKeys:nil sorts:nil conditionSet:conditionSet];
}

+ (instancetype)queryWithKeys:(NSSet<NSString *> *)keys;{
    return [self queryWithKeys:keys sorts:nil conditionSet:nil];
}

+ (instancetype)queryWithKeys:(NSSet<NSString *> *)keys sorts:(NSArray<MDDSort *> *)sorts;{
    return [self queryWithKeys:keys sorts:sorts conditionSet:nil];
}

+ (instancetype)queryWithKeys:(NSSet<NSString *> *)keys conditionSet:(MDDConditionSet *)conditionSet;{
    return [self queryWithKeys:keys sorts:nil conditionSet:conditionSet];
}

+ (instancetype)queryWithKeys:(NSSet<NSString *> *)keys sorts:(NSArray<MDDSort *> *)sorts conditionSet:(MDDConditionSet *)conditionSet;{
    MDDQuery *descriptor = [self new];
    descriptor->_keys = [keys copy];
    descriptor->_sorts = [sorts copy];
    descriptor->_conditionSet = conditionSet;
    
    return descriptor;
}

- (NSString *)descriptionWithTableInfo:(MDDTableInfo *)tableInfo value:(id *)value{
    NSParameterAssert(tableInfo);
    
    NSMutableArray<NSString *> *columns = [NSMutableArray<NSString *> new];
    for (id key in [self keys]) {
        MDDColumn *column = [tableInfo columnForKey:key];
        NSParameterAssert(column);
        
        [columns addObject:[column name]];
    }
    
    NSString *keyString = [columns componentsJoinedByString:@", "];
    keyString = [keyString length] ? keyString : @" * ";
    
    MDDIndex *index = [self conditionSet] ? [tableInfo indexForConditionSet:[self conditionSet]] : nil;
    NSString *indexString = index ? [NSString stringWithFormat:@" INDEXED BY %@ ", [index name]] : @"";
    
    return [NSString stringWithFormat:@" SELECT %@ FROM %@ %@ ", keyString, [tableInfo tableName], indexString];
}

@end
