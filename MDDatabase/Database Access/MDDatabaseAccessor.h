//
//  MDDatabaseAccessor.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/8/8.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDQueueObject.h"
#import "MDDatabaseRange.h"
#import "MDDatabaseAccessorConstants.h"

@protocol MDDatabaseObject;
@class MDDatabase, MDDatabaseConditionDescriptor, MDDatabaseSetterDescriptor, MDDatabaseSortDescriptor, MDDatabaseQueryDescriptor, MDDatabaseFunctionQuery;
@interface MDDatabaseAccessor : MDQueueObject

@property (nonatomic, strong, readonly) MDDatabase *database;
@property (nonatomic, strong, readonly) Class<MDDatabaseObject> modelClass;

- (instancetype)initWithModelClass:(Class<MDDatabaseObject>)modelClass database:(MDDatabase *)database;

#pragma mark - Append
- (BOOL)appendWithObject:(id<MDDatabaseObject>)object;
- (BOOL)appendWithObjects:(NSArray<MDDatabaseObject> *)objects;

- (BOOL)appendWithObjectsWithBlock:(id<MDDatabaseObject>(^)(NSUInteger index, BOOL *stop))block result:(void (^)(BOOL state, UInt64 rowID, NSUInteger index, BOOL *stop))result;

#pragma mark - Update

- (BOOL)updateWithObject:(NSObject<MDDatabaseObject> *)object;
- (BOOL)updateWithObject:(NSObject<MDDatabaseObject> *)object properties:(NSSet *)properties;
- (BOOL)updateWithObject:(NSObject<MDDatabaseObject> *)object properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties;
- (BOOL)updateWithObject:(NSObject<MDDatabaseObject> *)object properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;

- (BOOL)updateWithObjects:(NSArray<MDDatabaseObject> *)objects;
- (BOOL)updateWithObjects:(NSArray<MDDatabaseObject> *)objects properties:(NSSet *)properties;
- (BOOL)updateWithObjects:(NSArray<MDDatabaseObject> *)objects properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties;
- (BOOL)updateWithObjects:(NSArray<MDDatabaseObject> *)objects properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;

- (BOOL)updateWithObjects:(NSArray<MDDatabaseObject> *)objects properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties conditionKeys:(NSArray<NSString *> *)conditionKeys;

- (BOOL)updateWithObjectsWithBlock:(id<MDDatabaseObject>(^)(NSUInteger index, NSSet<NSString *> **propertiesPtr, NSSet<NSString *> **ignoredPropertiesPtr, NSArray<MDDatabaseConditionDescriptor *> **conditionsPtr, BOOL *stop))block result:(void (^)(BOOL state, NSUInteger index, BOOL *stop))result;

- (BOOL)updateWithPrimaryValue:(id)primaryValue key:(NSString *)key value:(id)value;
- (BOOL)updateWithPrimaryValue:(id)primaryValue key:(NSString *)key value:(id)value operation:(MDDatabaseOperation)operation;
- (BOOL)updateWithKey:(NSString *)key value:(id)value operation:(MDDatabaseOperation)operation conditionKey:(NSString *)conditionKey conditionValue:(id)conditionValue;
- (BOOL)updateWithKey:(NSString *)key value:(id)value conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;
- (BOOL)updateWithKey:(NSString *)key value:(id)value operation:(MDDatabaseOperation)operation conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;
- (BOOL)updateWithKeyValues:(NSDictionary *)keyValues conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;
- (BOOL)updateWithSetters:(NSArray<MDDatabaseSetterDescriptor *> *)settters conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;

#pragma mark - Delete

