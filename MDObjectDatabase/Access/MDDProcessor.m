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

#import "MDDDescriptor+Private.h"

#import "MDDatabase.h"
#import "MDDTableInfo.h"

#import "MDDColumn+Private.h"
#import "MDDSetter+Private.h"
#import "MDDCondition+Private.h"
#import "MDDConditionSet+Private.h"
#import "MDDSort+Private.h"

#import "MDDQuery+Private.h"
#import "MDDFunctionQuery+Private.h"

#import "MDDInserter+Private.h"
#import "MDDUpdater+Private.h"
#import "MDDDeleter+Private.h"

#import "MDDObject.h"
#import "MDDTokenDescription.h"

@implementation MDDProcessor

- (instancetype)initWithClass:(Class<MDDObject>)class database:(MDDatabase *)database;{
    if (self = [super init]) {
        _modelClass = class;
        _database = database;
    }
    return self;
}

#pragma mark - Append

- (BOOL)insertWithObject:(id<MDDObject>)object;{
    NSParameterAssert(object);
    
    MDDTableInfo *tableInfo = [[self database] requireTableInfoWithClass:[object class]];
    NSParameterAssert(tableInfo);
    
    MDDTokenDescription *description = [MDDInserter descriptionWithObject:object tableInfo:tableInfo];
    NSParameterAssert(description);
    
    return [self executeInsertDescription:description completion:^(NSUInteger rowID) {
        if (![object objectID]) object.objectID = [@(rowID) description];
    }];
}

- (BOOL)insertWithObjects:(NSArray<MDDObject> *)objects;{
    NSParameterAssert(objects && [objects count]);
    if ([objects count] == 1) {
        return [self insertWithObject:[objects firstObject]];
    }
    return [self insertWithObjectsWithBlock:^id<MDDObject>(NSUInteger index, BOOL *stop) {
        *stop = index >= (objects.count - 1);
        return objects[index];
    } result:^(BOOL state, UInt64 rowID, NSUInteger index, BOOL *stop) {
        id<MDDObject> object = objects[index];
        if (![object objectID]) object.objectID = [@(rowID) description];
    }];
}

- (BOOL)insertWithObjectsWithBlock:(id<MDDObject>(^)(NSUInteger index, BOOL *stop))block result:(void (^)(BOOL state, UInt64 rowID, NSUInteger index, BOOL *stop))result;{
    return [self executeInsert:^MDDTokenDescription *(NSUInteger index, BOOL *stop) {
        id<MDDObject> object = block(index, stop);
        MDDTableInfo *tableInfo = [[self database] requireTableInfoWithClass:[object class]];
        NSParameterAssert(tableInfo);
        
        return [MDDInserter descriptionWithObject:object tableInfo:tableInfo];
    } result:^(BOOL state, UInt64 rowID, NSUInteger index, BOOL *stop) {
        if (result) result(state, rowID, index, stop);
    }];
}

#pragma mark - Update

- (BOOL)updateWithObject:(NSObject<MDDObject> *)object;{
    NSParameterAssert(object);
    
    return [self updateWithObject:object properties:nil];
}

- (BOOL)updateWithObject:(NSObject<MDDObject> *)object properties:(NSSet *)properties{
    NSSet *ignoredProperties = [NSSet setWithObject:MDDObjectObjectIDName];
    MDDCondition *condition = [MDDCondition conditionWithPrimaryValue:[object objectID]];
    MDDConditionSet *conditionSet = [MDDConditionSet setWithCondition:condition];
    
    return [self updateWithObject:object properties:properties ignoredProperties:ignoredProperties conditionSet:conditionSet];
}

- (BOOL)updateWithObject:(NSObject<MDDObject> *)object properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties{
    NSMutableSet *mutableIgnoredProperties = [NSMutableSet setWithObject:MDDObjectObjectIDName];
    if (ignoredProperties) {
        [mutableIgnoredProperties unionSet:ignoredProperties];
    }
    MDDCondition *condition = [MDDCondition conditionWithPrimaryValue:[object objectID]];
    MDDConditionSet *conditionSet = [MDDConditionSet setWithCondition:condition];
    
    return [self updateWithObject:object properties:properties ignoredProperties:mutableIgnoredProperties conditionSet:conditionSet];
}

