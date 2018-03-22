//
//  MDDatabaseAccessor.m
//  MDDatabase
//
//  Created by xulinfeng on 2017/8/8.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDatabaseAccessor.h"
#import "MDDatabaseAccessor+MDDatabase.h"

#import "MDDatabaseDescriptor+Private.h"

#import "MDDatabase.h"
#import "MDDatabaseTableInfo.h"
#import "MDDatabaseColumn.h"

#import "MDDatabaseObject.h"

@implementation MDDatabaseAccessor

- (instancetype)initWithModelClass:(Class<MDDatabaseObject>)modelClass database:(MDDatabase *)database;{
    if (self = [super init]) {
        _modelClass = modelClass;
        _database = database;
        
        [database attachTableIfNeedsWithClass:modelClass];
    }
    return self;
}

#pragma mark - Append

- (BOOL)appendWithObject:(id<MDDatabaseObject>)object;{
    NSParameterAssert(object);
    
    MDDatabaseTableInfo *tableInfo = [[self database] requireTableInfoWithClass:[object class]];
    NSParameterAssert(tableInfo);
    
    MDDatabaseTokenDescription *description = [MDDatabaseInserterDescriptor descriptionWithObject:object tableInfo:tableInfo];
    NSParameterAssert(description);
    
    return [self executeInsertDescription:description completion:^(NSUInteger rowID) {
        if (![object objectID]) object.objectID = [@(rowID) description];
    }];
}

- (BOOL)appendWithObjects:(NSArray<MDDatabaseObject> *)objects;{
    NSParameterAssert(objects && [objects count]);
    if ([objects count] == 1) {
        return [self appendWithObject:[objects firstObject]];
    }
    return [self appendWithObjectsWithBlock:^id<MDDatabaseObject>(NSUInteger index, BOOL *stop) {
        *stop = index >= (objects.count - 1);
        return objects[index];
    } result:^(BOOL state, UInt64 rowID, NSUInteger index, BOOL *stop) {
        id<MDDatabaseObject> object = objects[index];
        if (![object objectID]) object.objectID = [@(rowID) description];
    }];
}

- (BOOL)appendWithObjectsWithBlock:(id<MDDatabaseObject>(^)(NSUInteger index, BOOL *stop))block result:(void (^)(BOOL state, UInt64 rowID, NSUInteger index, BOOL *stop))result;{
    return [self executeInsert:^MDDatabaseTokenDescription *(NSUInteger index, BOOL *stop) {
        id<MDDatabaseObject> object = block(index, stop);
        MDDatabaseTableInfo *tableInfo = [[self database] requireTableInfoWithClass:[object class]];
        NSParameterAssert(tableInfo);
        
        return [MDDatabaseInserterDescriptor descriptionWithObject:object tableInfo:tableInfo];
    } result:^(BOOL state, UInt64 rowID, NSUInteger index, BOOL *stop) {
        if (result) result(state, rowID, index, stop);
    }];
}

#pragma mark - Update

- (BOOL)updateWithObject:(NSObject<MDDatabaseObject> *)object;{
    NSParameterAssert(object);

    return [self updateWithObject:object properties:nil];
}

- (BOOL)updateWithObject:(NSObject<MDDatabaseObject> *)object properties:(NSSet *)properties{
    NSSet *ignoredProperties = [NSSet setWithObject:MDDatabaseObjectObjectIDName];
    MDDatabaseConditionDescriptor *condition = [MDDatabaseConditionDescriptor conditionWithPrimaryValue:[object objectID]];
    
    return [self updateWithObject:object properties:properties ignoredProperties:ignoredProperties conditions:@[condition]];
}

- (BOOL)updateWithObject:(NSObject<MDDatabaseObject> *)object properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties{
    NSMutableSet *mutableIgnoredProperties = [NSMutableSet setWithObject:MDDatabaseObjectObjectIDName];
    if (ignoredProperties) {
        [mutableIgnoredProperties unionSet:ignoredProperties];
    }
    MDDatabaseConditionDescriptor *condition = [MDDatabaseConditionDescriptor conditionWithPrimaryValue:[object objectID]];
    
    return [self updateWithObject:object properties:properties ignoredProperties:mutableIgnoredProperties conditions:@[condition]];
}

