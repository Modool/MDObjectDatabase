//
//  MDDProcessor.m
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/24.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDProcessor.h"
#import "MDDProcessor+Private.h"
#import "MDDProcessor+MDDatabase.h"

#import "MDDatabase.h"
#import "MDDTableInfo.h"
#import "MDDInserter.h"

#import "MDDColumn+Private.h"
#import "MDDSetter.h"
#import "MDDCondition.h"
#import "MDDConditionSet.h"
#import "MDDSort.h"

#import "MDDQuery+Private.h"
#import "MDDFunctionQuery.h"

#import "MDDUpdater.h"
#import "MDDDeleter.h"
#import "MDDDescription.h"

#import "MDDObject+Private.h"
#import "MDDItem.h"

@implementation MDDProcessor

- (instancetype)initWithClass:(Class<MDDObject>)class database:(MDDatabase *)database tableInfo:(id<MDDTableInfo>)tableInfo;{
    if (self = [super init]) {
        _objectClass = class;
        _database = database;
        _tableInfo = tableInfo;
    }
    return self;
}

- (id<MDDTableInfo>)tableInfoForClass:(Class<MDDObject>)class;{
    return [_database requireInfoWithClass:class error:nil];
}

- (NSString *)description{
    return [[self dictionaryWithValuesForKeys:@[@"objectClass", @"database", @"tableInfo"]] description];
}

#pragma mark - Append

- (BOOL)insertWithObject:(id)object;{
    NSParameterAssert(object);
    
    MDDInserter *inserter = [MDDInserter inserterWithObject:object tableInfo:_tableInfo];
    NSParameterAssert(inserter);
    
    return [self executeInserter:inserter block:^(NSUInteger rowID) {
        [object setPrimaryValue:[@(rowID) description] tableInfo:_tableInfo];
    }];
}

- (BOOL)insertWithObjects:(NSArray *)objects;{
    NSParameterAssert(objects && [objects count]);
    if ([objects count] == 1) {
        return [self insertWithObject:[objects firstObject]];
    }

    return [self insertWithObjectsWithBlock:^id(NSUInteger index, BOOL *stop) {
        *stop = index >= (objects.count - 1);
        return objects[index];
    } block:^(BOOL state, UInt64 rowID, NSUInteger index, BOOL *stop) {
        id object = objects[index];
        [object setPrimaryValue:[@(rowID) description] tableInfo:_tableInfo];
    }];
}

- (BOOL)insertWithObjectsWithBlock:(id(^)(NSUInteger index, BOOL *stop))block block:(void (^)(BOOL state, UInt64 rowID, NSUInteger index, BOOL *stop))resultBlock;{
    return [self executeInserters:^MDDInserter *(NSUInteger index, BOOL *stop) {
        id object = block(index, stop);
        NSParameterAssert(object);
        return [MDDInserter inserterWithObject:object tableInfo:_tableInfo];
    } block:^(BOOL state, UInt64 rowID, NSUInteger index, BOOL *stop) {
        if (resultBlock) resultBlock(state, rowID, index, stop);
    }];
}

#pragma mark - Update

- (BOOL)updateWithObject:(id)object;{
    NSParameterAssert(object);
    
    return [self updateWithObject:object properties:nil];
}

- (BOOL)updateWithObject:(id)object properties:(NSSet<NSString *> *)properties{
    NSSet<NSString *> *ignoredProperties = [_tableInfo primaryProperties];
    MDDCondition *condition = [MDDCondition conditionWithTableInfo:_tableInfo primaryValue:[object primaryValurWithTableInfo:_tableInfo]];
    MDDConditionSet *conditionSet = [MDDConditionSet setWithCondition:condition];
    
    return [self updateWithObject:object properties:properties ignoredProperties:ignoredProperties conditionSet:conditionSet];
}

- (BOOL)updateWithObject:(id)object properties:(NSSet<NSString *> *)properties ignoredProperties:(NSSet<NSString *> *)ignoredProperties{
    NSMutableSet<NSString *> *mutableIgnoredProperties = [[_tableInfo primaryProperties] mutableCopy];
    if (ignoredProperties) {
        [mutableIgnoredProperties unionSet:ignoredProperties];
    }
    MDDCondition *condition = [MDDCondition conditionWithTableInfo:_tableInfo primaryValue:[object primaryValurWithTableInfo:_tableInfo]];
    MDDConditionSet *conditionSet = [MDDConditionSet setWithCondition:condition];
    
    return [self updateWithObject:object properties:properties ignoredProperties:mutableIgnoredProperties conditionSet:conditionSet];
}

