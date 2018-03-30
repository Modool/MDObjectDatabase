
//
//  MDDConditionSet.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDConditionSet.h"
#import "MDDConditionSet+Private.h"

#import "MDDDescription.h"
#import "MDDCondition.h"

#import "MDDItem.h"
#import "MDDTableInfo.h"

@implementation MDDConditionSet

+ (instancetype)setWithCondition:(MDDCondition *)condition;{
    NSParameterAssert(condition);
    return [self setWithConditions:@[condition]];
}

+ (instancetype)setWithConditions:(NSArray<MDDCondition *> *)conditions;{
    NSParameterAssert(conditions && [conditions count]);
    return [self setWithConditions:conditions operation:MDDConditionOperationAnd];
}

+ (instancetype)setWithConditions:(NSArray<MDDCondition *> *)conditions operation:(MDDConditionOperation)operation;{
    NSParameterAssert(conditions && [conditions count]);
    return [self setWithConditions:conditions set:nil operation:operation];
}

+ (instancetype)setWithConditions:(NSArray<MDDCondition *> *)conditions set:(MDDConditionSet *)set operation:(MDDConditionOperation)operation; {
    NSParameterAssert(conditions && [conditions count]);
    return [self setWithConditions:conditions sets:set ? @[set] : nil operation:operation];
}

+ (instancetype)setWithCondition:(MDDCondition *)condition set:(MDDConditionSet *)set operation:(MDDConditionOperation)operation;{
    NSParameterAssert(condition && set);
    return [self setWithConditions:@[condition] sets:@[set] operation:operation];
}

+ (instancetype)setWithSets:(NSArray<MDDConditionSet *> *)sets operation:(MDDConditionOperation)operation;{
    NSParameterAssert(sets && [sets count]);
    return [self setWithConditions:nil sets:sets operation:operation];
}

+ (instancetype)setWithConditions:(NSArray<MDDCondition *> *)conditions sets:(NSArray<MDDConditionSet *> *)sets operation:(MDDConditionOperation)operation;{
    MDDConditionSet *set = [[self alloc] init];
    set.operation = operation;
    
    if (sets && [sets count]) {
        [[set mutableSets] addObjectsFromArray:sets.copy];
        for (MDDConditionSet *conditionSet in sets) [[set mutableTableInfos] unionSet:[conditionSet mutableTableInfos]];
    }
    if (conditions && [conditions count]) {
        [[set mutableConditions] addObjectsFromArray:conditions.copy];
        [[set mutableTableInfos] addObjectsFromArray:[conditions valueForKey:@"tableInfo"]];
    }
    return set;
}

- (instancetype)init{
    if (self = [super init]) {
        self.operation = MDDConditionOperationAnd;
        self.mutableSets = [NSMutableSet set];
        self.mutableConditions = [NSMutableSet set];
        self.mutableTableInfos = [NSMutableSet set];
    }
    return self;
}

#pragma mark - compare

- (BOOL)isEqual:(MDDConditionSet *)object{
    if (object == self) return self;
    if ([super isEqual:object]) return YES;
    if (![object isKindOfClass:[MDDConditionSet class]]) return NO;
    
    return [object operation] == [self operation] && [[object mutableSets] isEqual:[self mutableSets]] && [[object mutableConditions] isEqual:[self mutableConditions]];
}

- (NSUInteger)hash{
    return [self operation] ^ [[self mutableSets] hash] ^ [[self mutableConditions] hash];
}

- (NSString *)description{
    return [[self dictionaryWithValuesForKeys:@[@"multipleTable", @"operation", @"mutableSets", @"mutableConditions", @"mutableTableInfos"]] description];
}

#pragma mark - accessor

- (NSArray<MDDConditionSet *> *)sets{
    return [[self mutableSets] allObjects];
}

- (NSArray<MDDCondition *> *)conditions{
    return [[self mutableConditions] allObjects];
}

- (NSArray<MDDItem> *)allKeysIgnoreMultipleTable:(BOOL)ignore;{
    return [self _keysIgnoreMultipleTable:ignore];
}