- (BOOL)updateWithObject:(NSObject<MDDatabaseObject> *)object properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;{
    NSParameterAssert(object);
    
    MDDatabaseTableInfo *tableInfo = [[self database] requireTableInfoWithClass:[object class]];
    NSParameterAssert(tableInfo);
    
    if (!conditions || ![conditions count]) {
        conditions = [self defaultUpdateConditionsWithTableInfo:tableInfo object:object];
    }
    
    NSMutableSet *rquiredIgnoredProperties = [ignoredProperties ?: [NSSet set] mutableCopy];
    [rquiredIgnoredProperties addObjectsFromArray:[conditions valueForKey:@"key"]];
    
    MDDatabaseTokenDescription *description = [MDDatabaseUpdaterDescriptor descriptionWithObject:object properties:properties ignoredProperties:rquiredIgnoredProperties conditions:conditions tableInfo:tableInfo];
    NSParameterAssert(description);
    
    return [self executeUpdateDescription:description];
}

- (BOOL)updateWithObjects:(NSArray<MDDatabaseObject> *)objects;{
    NSParameterAssert(objects && [objects count]);
    return [self updateWithObjects:objects properties:nil ignoredProperties:nil];
}

- (BOOL)updateWithObjects:(NSArray<MDDatabaseObject> *)objects properties:(NSSet *)properties{
    NSParameterAssert(objects && [objects count]);
    return [self updateWithObjects:objects properties:properties ignoredProperties:nil];
}

- (BOOL)updateWithObjects:(NSArray<MDDatabaseObject> *)objects properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties;{
    NSParameterAssert(objects && [objects count]);
    return [self updateWithObjects:objects properties:properties ignoredProperties:ignoredProperties conditions:nil];
}

- (NSArray<MDDatabaseConditionDescriptor *> *)defaultUpdateConditionsWithTableInfo:(MDDatabaseTableInfo *)tableInfo object:(id)object{
    NSMutableArray<MDDatabaseConditionDescriptor *> *conditions = [[NSMutableArray alloc] init];
    for (NSString *propertyName in [tableInfo primaryProperties]) {
        MDDatabaseConditionDescriptor *condition = [MDDatabaseConditionDescriptor conditionWithKey:propertyName value:[object valueForKey:propertyName]];
        NSParameterAssert(condition);
        [conditions addObject:condition];
    }
    return [conditions copy];
}

- (BOOL)updateWithObjects:(NSArray<MDDatabaseObject> *)objects properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;{
    NSParameterAssert(objects && [objects count]);
    if ([objects count] == 1) {
        return [self updateWithObject:[objects firstObject] properties:properties ignoredProperties:ignoredProperties conditions:conditions];
    }
    
    ignoredProperties = ignoredProperties ?: [NSSet set];
  
    return [self updateWithObjectsWithBlock:^id<MDDatabaseObject>(NSUInteger index, NSSet<NSString *> **propertiesPtr, NSSet<NSString *> **ignoredPropertiesPtr, NSArray<MDDatabaseConditionDescriptor *> **conditionsPtr, BOOL *stop) {
        *stop = index >= (objects.count - 1);
        
        *propertiesPtr = properties;
        *ignoredPropertiesPtr = ignoredProperties;
        *conditionsPtr = conditions;
        
        return objects[index];
    } result:^(BOOL state, NSUInteger index, BOOL *stop) {
        *stop = !state;
    }];
}

- (BOOL)updateWithObjects:(NSArray<MDDatabaseObject> *)objects properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties conditionKeys:(NSArray<NSString *> *)conditionKeys;{
    NSParameterAssert(objects && [objects count]);
    
    ignoredProperties = ignoredProperties ?: [NSSet set];
    conditionKeys = conditionKeys && [conditionKeys count] ? conditionKeys : @[MDDatabaseObjectObjectIDName];
    
    return [self updateWithObjectsWithBlock:^id<MDDatabaseObject>(NSUInteger index, NSSet<NSString *> **propertiesPtr, NSSet<NSString *> **ignoredPropertiesPtr, NSArray<MDDatabaseConditionDescriptor *> **conditionsPtr, BOOL *stop) {
        *stop = index >= (objects.count - 1);
        NSObject<MDDatabaseObject> *object = objects[index];
        
        NSMutableArray<MDDatabaseConditionDescriptor *> *conditions = [[NSMutableArray alloc] init];
        for (NSString *conditionKey in conditionKeys) {
            MDDatabaseConditionDescriptor *condition = [MDDatabaseConditionDescriptor conditionWithKey:conditionKey value:[object valueForKey:conditionKey]];
            NSParameterAssert(condition);
            [conditions addObject:condition];
        }
        *propertiesPtr = properties.copy;
        *ignoredPropertiesPtr = ignoredProperties.copy;
        *conditionsPtr = conditions.copy;
        
        return object;
    } result:nil];
}

