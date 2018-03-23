//
//  MDDAccessor.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/8/8.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDQueueObject.h"
#import "MDDRange.h"
#import "MDDAccessorConstants.h"

@protocol MDDObject;
@class MDDatabase, MDDConditionSet, MDDSetter, MDDSort, MDDQuery, MDDFunctionQuery;
@interface MDDAccessor : MDDQueueObject

@property (nonatomic, strong, readonly) MDDatabase *database;
@property (nonatomic, strong, readonly) Class<MDDObject> modelClass;

- (instancetype)initWithModelClass:(Class<MDDObject>)modelClass database:(MDDatabase *)database;

#pragma mark - Append
- (BOOL)appendWithObject:(id<MDDObject>)object;
- (BOOL)appendWithObjects:(NSArray<MDDObject> *)objects;

- (BOOL)appendWithObjectsWithBlock:(id<MDDObject>(^)(NSUInteger index, BOOL *stop))block result:(void (^)(BOOL state, UInt64 rowID, NSUInteger index, BOOL *stop))result;

#pragma mark - Update

- (BOOL)updateWithObject:(NSObject<MDDObject> *)object;
- (BOOL)updateWithObject:(NSObject<MDDObject> *)object properties:(NSSet *)properties;
- (BOOL)updateWithObject:(NSObject<MDDObject> *)object properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties;
- (BOOL)updateWithObject:(NSObject<MDDObject> *)object properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties conditionSet:(MDDConditionSet *)conditionSet;

- (BOOL)updateWithObjects:(NSArray<MDDObject> *)objects;
- (BOOL)updateWithObjects:(NSArray<MDDObject> *)objects properties:(NSSet *)properties;
- (BOOL)updateWithObjects:(NSArray<MDDObject> *)objects properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties;
- (BOOL)updateWithObjects:(NSArray<MDDObject> *)objects properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties conditionSet:(MDDConditionSet *)conditionSet;

- (BOOL)updateWithObjects:(NSArray<MDDObject> *)objects properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties conditionKeys:(NSArray<NSString *> *)conditionKeys;

- (BOOL)updateWithObjectsWithBlock:(id<MDDObject>(^)(NSUInteger index, NSSet<NSString *> **propertiesPtr, NSSet<NSString *> **ignoredPropertiesPtr, MDDConditionSet **conditionSetPtr, BOOL *stop))block result:(void (^)(BOOL state, NSUInteger index, BOOL *stop))result;

- (BOOL)updateWithPrimaryValue:(id)primaryValue key:(NSString *)key value:(id)value;
- (BOOL)updateWithPrimaryValue:(id)primaryValue key:(NSString *)key value:(id)value operation:(MDDOperation)operation;
- (BOOL)updateWithKey:(NSString *)key value:(id)value operation:(MDDOperation)operation conditionKey:(NSString *)conditionKey conditionValue:(id)conditionValue;
- (BOOL)updateWithKey:(NSString *)key value:(id)value conditionSet:(MDDConditionSet *)conditionSet;
- (BOOL)updateWithKey:(NSString *)key value:(id)value operation:(MDDOperation)operation conditionSet:(MDDConditionSet *)conditionSet;
- (BOOL)updateWithKeyValues:(NSDictionary *)keyValues conditionSet:(MDDConditionSet *)conditionSet;
- (BOOL)updateWithSetters:(NSArray<MDDSetter *> *)settters conditionSet:(MDDConditionSet *)conditionSet;

#pragma mark - Delete

- (BOOL)deleteWithPrimaryValue:(id)value;
- (BOOL)deleteWithPrimaryValues:(NSSet *)primaryValues;
- (BOOL)deleteWithKey:(NSString *)key value:(id)value;
- (BOOL)deleteWithKey:(NSString *)key value:(id)value operation:(MDDOperation)operation;
- (BOOL)deleteWithKey:(NSString *)key likeValue:(id)value;
- (BOOL)deleteWithKey:(NSString *)key likeValue:(id)value format:(NSString *)format;
- (BOOL)deleteWithKey:(NSString *)key inValues:(NSSet *)values;
- (BOOL)deleteWithConditionSet:(MDDConditionSet *)conditionSet;

