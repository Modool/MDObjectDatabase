
//
//  MDDConditionSet.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDConditionSet.h"
#import "MDDCondition.h"

@interface MDDConditionSet ()

@property (nonatomic, assign) MDDConditionOperation operation;

@property (nonatomic, strong) NSMutableSet<MDDConditionSet *> *mutableSets;

@property (nonatomic, strong) NSMutableSet<MDDCondition *> *mutableConditions;

@end

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
    MDDConditionSet *set = [self new];
    set.operation = operation;
    
    if (sets && [sets count]) {
        [[set mutableSets] addObjectsFromArray:sets.copy];
    }
    if (conditions && [conditions count]) {
        [[set mutableConditions] addObjectsFromArray:conditions.copy];
    }
    
    return set;
}

- (instancetype)init{
    if (self = [super init]) {
        self.operation = MDDConditionOperationAnd;
        self.mutableSets = [NSMutableSet new];
        self.mutableConditions = [NSMutableSet new];
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

#pragma mark - accessor

- (NSArray<MDDConditionSet *> *)sets{
    return [[self mutableSets] allObjects];
}

- (NSArray<MDDCondition *> *)conditions{
    return [[self mutableConditions] allObjects];
}

- (NSArray<NSString *> *)allKeys{
    NSMutableSet *keys = [NSMutableSet set];
    for (MDDConditionSet *set in self.sets) {
        [keys addObjectsFromArray:[set allKeys]];
    }
    for (MDDCondition *condition in self.conditions) {
        [keys addObject:condition.key ?: [NSNull null]];
    }
    return [keys allObjects];
}

#pragma mark - public

- (MDDConditionSet *)and:(MDDCondition *)condition;{
    NSParameterAssert(condition);
    
    if ([self operation] != MDDConditionOperationAnd) {
        return [[self class] setWithCondition:condition set:self operation:MDDConditionOperationAnd];
    }
    
    [[self mutableConditions] addObject:condition];
    
    return self;
}

- (MDDConditionSet *)or:(MDDCondition *)condition;{
    NSParameterAssert(condition);
    
    if ([self operation] != MDDConditionOperationOr) {
        return [[self class] setWithCondition:condition set:self operation:MDDConditionOperationOr];
    }
    
    [[self mutableConditions] addObject:condition];
    
    return self;
}

- (MDDConditionSet *)andSet:(MDDConditionSet *)set;{
    NSParameterAssert(set);
    
    if ([self operation] != MDDConditionOperationAnd) {
        return [[self class] setWithSets:@[set, self] operation:MDDConditionOperationAnd];
    }
    
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
    
    if ([[set sets] count]) {
        [[self mutableSets] addObject:set];
    } else {
        [[self mutableConditions] addObjectsFromArray:[set conditions]];
    }
    
    return self;
}

@end

