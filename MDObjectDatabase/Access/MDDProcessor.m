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

- (instancetype)initWithClass:(Class<MDDObject>)class database:(MDDatabase *)database tableInfo:(MDDTableInfo *)tableInfo;{
    if (self = [super init]) {
        _objectClass = class;
        _database = database;
        _tableInfo = tableInfo;
    }
    return self;
}

- (MDDTableInfo *)tableInfoForClass:(Class<MDDObject>)class;{
    return [_database requireTableInfoWithClass:class error:nil];
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
    [rquiredIgnoredProperties addObjectsFromArray:[conditionSet allKeysIgnoreMultipleTable:YES]];
    
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

- (MDDConditionSet *)defaultUpdateConditionSetWithTableInfo:(MDDTableInfo *)tableInfo object:(id)object{
    NSMutableArray<MDDCondition *> *conditions = [[NSMutableArray alloc] init];
    for (NSString *propertyName in [tableInfo primaryProperties]) {
        MDDCondition *condition = [MDDCondition conditionWithTableInfo:_tableInfo key:propertyName value:[object valueForKey:propertyName]];
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

- (BOOL)updateWithObjects:(NSArray *)objects properties:(NSSet<NSString *> *)properties ignoredProperties:(NSSet<NSString *> *)ignoredProperties conditionKeys:(NSSet<NSString *> *)conditionKeys;{
    NSParameterAssert(objects && [objects count]);
    
    ignoredProperties = ignoredProperties ?: [NSSet set];
    conditionKeys = conditionKeys && [conditionKeys count] ? conditionKeys : [_tableInfo primaryProperties];
    
    return [self updateWithObjectsWithBlock:^id(NSUInteger index, NSSet<NSString *> **propertiesPtr, NSSet<NSString *> **ignoredPropertiesPtr, MDDConditionSet **conditionSetPtr, BOOL *stop) {
        *stop = index >= (objects.count - 1);
        id object = objects[index];
        
        NSMutableArray<MDDCondition *> *conditions = [[NSMutableArray alloc] init];
        for (NSString *conditionKey in conditionKeys) {
            MDDCondition *condition = [MDDCondition conditionWithTableInfo:_tableInfo key:conditionKey value:[object valueForKey:conditionKey]];
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
        [rquiredIgnoredProperties addObjectsFromArray:[conditionSet allKeysIgnoreMultipleTable:YES]];
        
        return [MDDUpdater updaterWithObject:object properties:properties ignoredProperties:rquiredIgnoredProperties conditionSet:conditionSet tableInfo:_tableInfo];
    } block:nil];
}

- (BOOL)updateWithPrimaryValue:(id)primaryValue key:(NSString *)key value:(id)value;{
    return [self updateWithPrimaryValue:primaryValue key:key value:value operation:MDDOperationEqual];
}

- (BOOL)updateWithPrimaryValue:(id)primaryValue key:(NSString *)key value:(id)value operation:(MDDOperation)operation;{
    return [self updateWithKey:key value:value operation:operation conditionKey:nil conditionValue:primaryValue];
}

- (BOOL)updateWithKey:(NSString *)key value:(id)value operation:(MDDOperation)operation conditionKey:(NSString *)conditionKey conditionValue:(id)conditionValue{
    MDDCondition *condition = [MDDCondition conditionWithTableInfo:_tableInfo key:conditionKey value:conditionValue operation:MDDOperationEqual];
    NSParameterAssert(condition);
    
    MDDConditionSet *conditionSet = [MDDConditionSet setWithCondition:condition];
    
    return [self updateWithKey:key value:value operation:operation conditionSet:conditionSet];
}

- (BOOL)updateWithKey:(NSString *)key value:(id)value conditionSet:(MDDConditionSet *)conditionSet;{
    return [self updateWithKey:key value:value operation:MDDOperationEqual conditionSet:conditionSet];
}

- (BOOL)updateWithKey:(NSString *)key value:(id)value operation:(MDDOperation)operation conditionSet:(MDDConditionSet *)conditionSet;{
    key = key ?: (id)[NSNull null];
    value = value ?: [NSNull null];
    
    MDDSetter *setter = [MDDSetter setterWithTableInfo:_tableInfo key:key value:value operation:operation];
    
    return [self updateWithSetters:@[setter] conditionSet:conditionSet];
}

#pragma mark - Update - Provide key-values and conditions

- (BOOL)updateWithKeyValues:(NSDictionary *)keyValues conditionSet:(MDDConditionSet *)conditionSet;{
    NSMutableArray *setters = [NSMutableArray array];
    for (NSString *key in [keyValues allKeys]) {
        id value = keyValues[key];
        [setters addObject:[MDDSetter setterWithTableInfo:_tableInfo key:key value:value]];
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
    return [self deleteWithKey:nil value:value];
}

- (BOOL)deleteWithPrimaryValues:(NSSet *)primaryValues;{
    return [self deleteWithKey:nil inValues:primaryValues];
}

#pragma mark - Delete - Provide key equal value

- (BOOL)deleteWithKey:(NSString *)key value:(id)value;{
    return [self deleteWithKey:key value:value operation:MDDOperationEqual];
}

- (BOOL)deleteWithKey:(NSString *)key value:(id)value operation:(MDDOperation)operation;{
    MDDCondition *condition = [MDDCondition conditionWithTableInfo:_tableInfo key:key value:value operation:operation];
    NSParameterAssert(condition);
    
    return [self deleteWithConditionSet:[MDDConditionSet setWithCondition:condition]];
}

#pragma mark - Delete - Provide key like value

- (BOOL)deleteWithKey:(NSString *)key likeValue:(id)value;{
    return [self deleteWithKey:key likeValue:value format:nil];
}

- (BOOL)deleteWithKey:(NSString *)key likeValue:(id)value format:(NSString *)format;{
    NSParameterAssert(value);
    if (format) {
        value = [NSString stringWithFormat:format, value];
    }
    
    MDDCondition *condition = [MDDCondition conditionWithTableInfo:_tableInfo key:key value:value operation:MDDOperationLike];
    NSParameterAssert(condition);
    
    return [self deleteWithConditionSet:[MDDConditionSet setWithCondition:condition]];
}

- (BOOL)deleteWithKey:(NSString *)key inValues:(NSSet *)values;{
    MDDCondition *condition = [MDDCondition conditionWithTableInfo:_tableInfo key:key value:[values allObjects] operation:MDDOperationIn];
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
    return [[self queryWithKey:nil value:value] firstObject];
}

- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues;{
    NSParameterAssert(primaryValues && [primaryValues count]);
    return [self queryWithPrimaryValues:primaryValues range:(NSRange){0, 0}];
}

- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues range:(NSRange)range;{
    NSParameterAssert(primaryValues && [primaryValues count]);
    return [self queryWithPrimaryValues:primaryValues range:range orderByKey:nil ascending:YES];
}

- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;{
    NSParameterAssert(primaryValues && [primaryValues count]);
    return [self queryWithPrimaryValues:primaryValues operation:MDDOperationIn range:range orderByKey:orderKey ascending:ascending];
}

- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues operation:(MDDOperation)operation range:(NSRange)range{
    return [self queryWithPrimaryValues:primaryValues operation:operation range:range orderByKey:nil ascending:YES];
}

- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues operation:(MDDOperation)operation range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;{
    NSParameterAssert(operation == MDDOperationIn || operation == MDDOperationNotIn);
    return [self queryWithKey:nil inValues:primaryValues operation:operation range:range orderByKey:orderKey ascending:ascending];
}

#pragma mark - Fetch - Provide searching in set

- (NSArray *)queryWithKey:(NSString *)key inValues:(NSSet *)values;{
    NSParameterAssert(values && [values count]);
    return [self queryWithKey:key inValues:values range:(NSRange){0, 0}];
}

- (NSArray *)queryWithKey:(NSString *)key inValues:(NSSet *)values range:(NSRange)range;{
    NSParameterAssert(values && [values count]);
    return [self queryWithKey:key inValues:values range:range orderByKey:nil ascending:YES];
}

- (NSArray *)queryWithKey:(NSString *)key inValues:(NSSet *)values range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;{
    NSParameterAssert(values && [values count]);
    return [self queryWithKey:key inValues:values operation:MDDOperationIn range:range orderByKey:orderKey ascending:ascending];
}

- (NSArray *)queryWithKey:(NSString *)key inValues:(NSSet *)values operation:(MDDOperation)operation range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;{
    NSParameterAssert(values && [values count]);
    NSParameterAssert(operation == MDDOperationIn || operation == MDDOperationNotIn);
    
    MDDCondition *condition = [MDDCondition conditionWithTableInfo:_tableInfo key:key value:[values allObjects] operation:operation];
    MDDConditionSet *conditionSet = [MDDConditionSet setWithCondition:condition];
    
    return [self queryWithConditionSet:conditionSet range:range orderByKey:orderKey ascending:ascending];
}

#pragma mark - Fetch - Provide searching that key equal value

- (NSArray *)queryWithKey:(NSString *)key value:(id)value;{
    return [self queryWithKey:key value:value range:(NSRange){0, 0}];
}

- (NSArray *)queryWithKey:(NSString *)key value:(id)value range:(NSRange)range;{
    return [self queryWithKey:key value:value range:range orderByKey:nil ascending:YES];
}

- (NSArray *)queryWithKey:(NSString *)key value:(id)value range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;{
    return [self queryWithKey:key value:value operation:MDDOperationEqual range:range orderByKey:orderKey ascending:ascending];
}

- (NSArray *)queryWithKey:(NSString *)key value:(id)value operation:(MDDOperation)operation;{
    return [self queryWithKey:key value:value operation:operation range:(NSRange){0, 0}];
}

- (NSArray *)queryWithKey:(NSString *)key value:(id)value operation:(MDDOperation)operation range:(NSRange)range;{
    return [self queryWithKey:key value:value operation:operation range:range orderByKey:nil ascending:YES];
}

- (NSArray *)queryWithKey:(NSString *)key value:(id)value operation:(MDDOperation)operation range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;{
    MDDConditionSet *conditionSet = nil;
    if (key || value) {
        MDDCondition *condition = [MDDCondition conditionWithTableInfo:_tableInfo key:key value:value operation:operation];
        conditionSet = [MDDConditionSet setWithCondition:condition];
    }
    
    return [self queryWithConditionSet:conditionSet range:range orderByKey:orderKey ascending:ascending];
}

#pragma mark - Fetch - Provide searching that key like value

- (NSArray *)queryWithKey:(NSString *)key likeValue:(id)value format:(NSString *)format ;{
    return [self queryWithKey:key likeValue:value format:format range:(NSRange){0, 0}];
}

- (NSArray *)queryWithKey:(NSString *)key likeValue:(id)value format:(NSString *)format range:(NSRange)range;{
    return [self queryWithKey:key likeValue:value format:format range:range orderByKey:nil ascending:YES];
}

- (NSArray *)queryWithKey:(NSString *)key likeValue:(id)value format:(NSString *)format range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;{
    NSParameterAssert(value && [format length]);
    
    NSString *expression = [NSString stringWithFormat:format, value];
    MDDCondition *condition = [MDDCondition conditionWithTableInfo:_tableInfo key:key value:expression operation:MDDOperationLike];
    MDDConditionSet *conditionSet = [MDDConditionSet setWithCondition:condition];
    
    return [self queryWithConditionSet:conditionSet range:range orderByKey:orderKey ascending:ascending];
}

- (NSArray *)queryAllRows;{
    return [self queryWithConditionSet:nil];
}

#pragma mark - Fetch - Provide conditions

- (NSArray *)queryWithConditionSet:(MDDConditionSet *)conditionSet;{
    return [self queryWithConditionSet:conditionSet range:(NSRange){0, 0}];
}

- (NSArray *)queryWithConditionSet:(MDDConditionSet *)conditionSet range:(NSRange)range;{
    return [self queryWithConditionSet:conditionSet range:range orderByKey:nil ascending:YES];
}

- (NSArray *)queryWithConditionSet:(MDDConditionSet *)conditionSet range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;{
    MDDSort *sort = [orderKey length] ? [MDDSort sortWithTableInfo:_tableInfo key:orderKey ascending:ascending] : nil;
    
    return [self queryWithConditionSet:conditionSet sorts:sort ? @[sort] : nil range:range];
}

- (NSArray *)queryWithConditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range;{
    MDDQuery *query = [MDDQuery queryWithKeys:nil set:nil conditionSet:conditionSet sorts:sorts range:range objectClass:[self objectClass]];
    NSParameterAssert(query);
    
    __block NSMutableArray *results = [NSMutableArray array];
    [self executeQuery:query block:^(id result) {
        if (result) [results addObject:result];
    }];
    return results;
}

#pragma mark - Fetch - Provide function

- (NSUInteger)queryCountWithKey:(NSString *)key value:(id)value{
    MDDCondition *condition = [MDDCondition conditionWithTableInfo:_tableInfo key:key value:value];
    MDDConditionSet *conditionSet = condition ? [MDDConditionSet setWithCondition:condition] : nil;
    
    return [[self queryWithKey:nil function:MDDFunctionCOUNT conditionSet:conditionSet] unsignedIntegerValue];
}

- (NSUInteger)queryCountWithConditionSet:(MDDConditionSet *)conditionSet;{
    return [[self queryWithKey:nil function:MDDFunctionCOUNT conditionSet:conditionSet] unsignedIntegerValue];
}

- (NSUInteger)queryCountWithKey:(NSString *)key conditionSet:(MDDConditionSet *)conditionSet;{
    return [[self queryWithKey:key function:MDDFunctionCOUNT conditionSet:conditionSet] unsignedIntegerValue];
}

- (id)queryWithKey:(NSString *)key function:(MDDFunction)function conditionSet:(MDDConditionSet *)conditionSet;{
    MDDFuntionKey *key_ = [MDDFuntionKey keyWithTableInfo:_tableInfo key:key function:function alias:@"function_result"];
    MDDFunctionQuery *query = [MDDFunctionQuery fuctionQueryWithKey:key_ conditionSet:conditionSet];
    
    __block id result = nil;
    [self executeQuery:query block:^(id value) {
        result = value;
    }];
    return result == [NSNull null] ? nil : result;
}

@end