- (BOOL)updateWithObject:(NSObject<MDDObject> *)object properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties conditionSet:(MDDConditionSet *)conditionSet;{
    NSParameterAssert(object);
    
    MDDTableInfo *tableInfo = [[self database] requireTableInfoWithClass:[object class]];
    NSParameterAssert(tableInfo);
    
    if (!conditionSet) {
        conditionSet = [self defaultUpdateConditionSetWithTableInfo:tableInfo object:object];
    }
    
    NSMutableSet *rquiredIgnoredProperties = [ignoredProperties ?: [NSSet set] mutableCopy];
    [rquiredIgnoredProperties addObjectsFromArray:[conditionSet allKeys]];
    
    MDDTokenDescription *description = [MDDUpdater descriptionWithObject:object properties:properties ignoredProperties:rquiredIgnoredProperties conditionSet:conditionSet tableInfo:tableInfo];
    NSParameterAssert(description);
    
    return [self executeUpdateDescription:description];
}

- (BOOL)updateWithObjects:(NSArray<MDDObject> *)objects;{
    NSParameterAssert(objects && [objects count]);
    return [self updateWithObjects:objects properties:nil ignoredProperties:nil];
}

- (BOOL)updateWithObjects:(NSArray<MDDObject> *)objects properties:(NSSet *)properties{
    NSParameterAssert(objects && [objects count]);
    return [self updateWithObjects:objects properties:properties ignoredProperties:nil];
}

- (BOOL)updateWithObjects:(NSArray<MDDObject> *)objects properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties;{
    NSParameterAssert(objects && [objects count]);
    return [self updateWithObjects:objects properties:properties ignoredProperties:ignoredProperties conditionSet:nil];
}

- (MDDConditionSet *)defaultUpdateConditionSetWithTableInfo:(MDDTableInfo *)tableInfo object:(id)object{
    NSMutableArray<MDDCondition *> *conditions = [[NSMutableArray alloc] init];
    for (NSString *propertyName in [tableInfo primaryProperties]) {
        MDDCondition *condition = [MDDCondition conditionWithKey:propertyName value:[object valueForKey:propertyName]];
        NSParameterAssert(condition);
        [conditions addObject:condition];
    }
    return [MDDConditionSet setWithConditions:conditions];
}

- (BOOL)updateWithObjects:(NSArray<MDDObject> *)objects properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties conditionSet:(MDDConditionSet *)conditionSet;{
    NSParameterAssert(objects && [objects count]);
    if ([objects count] == 1) {
        return [self updateWithObject:[objects firstObject] properties:properties ignoredProperties:ignoredProperties conditionSet:conditionSet];
    }
    
    ignoredProperties = ignoredProperties ?: [NSSet set];
    
    return [self updateWithObjectsWithBlock:^id<MDDObject>(NSUInteger index, NSSet<NSString *> **propertiesPtr, NSSet<NSString *> **ignoredPropertiesPtr, MDDConditionSet **conditionSetPtr, BOOL *stop) {
        *stop = index >= (objects.count - 1);
        
        *propertiesPtr = properties;
        *ignoredPropertiesPtr = ignoredProperties;
        *conditionSetPtr = conditionSet;
        
        return objects[index];
    } result:^(BOOL state, NSUInteger index, BOOL *stop) {
        *stop = !state;
    }];
}

- (BOOL)updateWithObjects:(NSArray<MDDObject> *)objects properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties conditionKeys:(NSArray<NSString *> *)conditionKeys;{
    NSParameterAssert(objects && [objects count]);
    
    ignoredProperties = ignoredProperties ?: [NSSet set];
    conditionKeys = conditionKeys && [conditionKeys count] ? conditionKeys : @[MDDObjectObjectIDName];
    
    return [self updateWithObjectsWithBlock:^id<MDDObject>(NSUInteger index, NSSet<NSString *> **propertiesPtr, NSSet<NSString *> **ignoredPropertiesPtr, MDDConditionSet **conditionSetPtr, BOOL *stop) {
        *stop = index >= (objects.count - 1);
        NSObject<MDDObject> *object = objects[index];
        
        NSMutableArray<MDDCondition *> *conditions = [[NSMutableArray alloc] init];
        for (NSString *conditionKey in conditionKeys) {
            MDDCondition *condition = [MDDCondition conditionWithKey:conditionKey value:[object valueForKey:conditionKey]];
            NSParameterAssert(condition);
            [conditions addObject:condition];
        }
        *propertiesPtr = properties.copy;
        *ignoredPropertiesPtr = ignoredProperties.copy;
        *conditionSetPtr = [MDDConditionSet setWithConditions:conditions];
        
        return object;
    } result:nil];
}