- (NSArray<MDDItem> *)_keysIgnoreMultipleTable:(BOOL)ignore;{
    if (ignore && [self isMultipleTable]) return nil;
    
    NSMutableSet<MDDItem> *keys = [NSMutableSet set];
    for (MDDConditionSet *set in self.sets) {
        NSArray<NSString *> *subkeys = [set _keysIgnoreMultipleTable:ignore];
        
        [keys addObjectsFromArray:subkeys];
    }
    for (MDDCondition *condition in self.conditions) {
        if ([condition.key isKindOfClass:[MDDKey class]]) [keys unionSet:[(MDDKey *)[condition key] keys]];
        else [keys addObject:condition.key ?: [NSNull null]];
    }
    
    return [keys allObjects];
}

- (MDDDescription *)SQLDescription{
    NSString *operation = MDConditionOperationDescription([self operation]);
    
    NSMutableString *SQL = [NSMutableString string];
    NSMutableArray *values = [NSMutableArray array];
    
    NSArray<MDDConditionSet *> *sets = [self sets];
    NSArray<MDDCondition *> *conditions = [self conditions];
    
    // ((a OR b OR c) AND (c OR d OR e) AND (f OR g OR h) ) OR (i AND j AND k)
    [sets enumerateObjectsUsingBlock:^(MDDConditionSet *set, NSUInteger index, BOOL *stop) {
        MDDDescription *description = [set SQLDescription];
        [SQL appendFormat:@" ( %@ ) %@", [description SQL], index < ([sets count] - 1) ? operation : @""];
        [values addObjectsFromArray:[description values]];
    }];
    
    MDDDescription *description = [MDDCondition descriptionWithConditions:conditions operation:[self operation]];
    [SQL appendFormat:@" %@ %@", [SQL length] ? operation : @"", [description SQL]];
    [values addObjectsFromArray:[description values]];
    
    return [MDDDescription descriptionWithSQL:SQL values:values];
}

- (BOOL)isMultipleTable{
    return [[self mutableTableInfos] count] > 1;
}

- (MDDTableInfo *)tableInfo{
    return [self isMultipleTable] ? nil : [[self mutableTableInfos] anyObject];
}

- (MDDIndex *)index;{
    if ([self isMultipleTable]) return nil;
    
    return [[self tableInfo] indexForConditionSet:self];
}

#pragma mark - public

- (MDDConditionSet *)and:(MDDCondition *)condition;{
    NSParameterAssert(condition);
    
    if ([self operation] != MDDConditionOperationAnd) {
        return [[self class] setWithCondition:condition set:self operation:MDDConditionOperationAnd];
    }
    
    [[self mutableTableInfos] addObject:[condition tableInfo]];
    [[self mutableConditions] addObject:condition];
    
    return self;
}

- (MDDConditionSet *)or:(MDDCondition *)condition;{
    NSParameterAssert(condition);
    
    if ([self operation] != MDDConditionOperationOr) {
        return [[self class] setWithCondition:condition set:self operation:MDDConditionOperationOr];
    }
    
    [[self mutableTableInfos] addObject:[condition tableInfo]];
    [[self mutableConditions] addObject:condition];
    
    return self;
}

- (MDDConditionSet *)andSet:(MDDConditionSet *)set;{
    NSParameterAssert(set);
    
    if ([self operation] != MDDConditionOperationAnd) {
        return [[self class] setWithSets:@[set, self] operation:MDDConditionOperationAnd];
    }
    
    [[self mutableTableInfos] unionSet:[set mutableTableInfos]];
    if ([[set sets] count]) {
        [[self mutableSets] addObject:set];
    } else {
        [[self mutableConditions] addObjectsFromArray:[set conditions]];
    }
    
    return self;
}

- (MDDConditionSet *)orSet:(MDDConditionSet *)set;{
    NSParameterAssert(set);
    
    if ([self operation] != MDDConditionOperationOr) {
        return [[self class] setWithSets:@[set, self] operation:MDDConditionOperationOr];
    }
    
    [[self mutableTableInfos] unionSet:[set mutableTableInfos]];
    if ([[set sets] count]) {
        [[self mutableSets] addObject:set];
    } else {
        [[self mutableConditions] addObjectsFromArray:[set conditions]];
    }
    
    return self;
}

@end