- (BOOL)updateWithObjectsWithBlock:(id<MDDatabaseObject>(^)(NSUInteger index, NSSet<NSString *> **propertiesPtr, NSSet<NSString *> **ignoredPropertiesPtr, NSArray<MDDatabaseConditionDescriptor *> **conditionsPtr, BOOL *stop))block result:(void (^)(BOOL state, NSUInteger index, BOOL *stop))result;{
    return [self executeUpdate:^MDDatabaseTokenDescription *(NSUInteger index, BOOL *stop) {
        NSSet<NSString *> *properties = nil;
        NSSet<NSString *> *ignoredProperties = nil;
        NSArray<MDDatabaseConditionDescriptor *> *conditions = nil;
        id<MDDatabaseObject> object = block(index, &properties, &ignoredProperties, &conditions, stop);
        MDDatabaseTableInfo *tableInfo = [[self database] requireTableInfoWithClass:[object class]];
        NSParameterAssert(tableInfo);
        
        if (!conditions || ![conditions count]) {
            conditions = [self defaultUpdateConditionsWithTableInfo:tableInfo object:object];
        }
        NSMutableSet *rquiredIgnoredProperties = [ignoredProperties ?: [NSSet set] mutableCopy];
        [rquiredIgnoredProperties addObjectsFromArray:[conditions valueForKey:@"key"]];
        
        return [MDDatabaseUpdaterDescriptor descriptionWithObject:object properties:properties ignoredProperties:rquiredIgnoredProperties conditions:conditions tableInfo:tableInfo];
    } result:nil];
}

- (BOOL)updateWithPrimaryValue:(id)primaryValue key:(NSString *)key value:(id)value;{
    return [self updateWithPrimaryValue:primaryValue key:key value:value operation:MDDatabaseOperationEqual];
}

- (BOOL)updateWithPrimaryValue:(id)primaryValue key:(NSString *)key value:(id)value operation:(MDDatabaseOperation)operation;{
    return [self updateWithKey:key value:value operation:operation conditionKey:nil conditionValue:primaryValue];
}

- (BOOL)updateWithKey:(NSString *)key value:(id)value operation:(MDDatabaseOperation)operation conditionKey:(NSString *)conditionKey conditionValue:(id)conditionValue{
    MDDatabaseConditionDescriptor *condition = [MDDatabaseConditionDescriptor conditionWithKey:conditionKey value:conditionValue operation:MDDatabaseOperationEqual];
    NSParameterAssert(condition);
    
    return [self updateWithKey:key value:value operation:operation conditions:@[condition]];
}

- (BOOL)updateWithKey:(NSString *)key value:(id)value conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;{
    return [self updateWithKey:key value:value operation:MDDatabaseOperationEqual conditions:conditions];
}

- (BOOL)updateWithKey:(NSString *)key value:(id)value operation:(MDDatabaseOperation)operation conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;{
    key = key ?: (id)[NSNull null];
    value = value ?: [NSNull null];
    
    MDDatabaseSetterDescriptor *setter = [MDDatabaseSetterDescriptor setterWithKey:key value:value operation:operation];
    
    return [self updateWithSetters:@[setter] conditions:conditions];
}

#pragma mark - Update - Provide key-values and conditions

- (BOOL)updateWithKeyValues:(NSDictionary *)keyValues conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;{
    NSMutableArray *setters = [NSMutableArray new];
    for (NSString *key in [keyValues allKeys]) {
        id value = keyValues[key];
        [setters addObject:[MDDatabaseSetterDescriptor setterWithKey:key value:value]];
    }
    return [self updateWithSetters:setters conditions:conditions];
}

#pragma mark - Update - Provide setter and conditions