- (BOOL)updateWithObject:(id)object properties:(NSSet<NSString *> *)properties ignoredProperties:(NSSet<NSString *> *)ignoredProperties conditionSet:(MDDConditionSet *)conditionSet;{
    NSParameterAssert(object);
    
    if (!conditionSet) {
        conditionSet = [self defaultUpdateConditionSetWithTableInfo:_tableInfo object:object];
    }
    
    NSMutableSet *rquiredIgnoredProperties = [ignoredProperties ?: [NSSet set] mutableCopy];
    [rquiredIgnoredProperties addObjectsFromArray:[conditionSet allPropertysIgnoreMultipleTable:YES]];
    
    MDDUpdater *updater = [MDDUpdater updaterWithObject:object properties:properties ignoredProperties:rquiredIgnoredProperties conditionSet:conditionSet tableInfo:_tableInfo];
    NSParameterAssert(updater);
    
    return [self executeUpdater:updater];
}

- (BOOL)updateWithObjects:(NSArray *)objects;{
    NSParameterAssert(objects && [objects count]);
    return [self updateWithObjects:objects properties:nil ignoredProperties:nil];
}

- (BOOL)updateWithObjects:(NSArray *)objects properties:(NSSet<NSString *> *)properties{
    NSParameterAssert(objects && [objects count]);
    return [self updateWithObjects:objects properties:properties ignoredProperties:nil];
}

- (BOOL)updateWithObjects:(NSArray *)objects properties:(NSSet<NSString *> *)properties ignoredProperties:(NSSet<NSString *> *)ignoredProperties;{
    NSParameterAssert(objects && [objects count]);
    return [self updateWithObjects:objects properties:properties ignoredProperties:ignoredProperties conditionSet:nil];
}

- (MDDConditionSet *)defaultUpdateConditionSetWithTableInfo:(id<MDDTableInfo>)tableInfo object:(id)object{
    NSMutableArray<MDDCondition *> *conditions = [[NSMutableArray alloc] init];
    for (NSString *propertyName in [tableInfo primaryProperties]) {
        MDDCondition *condition = [MDDCondition conditionWithTableInfo:_tableInfo property:propertyName value:[object valueForKey:propertyName]];
        NSParameterAssert(condition);
        [conditions addObject:condition];
    }
    return [MDDConditionSet setWithConditions:conditions];
}

- (BOOL)updateWithObjects:(NSArray *)objects properties:(NSSet<NSString *> *)properties ignoredProperties:(NSSet<NSString *> *)ignoredProperties conditionSet:(MDDConditionSet *)conditionSet;{
    NSParameterAssert(objects && [objects count]);
    if ([objects count] == 1) {
        return [self updateWithObject:[objects firstObject] properties:properties ignoredProperties:ignoredProperties conditionSet:conditionSet];
    }
    
    ignoredProperties = ignoredProperties ?: [NSSet set];
    
    return [self updateWithObjectsWithBlock:^id(NSUInteger index, NSSet<NSString *> **propertiesPtr, NSSet<NSString *> **ignoredPropertiesPtr, MDDConditionSet **conditionSetPtr, BOOL *stop) {
        *stop = index >= (objects.count - 1);
        
        *propertiesPtr = properties;
        *ignoredPropertiesPtr = ignoredProperties;
        *conditionSetPtr = conditionSet;
        
        return objects[index];
    } result:^(BOOL state, NSUInteger index, BOOL *stop) {
        *stop = !state;
    }];
}