#pragma mark - Fetch

- (id)queryWithPrimaryValue:(id)value;

- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues;
- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues range:(NSRange)range;
- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;

- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues operation:(MDDOperation)operation range:(NSRange)range;
- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues operation:(MDDOperation)operation range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;

- (NSArray *)queryWithKey:(NSString *)key inValues:(NSSet *)values;
- (NSArray *)queryWithKey:(NSString *)key inValues:(NSSet *)values range:(NSRange)range;
- (NSArray *)queryWithKey:(NSString *)key inValues:(NSSet *)values range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;
- (NSArray *)queryWithKey:(NSString *)key inValues:(NSSet *)values operation:(MDDOperation)operation range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;

// Default is MDDOperationEqual
- (NSArray *)queryWithKey:(NSString *)key value:(id)value;
- (NSArray *)queryWithKey:(NSString *)key value:(id)value range:(NSRange)range;
- (NSArray *)queryWithKey:(NSString *)key value:(id)value range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;

- (NSArray *)queryWithKey:(NSString *)key value:(id)value operation:(MDDOperation)operation;
- (NSArray *)queryWithKey:(NSString *)key value:(id)value operation:(MDDOperation)operation range:(NSRange)range;
- (NSArray *)queryWithKey:(NSString *)key value:(id)value operation:(MDDOperation)operation range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;

- (NSArray *)queryWithKey:(NSString *)key likeValue:(id)value format:(NSString *)format;
- (NSArray *)queryWithKey:(NSString *)key likeValue:(id)value format:(NSString *)format range:(NSRange)range;
- (NSArray *)queryWithKey:(NSString *)key likeValue:(id)value format:(NSString *)format range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;

- (NSArray *)queryAllRows;
- (NSArray *)queryWithConditionSet:(MDDConditionSet *)conditionSet;
- (NSArray *)queryWithConditionSet:(MDDConditionSet *)conditionSet range:(NSRange)range;
- (NSArray *)queryWithConditionSet:(MDDConditionSet *)conditionSet range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;
- (NSArray *)queryWithConditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range;

- (NSArray *)queryWithClass:(Class<MDDObject>)class conditionSet:(MDDConditionSet *)conditionSet;
- (NSArray *)queryWithClass:(Class<MDDObject>)class conditionSet:(MDDConditionSet *)conditionSet range:(NSRange)range;
- (NSArray *)queryWithClass:(Class<MDDObject>)class conditionSet:(MDDConditionSet *)conditionSet range:(NSRange)range orderByKey:(NSString *)orderKey ascending:(BOOL)ascending;
- (NSArray *)queryWithClass:(Class<MDDObject>)class conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range;

- (BOOL)queryWithBlock:(MDDQuery *(^)(NSRange *range, NSUInteger index, BOOL *stop))block result:(void (^)(id<MDDObject> object))result;
- (BOOL)queryWithClass:(Class<MDDObject>)class block:(MDDQuery *(^)(NSRange *range, NSUInteger index, BOOL *stop))block result:(void (^)(id<MDDObject> object))resultBlock;

- (NSUInteger)queryCountWithKey:(NSString *)key value:(id)value;
- (NSUInteger)queryCountWithConditionSet:(MDDConditionSet *)conditionSet;
- (NSUInteger)queryCountWithKey:(NSString *)key conditionSet:(MDDConditionSet *)conditionSet;
- (id)queryWithKey:(NSString *)key function:(MDDFunction)fuction conditionSet:(MDDConditionSet *)conditionSet;

- (BOOL)functionQueries:(MDDFunctionQuery *(^)(NSUInteger index, BOOL *stop))block result:(void (^)(NSUInteger index, id value))resultBlock;

@end