- (BOOL)updateWithSetters:(NSArray<MDDatabaseSetterDescriptor *> *)setters conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;{
    NSParameterAssert(setters && [setters count]);
    Class class = [self modelClass];
    
    MDDatabaseUpdaterDescriptor *updater = [MDDatabaseUpdaterDescriptor updaterWithSetter:setters conditions:conditions];
    NSParameterAssert(updater);
    
    MDDatabaseTableInfo *tableInfo = [[self database] requireTableInfoWithClass:class];
    NSParameterAssert(tableInfo);
    
    MDDatabaseTokenDescription *description = [MDDatabaseUpdaterDescriptor descriptionWithClass:class updater:updater tableInfo:tableInfo];
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
    return [self deleteWithKey:key value:value operation:MDDatabaseOperationEqual];
}

- (BOOL)deleteWithKey:(NSString *)key value:(id)value operation:(MDDatabaseOperation)operation;{
    MDDatabaseConditionDescriptor *condition = [MDDatabaseConditionDescriptor conditionWithKey:key value:value operation:operation];
    NSParameterAssert(condition);
    
    return [self deleteWithConditions:@[condition]];
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
    
    MDDatabaseConditionDescriptor *condition = [MDDatabaseConditionDescriptor conditionWithKey:key value:value operation:MDDatabaseOperationLike];
    NSParameterAssert(condition);
    
    return [self deleteWithConditions:@[condition]];
}

- (BOOL)deleteWithKey:(NSString *)key inValues:(NSSet *)values;{
    MDDatabaseConditionDescriptor *condition = [MDDatabaseConditionDescriptor conditionWithKey:key value:[values allObjects] operation:MDDatabaseOperationIn];
    NSParameterAssert(condition);
    
    return [self deleteWithConditions:@[condition]];
}

#pragma mark - Delete - Provide conditions

- (BOOL)deleteWithConditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions{
    NSParameterAssert(conditions && [conditions count]);
    Class class = [self modelClass];
    
    MDDatabaseDeleterDescriptor *deleter = [MDDatabaseDeleterDescriptor deleterWithConditions:conditions];
    NSParameterAssert(deleter);
    
    MDDatabaseTableInfo *tableInfo = [[self database] requireTableInfoWithClass:class];
    NSParameterAssert(tableInfo);
    
    MDDatabaseTokenDescription *description = [MDDatabaseDeleterDescriptor descriptionWithClass:class deleter:deleter tableInfo:tableInfo];
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
    return [self queryWithPrimaryValues:primaryValues operation:MDDatabaseOperationIn range:range orderByKey:orderKey ascending:ascending];
}

- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues operation:(MDDatabaseOperation)operation range:(NSRange)range{
    return [self queryWithPrimaryValues:primaryValues operation:operation range:range orderByKey:nil ascending:YES];
}

- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues operation:(MDDatabaseOperation)operation range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;{
    NSParameterAssert(operation == MDDatabaseOperationIn || operation == MDDatabaseOperationNotIn);
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
    return [self queryWithKey:key inValues:values operation:MDDatabaseOperationIn range:range orderByKey:orderKey ascending:ascending];
}
    
- (NSArray *)queryWithKey:(NSString *)key inValues:(NSSet *)values operation:(MDDatabaseOperation)operation range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;{
    NSParameterAssert(values && [values count]);
    NSParameterAssert(operation == MDDatabaseOperationIn || operation == MDDatabaseOperationNotIn);
    
    MDDatabaseConditionDescriptor *condition = [MDDatabaseConditionDescriptor conditionWithKey:key value:[values allObjects] operation:operation];
    return [self queryWithClass:[self modelClass] conditions:@[condition] range:range orderByKey:orderKey ascending:ascending];
}

#pragma mark - Fetch - Provide searching that key equal value

- (NSArray *)queryWithKey:(NSString *)key value:(id)value;{
    return [self queryWithKey:key value:value range:(NSRange){0, 0}];
}

- (NSArray *)queryWithKey:(NSString *)key value:(id)value range:(NSRange)range;{
    return [self queryWithKey:key value:value range:range orderByKey:nil ascending:YES];
}

- (NSArray *)queryWithKey:(NSString *)key value:(id)value range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;{
    return [self queryWithKey:key value:value operation:MDDatabaseOperationEqual range:range orderByKey:orderKey ascending:ascending];
}

- (NSArray *)queryWithKey:(NSString *)key value:(id)value operation:(MDDatabaseOperation)operation;{
    return [self queryWithKey:key value:value operation:operation range:(NSRange){0, 0}];
}