- (BOOL)updateWithObjectsWithBlock:(id<MDDObject>(^)(NSUInteger index, NSSet<NSString *> **propertiesPtr, NSSet<NSString *> **ignoredPropertiesPtr, MDDConditionSet **conditionSetPtr, BOOL *stop))block result:(void (^)(BOOL state, NSUInteger index, BOOL *stop))result;{
    return [self executeUpdate:^MDDTokenDescription *(NSUInteger index, BOOL *stop) {
        NSSet<NSString *> *properties = nil;
        NSSet<NSString *> *ignoredProperties = nil;
        MDDConditionSet *conditionSet = nil;
        id<MDDObject> object = block(index, &properties, &ignoredProperties, &conditionSet, stop);
        MDDTableInfo *tableInfo = [[self database] requireTableInfoWithClass:[object class]];
        NSParameterAssert(tableInfo);
        
        if (!conditionSet) {
            conditionSet = [self defaultUpdateConditionSetWithTableInfo:tableInfo object:object];
        }
        NSMutableSet *rquiredIgnoredProperties = [ignoredProperties ?: [NSSet set] mutableCopy];
        [rquiredIgnoredProperties addObjectsFromArray:[conditionSet allKeys]];
        
        return [MDDUpdater descriptionWithObject:object properties:properties ignoredProperties:rquiredIgnoredProperties conditionSet:conditionSet tableInfo:tableInfo];
    } result:nil];
}

- (BOOL)updateWithPrimaryValue:(id)primaryValue key:(NSString *)key value:(id)value;{
    return [self updateWithPrimaryValue:primaryValue key:key value:value operation:MDDOperationEqual];
}

- (BOOL)updateWithPrimaryValue:(id)primaryValue key:(NSString *)key value:(id)value operation:(MDDOperation)operation;{
    return [self updateWithKey:key value:value operation:operation conditionKey:nil conditionValue:primaryValue];
}

- (BOOL)updateWithKey:(NSString *)key value:(id)value operation:(MDDOperation)operation conditionKey:(NSString *)conditionKey conditionValue:(id)conditionValue{
    MDDCondition *condition = [MDDCondition conditionWithKey:conditionKey value:conditionValue operation:MDDOperationEqual];
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
    
    MDDSetter *setter = [MDDSetter setterWithKey:key value:value operation:operation];
    
    return [self updateWithSetters:@[setter] conditionSet:conditionSet];
}

#pragma mark - Update - Provide key-values and conditions

- (BOOL)updateWithKeyValues:(NSDictionary *)keyValues conditionSet:(MDDConditionSet *)conditionSet;{
    NSMutableArray *setters = [NSMutableArray new];
    for (NSString *key in [keyValues allKeys]) {
        id value = keyValues[key];
        [setters addObject:[MDDSetter setterWithKey:key value:value]];
    }
    return [self updateWithSetters:setters conditionSet:conditionSet];
}

#pragma mark - Update - Provide setter and conditions

- (BOOL)updateWithSetters:(NSArray<MDDSetter *> *)setters conditionSet:(MDDConditionSet *)conditionSet;{
    NSParameterAssert(setters && [setters count]);
    Class class = [self modelClass];
    
    MDDUpdater *updater = [MDDUpdater updaterWithSetter:setters conditionSet:conditionSet];
    NSParameterAssert(updater);
    
    MDDTableInfo *tableInfo = [[self database] requireTableInfoWithClass:class];
    NSParameterAssert(tableInfo);
    
    MDDTokenDescription *description = [MDDUpdater descriptionWithUpdater:updater tableInfo:tableInfo];
    NSParameterAssert(description);
    
    return [self executeUpdateDescription:description];
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
    MDDCondition *condition = [MDDCondition conditionWithKey:key value:value operation:operation];
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
    
    MDDCondition *condition = [MDDCondition conditionWithKey:key value:value operation:MDDOperationLike];
    NSParameterAssert(condition);
    
    return [self deleteWithConditionSet:[MDDConditionSet setWithCondition:condition]];
}