- (BOOL)deleteWithPrimaryValue:(id)value;
- (BOOL)deleteWithPrimaryValues:(NSSet *)primaryValues;
- (BOOL)deleteWithKey:(NSString *)key value:(id)value;
- (BOOL)deleteWithKey:(NSString *)key value:(id)value operation:(MDDatabaseOperation)operation;
- (BOOL)deleteWithKey:(NSString *)key likeValue:(id)value;
- (BOOL)deleteWithKey:(NSString *)key likeValue:(id)value format:(NSString *)format;
- (BOOL)deleteWithKey:(NSString *)key inValues:(NSSet *)values;
- (BOOL)deleteWithConditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;

#pragma mark - Fetch

- (id)queryWithPrimaryValue:(id)value;

- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues;
- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues range:(NSRange)range;
- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;

- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues operation:(MDDatabaseOperation)operation range:(NSRange)range;
- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues operation:(MDDatabaseOperation)operation range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;

- (NSArray *)queryWithKey:(NSString *)key inValues:(NSSet *)values;
- (NSArray *)queryWithKey:(NSString *)key inValues:(NSSet *)values range:(NSRange)range;
- (NSArray *)queryWithKey:(NSString *)key inValues:(NSSet *)values range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;
- (NSArray *)queryWithKey:(NSString *)key inValues:(NSSet *)values operation:(MDDatabaseOperation)operation range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;

// Default is MDDatabaseOperationEqual
- (NSArray *)queryWithKey:(NSString *)key value:(id)value;
- (NSArray *)queryWithKey:(NSString *)key value:(id)value range:(NSRange)range;
- (NSArray *)queryWithKey:(NSString *)key value:(id)value range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;

- (NSArray *)queryWithKey:(NSString *)key value:(id)value operation:(MDDatabaseOperation)operation;
- (NSArray *)queryWithKey:(NSString *)key value:(id)value operation:(MDDatabaseOperation)operation range:(NSRange)range;
- (NSArray *)queryWithKey:(NSString *)key value:(id)value operation:(MDDatabaseOperation)operation range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;

- (NSArray *)queryWithKey:(NSString *)key likeValue:(id)value format:(NSString *)format;
- (NSArray *)queryWithKey:(NSString *)key likeValue:(id)value format:(NSString *)format range:(NSRange)range;
- (NSArray *)queryWithKey:(NSString *)key likeValue:(id)value format:(NSString *)format range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;

- (NSArray *)queryAllRows;
- (NSArray *)queryWithConditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;
- (NSArray *)queryWithConditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions range:(NSRange)range;
- (NSArray *)queryWithConditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;
- (NSArray *)queryWithConditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions sorts:(NSArray<MDDatabaseSortDescriptor *> *)sorts range:(NSRange)range;

- (NSArray *)queryWithClass:(Class<MDDatabaseObject>)class conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;
- (NSArray *)queryWithClass:(Class<MDDatabaseObject>)class conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions range:(NSRange)range;
- (NSArray *)queryWithClass:(Class<MDDatabaseObject>)class conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;
- (NSArray *)queryWithClass:(Class<MDDatabaseObject>)class conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions sorts:(NSArray<MDDatabaseSortDescriptor *> *)sorts range:(NSRange)range;

- (BOOL)queryWithBlock:(MDDatabaseQueryDescriptor *(^)(NSRange *range, NSUInteger index, BOOL *stop))block result:(void (^)(id<MDDatabaseObject> object))result;
- (BOOL)queryWithClass:(Class<MDDatabaseObject>)class block:(MDDatabaseQueryDescriptor *(^)(NSRange *range, NSUInteger index, BOOL *stop))block result:(void (^)(id<MDDatabaseObject> object))resultBlock;

- (NSUInteger)queryCountWithKey:(NSString *)key value:(id)value;
- (NSUInteger)queryCountWithConditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;
- (NSUInteger)queryCountWithKey:(NSString *)key conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;
- (id)queryWithKey:(NSString *)key function:(MDDatabaseFunction)fuction conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;

- (BOOL)functionQuerie:(MDDatabaseFunctionQuery *(^)(NSUInteger index, BOOL *stop))block result:(void (^)(NSUInteger index, id value))resultBlock;

@end