- (NSArray *)queryWithKey:(NSString *)key value:(id)value operation:(MDDatabaseOperation)operation range:(NSRange)range;{
    return [self queryWithKey:key value:value operation:operation range:range orderByKey:nil ascending:YES];
}

- (NSArray *)queryWithKey:(NSString *)key value:(id)value operation:(MDDatabaseOperation)operation range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;{
    
    MDDatabaseConditionDescriptor *condition = nil;
    if (key || value) {
        condition = [MDDatabaseConditionDescriptor conditionWithKey:key value:value operation:operation];
    }
    return [self queryWithClass:[self modelClass] conditions:condition ? @[condition] : nil range:range orderByKey:orderKey ascending:ascending];
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
    MDDatabaseConditionDescriptor *condition = [MDDatabaseConditionDescriptor conditionWithKey:key value:expression operation:MDDatabaseOperationLike];
    return [self queryWithClass:[self modelClass] conditions:@[condition] range:range orderByKey:orderKey ascending:ascending];
}

- (NSArray *)queryAllRows;{
    return [self queryWithConditions:nil];
}

#pragma mark - Fetch - Provide conditions

- (NSArray *)queryWithConditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;{
    return [self queryWithConditions:conditions range:(NSRange){0, 0}];
}

- (NSArray *)queryWithConditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions range:(NSRange)range;{
    return [self queryWithConditions:conditions range:range orderByKey:nil ascending:YES];
}

- (NSArray *)queryWithConditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;{
    return [self queryWithClass:[self modelClass] conditions:conditions range:range orderByKey:orderKey ascending:ascending];
}

- (NSArray *)queryWithConditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions sorts:(NSArray<MDDatabaseSortDescriptor *> *)sorts range:(NSRange)range;{
    return [self queryWithClass:[self modelClass] conditions:conditions sorts:sorts range:range];
}

#pragma mark - Fetch - Provide class

- (NSArray *)queryWithClass:(Class<MDDatabaseObject>)class conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;{
    return [self queryWithClass:class conditions:conditions range:(NSRange){0, 0}];
}

- (NSArray *)queryWithClass:(Class<MDDatabaseObject>)class conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions range:(NSRange)range;{
    return [self queryWithClass:class conditions:conditions range:range orderByKey:nil ascending:YES];
}

- (NSArray *)queryWithClass:(Class<MDDatabaseObject>)class conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;{
    MDDatabaseSortDescriptor *sort = [orderKey length] ? [MDDatabaseSortDescriptor sortWithKey:orderKey ascending:ascending] : nil;
    
    return [self queryWithClass:class conditions:conditions sorts:sort ? @[sort] : nil range:range];
}

- (NSArray *)queryWithClass:(Class<MDDatabaseObject>)class conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions sorts:(NSArray<MDDatabaseSortDescriptor *> *)sorts range:(NSRange)range;{
    NSParameterAssert(class);

    MDDatabaseQueryDescriptor *query = [MDDatabaseQueryDescriptor queryWithKeys:nil sorts:sorts conditions:conditions];
    NSParameterAssert(query);
    
    MDDatabaseTableInfo *tableInfo = [[self database] requireTableInfoWithClass:class];
    NSParameterAssert(tableInfo);
    
    MDDatabaseTokenDescription *description = [MDDatabaseQueryDescriptor descriptionWithClass:class query:query range:range tableInfo:tableInfo];
    NSParameterAssert(description);
    
    __block NSMutableArray *models = [NSMutableArray new];
    [self executeQueryDescription:description block:^(NSDictionary *dictionary) {
        id object = [class objectWithDictionary:dictionary];
        
        if (object) [models addObject:object];
    }];
    
    return models;
}

- (BOOL)queryWithBlock:(MDDatabaseQueryDescriptor *(^)(NSRange *range, NSUInteger index, BOOL *stop))block result:(void (^)(id<MDDatabaseObject> object))resultBlock;{
    return [self queryWithClass:[self modelClass] block:block result:resultBlock];
}