- (BOOL)deleteWithKey:(NSString *)key inValues:(NSSet *)values;{
    MDDCondition *condition = [MDDCondition conditionWithKey:key value:[values allObjects] operation:MDDOperationIn];
    NSParameterAssert(condition);
    
    return [self deleteWithConditionSet:[MDDConditionSet setWithCondition:condition]];
}

#pragma mark - Delete - Provide conditions

- (BOOL)deleteWithConditionSet:(MDDConditionSet *)conditionSet;{
    NSParameterAssert(conditionSet);
    Class class = [self modelClass];
    
    MDDDeleter *deleter = [MDDDeleter deleterWithConditionSet:conditionSet];
    NSParameterAssert(deleter);
    
    MDDTableInfo *tableInfo = [[self database] requireTableInfoWithClass:class];
    NSParameterAssert(tableInfo);
    
    MDDTokenDescription *description = [MDDDeleter descriptionWithDeleter:deleter tableInfo:tableInfo];
    NSParameterAssert(description);
    
    return [self executeUpdateDescription:description];
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
    
    MDDCondition *condition = [MDDCondition conditionWithKey:key value:[values allObjects] operation:operation];
    MDDConditionSet *conditionSet = [MDDConditionSet setWithCondition:condition];
    
    return [self queryWithClass:[self modelClass] conditionSet:conditionSet range:range orderByKey:orderKey ascending:ascending];
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
        MDDCondition *condition = [MDDCondition conditionWithKey:key value:value operation:operation];
        conditionSet = [MDDConditionSet setWithCondition:condition];
    }
    
    return [self queryWithClass:[self modelClass] conditionSet:conditionSet range:range orderByKey:orderKey ascending:ascending];
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
    MDDCondition *condition = [MDDCondition conditionWithKey:key value:expression operation:MDDOperationLike];
    MDDConditionSet *conditionSet = [MDDConditionSet setWithCondition:condition];
    
    return [self queryWithClass:[self modelClass] conditionSet:conditionSet range:range orderByKey:orderKey ascending:ascending];
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
    return [self queryWithClass:[self modelClass] conditionSet:conditionSet range:range orderByKey:orderKey ascending:ascending];
}

- (NSArray *)queryWithConditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range;{
    return [self queryWithClass:[self modelClass] conditionSet:conditionSet sorts:sorts range:range];
}

#pragma mark - Fetch - Provide class

- (NSArray *)queryWithClass:(Class<MDDObject>)class conditionSet:(MDDConditionSet *)conditionSet;{
    return [self queryWithClass:class conditionSet:conditionSet range:(NSRange){0, 0}];
}

- (NSArray *)queryWithClass:(Class<MDDObject>)class conditionSet:(MDDConditionSet *)conditionSet range:(NSRange)range;{
    return [self queryWithClass:class conditionSet:conditionSet range:range orderByKey:nil ascending:YES];
}

- (NSArray *)queryWithClass:(Class<MDDObject>)class conditionSet:(MDDConditionSet *)conditionSet range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;{
    MDDSort *sort = [orderKey length] ? [MDDSort sortWithKey:orderKey ascending:ascending] : nil;
    
    return [self queryWithClass:class conditionSet:conditionSet sorts:sort ? @[sort] : nil range:range];
}

- (NSArray *)queryWithClass:(Class<MDDObject>)class conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range;{
    NSParameterAssert(class);
    
    MDDQuery *query = [MDDQuery queryWithKeys:nil sorts:sorts conditionSet:conditionSet];
    NSParameterAssert(query);
    
    MDDTableInfo *tableInfo = [[self database] requireTableInfoWithClass:class];
    NSParameterAssert(tableInfo);
    
    MDDTokenDescription *description = [MDDQuery descriptionWithQuery:query range:range tableInfo:tableInfo];
    NSParameterAssert(description);
    
    __block NSMutableArray *models = [NSMutableArray new];
    [self executeQueryDescription:description block:^(NSDictionary *dictionary) {
        id object = [class objectWithDictionary:dictionary];
        
        if (object) [models addObject:object];
    }];
    
    return models;
}