- (BOOL)updateWithObjects:(NSArray *)objects properties:(NSSet<NSString *> *)properties ignoredProperties:(NSSet<NSString *> *)ignoredProperties conditionPropertys:(NSSet<NSString *> *)conditionPropertys;{
    NSParameterAssert(objects && [objects count]);
    
    ignoredProperties = ignoredProperties ?: [NSSet set];
    conditionPropertys = conditionPropertys && [conditionPropertys count] ? conditionPropertys : [_tableInfo primaryProperties];
    
    return [self updateWithObjectsWithBlock:^id(NSUInteger index, NSSet<NSString *> **propertiesPtr, NSSet<NSString *> **ignoredPropertiesPtr, MDDConditionSet **conditionSetPtr, BOOL *stop) {
        *stop = index >= (objects.count - 1);
        id object = objects[index];
        
        NSMutableArray<MDDCondition *> *conditions = [[NSMutableArray alloc] init];
        for (NSString *conditionProperty in conditionPropertys) {
            MDDCondition *condition = [MDDCondition conditionWithTableInfo:_tableInfo property:conditionProperty value:[object valueForKey:conditionProperty]];
            NSParameterAssert(condition);
            
            [conditions addObject:condition];
        }
        *propertiesPtr = properties.copy;
        *ignoredPropertiesPtr = ignoredProperties.copy;
        *conditionSetPtr = [MDDConditionSet setWithConditions:conditions];
        
        return object;
    } result:nil];
}

- (BOOL)updateWithObjectsWithBlock:(id(^)(NSUInteger index, NSSet<NSString *> **propertiesPtr, NSSet<NSString *> **ignoredPropertiesPtr, MDDConditionSet **conditionSetPtr, BOOL *stop))block result:(void (^)(BOOL state, NSUInteger index, BOOL *stop))result;{
    return [self executeUpdaters:^MDDUpdater *(NSUInteger index, BOOL *stop) {
        NSSet<NSString *> *properties = nil;
        NSSet<NSString *> *ignoredProperties = nil;
        MDDConditionSet *conditionSet = nil;
        id object = block(index, &properties, &ignoredProperties, &conditionSet, stop);
        
        if (!conditionSet) {
            conditionSet = [self defaultUpdateConditionSetWithTableInfo:_tableInfo object:object];
        }
        NSMutableSet *rquiredIgnoredProperties = [ignoredProperties ?: [NSSet set] mutableCopy];
        [rquiredIgnoredProperties addObjectsFromArray:[conditionSet allPropertysIgnoreMultipleTable:YES]];
        
        return [MDDUpdater updaterWithObject:object properties:properties ignoredProperties:rquiredIgnoredProperties conditionSet:conditionSet tableInfo:_tableInfo];
    } block:nil];
}

- (BOOL)updateWithPrimaryValue:(id)primaryValue property:(NSString *)property value:(id)value;{
    return [self updateWithPrimaryValue:primaryValue property:property value:value operation:MDDOperationEqual];
}

- (BOOL)updateWithPrimaryValue:(id)primaryValue property:(NSString *)property value:(id)value operation:(MDDOperation)operation;{
    return [self updateWithProperty:property value:value operation:operation conditionProperty:nil conditionValue:primaryValue];
}

- (BOOL)updateWithProperty:(NSString *)property value:(id)value operation:(MDDOperation)operation conditionProperty:(NSString *)conditionProperty conditionValue:(id)conditionValue{
    MDDCondition *condition = [MDDCondition conditionWithTableInfo:_tableInfo property:conditionProperty value:conditionValue operation:MDDOperationEqual];
    NSParameterAssert(condition);
    
    MDDConditionSet *conditionSet = [MDDConditionSet setWithCondition:condition];
    
    return [self updateWithProperty:property value:value operation:operation conditionSet:conditionSet];
}

- (BOOL)updateWithProperty:(NSString *)property value:(id)value conditionSet:(MDDConditionSet *)conditionSet;{
    return [self updateWithProperty:property value:value operation:MDDOperationEqual conditionSet:conditionSet];
}

- (BOOL)updateWithProperty:(NSString *)property value:(id)value operation:(MDDOperation)operation conditionSet:(MDDConditionSet *)conditionSet;{
    property = property ?: (id)[NSNull null];
    value = value ?: [NSNull null];
    
    MDDSetter *setter = [MDDSetter setterWithTableInfo:_tableInfo property:property value:value operation:operation];
    
    return [self updateWithSetters:@[setter] conditionSet:conditionSet];
}

#pragma mark - Update - Provide property-values and conditions