- (BOOL)queryWithClass:(Class<MDDatabaseObject>)class block:(MDDatabaseQueryDescriptor *(^)(NSRange *range, NSUInteger index, BOOL *stop))block result:(void (^)(id<MDDatabaseObject> object))resultBlock;{
    NSParameterAssert(class);
    
    MDDatabaseTableInfo *tableInfo = [[self database] requireTableInfoWithClass:class];
    NSParameterAssert(tableInfo);
    
    return [self executeQueryDescription:^MDDatabaseTokenDescription *(NSUInteger index, BOOL *stop) {
        NSRange range;
        MDDatabaseQueryDescriptor *query = block(&range, index, stop);
        NSParameterAssert(query);
        
        return [MDDatabaseQueryDescriptor descriptionWithClass:class query:query range:range tableInfo:tableInfo];
    } result:^(NSUInteger index, NSDictionary *dictionary, BOOL *stop) {
        id object = [class objectWithDictionary:dictionary];
        
        if (resultBlock) resultBlock(object);
    }];
}


#pragma mark - Fetch - Provide function

- (NSUInteger)queryCountWithKey:(NSString *)key value:(id)value{
    MDDatabaseConditionDescriptor *condition = [MDDatabaseConditionDescriptor conditionWithKey:key value:value];
    NSArray *conditions = condition ? @[condition] : nil;
    
    return [self queryCountWithConditions:conditions];
}

- (NSUInteger)queryCountWithConditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;{
    return [self queryCountWithKey:nil conditions:conditions];
}

- (NSUInteger)queryCountWithKey:(NSString *)key conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;{
    return [[self queryWithKey:key function:MDDatabaseFunctionCOUNT conditions:conditions] unsignedIntegerValue];
}

- (id)queryWithKey:(NSString *)key function:(MDDatabaseFunction)fuction conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;{
    MDDatabaseTableInfo *tableInfo = [[self database] requireTableInfoWithClass:[self modelClass]];
    NSParameterAssert(tableInfo);
    
    MDDatabaseFunctionQuery *query = [MDDatabaseFunctionQuery functionQueryWithKey:key function:fuction conditions:conditions];
    
    NSString *alias = @"function_result";
    MDDatabaseTokenDescription *description = [self tokenDescriptionWithFunctionQuery:query alias:alias tableInfo:tableInfo];
    
    __block id result = nil;
    [self executeQueryDescription:description block:^(NSDictionary *dictionary) {
        result = dictionary[alias];
    }];
    return result == [NSNull null] ? nil : result;
}

- (BOOL)functionQuerie:(MDDatabaseFunctionQuery *(^)(NSUInteger index, BOOL *stop))block result:(void (^)(NSUInteger index, id value))resultBlock{
    NSMutableArray<MDDatabaseTokenDescription *> *descriptions = [NSMutableArray new];
    MDDatabaseTableInfo *tableInfo = [[self database] requireTableInfoWithClass:[self modelClass]];
    NSParameterAssert(tableInfo);
    
    NSString *alias = @"function_result";
    return [self executeQueryDescription:^MDDatabaseTokenDescription *(NSUInteger index, BOOL *stop) {
        MDDatabaseFunctionQuery *query = block(index, stop);
        MDDatabaseTokenDescription *description = [self tokenDescriptionWithFunctionQuery:query alias:alias tableInfo:tableInfo];
        if (!description) return nil;
        
        [descriptions addObject:description];
        
        return description;
    } result:^(NSUInteger index, NSDictionary *dictionary, BOOL *stop) {
        id result = dictionary[alias];
        if (resultBlock) resultBlock(index, result == [NSNull null] ? nil : result);
    }];
}

- (MDDatabaseTokenDescription *)tokenDescriptionWithFunctionQuery:(MDDatabaseFunctionQuery *)query alias:(NSString *)alias tableInfo:(MDDatabaseTableInfo *)tableInfo{
    MDDatabaseColumn *column = [tableInfo columnForKey:query.key];
    NSParameterAssert(column);
    
    MDDatabaseTokenDescription *conditionDescription = [MDDatabaseConditionDescriptor descriptionWithClass:tableInfo.class conditions:query.conditions tableInfo:tableInfo];
    NSString *where = (conditionDescription && [conditionDescription tokenString]) ? [NSString stringWithFormat:@" WHERE %@", [conditionDescription tokenString]] : @"";
    
    NSString *SQL = [NSString stringWithFormat:@"SELECT %@(%@) AS %@ FROM %@ %@", query.function, [column name], alias, [tableInfo tableName], where];
    
    return [MDDatabaseTokenDescription descriptionWithTokenString:SQL values:[conditionDescription values]];
}

@end