- (BOOL)queryWithBlock:(MDDQuery *(^)(NSRange *range, NSUInteger index, BOOL *stop))block result:(void (^)(id<MDDObject> object))resultBlock;{
    return [self queryWithClass:[self modelClass] block:block result:resultBlock];
}

- (BOOL)queryWithClass:(Class<MDDObject>)class block:(MDDQuery *(^)(NSRange *range, NSUInteger index, BOOL *stop))block result:(void (^)(id<MDDObject> object))resultBlock;{
    NSParameterAssert(class);
    
    MDDTableInfo *tableInfo = [[self database] requireTableInfoWithClass:class];
    NSParameterAssert(tableInfo);
    
    return [self executeQueryDescription:^MDDTokenDescription *(NSUInteger index, BOOL *stop) {
        NSRange range;
        MDDQuery *query = block(&range, index, stop);
        NSParameterAssert(query);
        
        return [MDDQuery descriptionWithQuery:query range:range tableInfo:tableInfo];
    } result:^(NSUInteger index, NSDictionary *dictionary, BOOL *stop) {
        id object = [class objectWithDictionary:dictionary];
        
        if (resultBlock) resultBlock(object);
    }];
}


#pragma mark - Fetch - Provide function

- (NSUInteger)queryCountWithKey:(NSString *)key value:(id)value{
    MDDCondition *condition = [MDDCondition conditionWithKey:key value:value];
    MDDConditionSet *conditionSet = condition ? [MDDConditionSet setWithCondition:condition] : nil;
    
    return [self queryCountWithConditionSet:conditionSet];
}

- (NSUInteger)queryCountWithConditionSet:(MDDConditionSet *)conditionSet;{
    return [self queryCountWithKey:nil conditionSet:conditionSet];
}

- (NSUInteger)queryCountWithKey:(NSString *)key conditionSet:(MDDConditionSet *)conditionSet;{
    return [[self queryWithKey:key function:MDDFunctionCOUNT conditionSet:conditionSet] unsignedIntegerValue];
}

- (id)queryWithKey:(NSString *)key function:(MDDFunction)fuction conditionSet:(MDDConditionSet *)conditionSet;{
    MDDTableInfo *tableInfo = [[self database] requireTableInfoWithClass:[self modelClass]];
    NSParameterAssert(tableInfo);
    
    MDDFunctionQuery *query = [MDDFunctionQuery functionQueryWithKey:key function:fuction conditionSet:conditionSet];
    
    NSString *alias = @"function_result";
    MDDTokenDescription *description = [MDDFunctionQuery descriptionWithQuery:query alias:alias tableInfo:tableInfo];
    
    __block id result = nil;
    [self executeQueryDescription:description block:^(NSDictionary *dictionary) {
        result = dictionary[alias];
    }];
    return result == [NSNull null] ? nil : result;
}

- (BOOL)functionQueries:(MDDFunctionQuery *(^)(NSUInteger index, BOOL *stop))block result:(void (^)(NSUInteger index, id value))resultBlock{
    NSMutableArray<MDDTokenDescription *> *descriptions = [NSMutableArray new];
    MDDTableInfo *tableInfo = [[self database] requireTableInfoWithClass:[self modelClass]];
    NSParameterAssert(tableInfo);
    
    NSString *alias = @"function_result";
    return [self executeQueryDescription:^MDDTokenDescription *(NSUInteger index, BOOL *stop) {
        MDDFunctionQuery *query = block(index, stop);
        MDDTokenDescription *description = [MDDFunctionQuery descriptionWithQuery:query alias:alias tableInfo:tableInfo];
        if (!description) return nil;
        
        [descriptions addObject:description];
        
        return description;
    } result:^(NSUInteger index, NSDictionary *dictionary, BOOL *stop) {
        id result = dictionary[alias];
        if (resultBlock) resultBlock(index, result == [NSNull null] ? nil : result);
    }];
}

@end