- (BOOL)updateWithPropertyValues:(NSDictionary *)keyValues conditionSet:(MDDConditionSet *)conditionSet;{
    NSMutableArray *setters = [NSMutableArray array];
    for (NSString *property in [keyValues allKeys]) {
        id value = keyValues[property];
        [setters addObject:[MDDSetter setterWithTableInfo:_tableInfo property:property value:value]];
    }
    return [self updateWithSetters:setters conditionSet:conditionSet];
}

#pragma mark - Update - Provide setter and conditions

- (BOOL)updateWithSetter:(MDDSetter *)settter;{
    NSParameterAssert(settter);
    return [self updateWithSetter:settter conditionSet:nil];
}

- (BOOL)updateWithSetter:(MDDSetter *)settter conditionSet:(MDDConditionSet *)conditionSet;{
    NSParameterAssert(settter);
    return [self updateWithSetters:@[settter] conditionSet:conditionSet];
}

- (BOOL)updateWithSetters:(NSArray<MDDSetter *> *)setters conditionSet:(MDDConditionSet *)conditionSet;{
    NSParameterAssert(setters && [setters count]);
    MDDUpdater *updater = [MDDUpdater updaterWithSetter:setters conditionSet:conditionSet];
    NSParameterAssert(updater);
    
    return [self executeUpdater:updater];
}

#pragma mark - Delete

- (BOOL)deleteWithPrimaryValue:(id)value;{
    return [self deleteWithProperty:nil value:value];
}

- (BOOL)deleteWithPrimaryValues:(NSSet *)primaryValues;{
    return [self deleteWithProperty:nil inValues:primaryValues];
}

#pragma mark - Delete - Provide property equal value

- (BOOL)deleteWithProperty:(NSString *)property value:(id)value;{
    return [self deleteWithProperty:property value:value operation:MDDOperationEqual];
}

- (BOOL)deleteWithProperty:(NSString *)property value:(id)value operation:(MDDOperation)operation;{
    MDDCondition *condition = [MDDCondition conditionWithTableInfo:_tableInfo property:property value:value operation:operation];
    NSParameterAssert(condition);
    
    return [self deleteWithConditionSet:[MDDConditionSet setWithCondition:condition]];
}

#pragma mark - Delete - Provide property like value

- (BOOL)deleteWithProperty:(NSString *)property likeValue:(id)value;{
    return [self deleteWithProperty:property likeValue:value format:nil];
}

- (BOOL)deleteWithProperty:(NSString *)property likeValue:(id)value format:(NSString *)format;{
    NSParameterAssert(value);
    if (format) {
        value = [NSString stringWithFormat:format, value];
    }
    
    MDDCondition *condition = [MDDCondition conditionWithTableInfo:_tableInfo property:property value:value operation:MDDOperationLike];
    NSParameterAssert(condition);
    
    return [self deleteWithConditionSet:[MDDConditionSet setWithCondition:condition]];
}

- (BOOL)deleteWithProperty:(NSString *)property inValues:(NSSet *)values;{
    MDDCondition *condition = [MDDCondition conditionWithTableInfo:_tableInfo property:property value:[values allObjects] operation:MDDOperationIn];
    NSParameterAssert(condition);
    
    return [self deleteWithConditionSet:[MDDConditionSet setWithCondition:condition]];
}

#pragma mark - Delete - Provide conditions

- (BOOL)deleteWithConditionSet:(MDDConditionSet *)conditionSet;{
    NSParameterAssert(conditionSet);
    MDDDeleter *deleter = [MDDDeleter deleterWithTableInfo:_tableInfo conditionSet:conditionSet];
    NSParameterAssert(deleter);
    
    return [self executeDeleter:deleter];
}

#pragma mark - Fetch

- (id)queryWithPrimaryValue:(id)value;{
    return [[self queryWithProperty:nil value:value] firstObject];
}

- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues;{
    NSParameterAssert(primaryValues && [primaryValues count]);
    return [self queryWithPrimaryValues:primaryValues range:(NSRange){0, 0}];
}

- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues range:(NSRange)range;{
    NSParameterAssert(primaryValues && [primaryValues count]);
    return [self queryWithPrimaryValues:primaryValues range:range orderByProperty:nil ascending:YES];
}

- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues range:(NSRange)range orderByProperty:(NSString *)orderProperty ascending:(BOOL)ascending;{
    NSParameterAssert(primaryValues && [primaryValues count]);
    return [self queryWithPrimaryValues:primaryValues operation:MDDOperationIn range:range orderByProperty:orderProperty ascending:ascending];
}

- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues operation:(MDDOperation)operation range:(NSRange)range{
    return [self queryWithPrimaryValues:primaryValues operation:operation range:range orderByProperty:nil ascending:YES];
}

- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues operation:(MDDOperation)operation range:(NSRange)range orderByProperty:(NSString *)orderProperty ascending:(BOOL)ascending;{
    NSParameterAssert(operation == MDDOperationIn || operation == MDDOperationNotIn);
    return [self queryWithProperty:nil inValues:primaryValues operation:operation range:range orderByProperty:orderProperty ascending:ascending];
}

#pragma mark - Fetch - Provide searching in set

- (NSArray *)queryWithProperty:(NSString *)property inValues:(NSSet *)values;{
    NSParameterAssert(values && [values count]);
    return [self queryWithProperty:property inValues:values range:(NSRange){0, 0}];
}

- (NSArray *)queryWithProperty:(NSString *)property inValues:(NSSet *)values range:(NSRange)range;{
    NSParameterAssert(values && [values count]);
    return [self queryWithProperty:property inValues:values range:range orderByProperty:nil ascending:YES];
}

- (NSArray *)queryWithProperty:(NSString *)property inValues:(NSSet *)values range:(NSRange)range orderByProperty:(NSString *)orderProperty ascending:(BOOL)ascending;{
    NSParameterAssert(values && [values count]);
    return [self queryWithProperty:property inValues:values operation:MDDOperationIn range:range orderByProperty:orderProperty ascending:ascending];
}

- (NSArray *)queryWithProperty:(NSString *)property inValues:(NSSet *)values operation:(MDDOperation)operation range:(NSRange)range orderByProperty:(NSString *)orderProperty ascending:(BOOL)ascending;{
    NSParameterAssert(values && [values count]);
    NSParameterAssert(operation == MDDOperationIn || operation == MDDOperationNotIn);
    
    MDDCondition *condition = [MDDCondition conditionWithTableInfo:_tableInfo property:property value:[values allObjects] operation:operation];
    MDDConditionSet *conditionSet = [MDDConditionSet setWithCondition:condition];
    
    return [self queryWithConditionSet:conditionSet range:range orderByProperty:orderProperty ascending:ascending];
}

#pragma mark - Fetch - Provide searching that property equal value

- (NSArray *)queryWithProperty:(NSString *)property value:(id)value;{
    return [self queryWithProperty:property value:value range:(NSRange){0, 0}];
}

- (NSArray *)queryWithProperty:(NSString *)property value:(id)value range:(NSRange)range;{
    return [self queryWithProperty:property value:value range:range orderByProperty:nil ascending:YES];
}

- (NSArray *)queryWithProperty:(NSString *)property value:(id)value range:(NSRange)range orderByProperty:(NSString *)orderProperty ascending:(BOOL)ascending;{
    return [self queryWithProperty:property value:value operation:MDDOperationEqual range:range orderByProperty:orderProperty ascending:ascending];
}

- (NSArray *)queryWithProperty:(NSString *)property value:(id)value operation:(MDDOperation)operation;{
    return [self queryWithProperty:property value:value operation:operation range:(NSRange){0, 0}];
}

- (NSArray *)queryWithProperty:(NSString *)property value:(id)value operation:(MDDOperation)operation range:(NSRange)range;{
    return [self queryWithProperty:property value:value operation:operation range:range orderByProperty:nil ascending:YES];
}

- (NSArray *)queryWithProperty:(NSString *)property value:(id)value operation:(MDDOperation)operation range:(NSRange)range orderByProperty:(NSString *)orderProperty ascending:(BOOL)ascending;{
    MDDConditionSet *conditionSet = nil;
    if (property || value) {
        MDDCondition *condition = [MDDCondition conditionWithTableInfo:_tableInfo property:property value:value operation:operation];
        conditionSet = [MDDConditionSet setWithCondition:condition];
    }
    
    return [self queryWithConditionSet:conditionSet range:range orderByProperty:orderProperty ascending:ascending];
}

#pragma mark - Fetch - Provide searching that property like value

- (NSArray *)queryWithProperty:(NSString *)property likeValue:(id)value format:(NSString *)format ;{
    return [self queryWithProperty:property likeValue:value format:format range:(NSRange){0, 0}];
}

- (NSArray *)queryWithProperty:(NSString *)property likeValue:(id)value format:(NSString *)format range:(NSRange)range;{
    return [self queryWithProperty:property likeValue:value format:format range:range orderByProperty:nil ascending:YES];
}

- (NSArray *)queryWithProperty:(NSString *)property likeValue:(id)value format:(NSString *)format range:(NSRange)range orderByProperty:(NSString *)orderProperty ascending:(BOOL)ascending;{
    NSParameterAssert(value && [format length]);
    
    NSString *expression = [NSString stringWithFormat:format, value];
    MDDCondition *condition = [MDDCondition conditionWithTableInfo:_tableInfo property:property value:expression operation:MDDOperationLike];
    MDDConditionSet *conditionSet = [MDDConditionSet setWithCondition:condition];
    
    return [self queryWithConditionSet:conditionSet range:range orderByProperty:orderProperty ascending:ascending];
}

- (NSArray *)queryAllRows;{
    return [self queryWithConditionSet:nil];
}

#pragma mark - Fetch - Provide conditions

- (NSArray *)queryWithConditionSet:(MDDConditionSet *)conditionSet;{
    return [self queryWithConditionSet:conditionSet range:(NSRange){0, 0}];
}

- (NSArray *)queryWithConditionSet:(MDDConditionSet *)conditionSet range:(NSRange)range;{
    return [self queryWithConditionSet:conditionSet range:range orderByProperty:nil ascending:YES];
}

- (NSArray *)queryWithConditionSet:(MDDConditionSet *)conditionSet range:(NSRange)range orderByProperty:(NSString *)orderProperty ascending:(BOOL)ascending;{
    MDDSort *sort = [orderProperty length] ? [MDDSort sortWithTableInfo:_tableInfo property:orderProperty ascending:ascending] : nil;
    
    return [self queryWithConditionSet:conditionSet sorts:sort ? @[sort] : nil range:range];
}

- (NSArray *)queryWithConditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range;{
    MDDQuery *query = [MDDQuery queryWithPropertys:nil set:nil conditionSet:conditionSet sorts:sorts range:range objectClass:[self objectClass]];
    NSParameterAssert(query);
    
    __block NSMutableArray *results = [NSMutableArray array];
    [self executeQuery:query block:^(id result) {
        if (result) [results addObject:result];
    }];
    return results;
}

#pragma mark - Fetch - Provide function

- (NSUInteger)queryCountWithProperty:(NSString *)property value:(id)value{
    MDDCondition *condition = [MDDCondition conditionWithTableInfo:_tableInfo property:property value:value];
    MDDConditionSet *conditionSet = condition ? [MDDConditionSet setWithCondition:condition] : nil;
    
    return [[self queryWithProperty:nil function:MDDFunctionCOUNT conditionSet:conditionSet] unsignedIntegerValue];
}

- (NSUInteger)queryCountWithConditionSet:(MDDConditionSet *)conditionSet;{
    return [[self queryWithProperty:nil function:MDDFunctionCOUNT conditionSet:conditionSet] unsignedIntegerValue];
}

- (NSUInteger)queryCountWithProperty:(NSString *)property conditionSet:(MDDConditionSet *)conditionSet;{
    return [[self queryWithProperty:property function:MDDFunctionCOUNT conditionSet:conditionSet] unsignedIntegerValue];
}

- (id)queryWithProperty:(NSString *)propertyName function:(MDDFunction)function conditionSet:(MDDConditionSet *)conditionSet;{
    MDDFuntionProperty *property = [MDDFuntionProperty propertyWithTableInfo:_tableInfo name:propertyName function:function alias:@"function_result"];
    MDDFunctionQuery *query = [MDDFunctionQuery fuctionQueryWithProperty:property conditionSet:conditionSet];
    
    __block id result = nil;
    [self executeQuery:query block:^(id value) {
        result = value;
    }];
    return result == [NSNull null] ? nil : result;
}

@end
