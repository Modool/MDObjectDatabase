//
//  MDDProcessor.h
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/24.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDDRange.h"
#import "MDDAccessorConstants.h"

@protocol MDDObject;
@class MDDatabase, MDDConditionSet, MDDSetter, MDDSort, MDDQuery, MDDFunctionQuery, MDDTokenDescription;

@protocol MDDProcessor <NSObject>

#pragma mark - Append
- (BOOL)insertWithObject:(NSObject<MDDObject> *)object;
- (BOOL)insertWithObjects:(NSArray<MDDObject> *)objects;

- (BOOL)insertWithObjectsWithBlock:(NSObject<MDDObject> *(^)(NSUInteger index, BOOL *stop))block result:(void (^)(BOOL state, UInt64 rowID, NSUInteger index, BOOL *stop))result;

#pragma mark - Update

- (BOOL)updateWithObject:(NSObject<MDDObject> *)object;
- (BOOL)updateWithObject:(NSObject<MDDObject> *)object properties:(NSSet<NSString *> *)properties;
- (BOOL)updateWithObject:(NSObject<MDDObject> *)object properties:(NSSet<NSString *> *)properties ignoredProperties:(NSSet<NSString *> *)ignoredProperties;
- (BOOL)updateWithObject:(NSObject<MDDObject> *)object properties:(NSSet<NSString *> *)properties ignoredProperties:(NSSet<NSString *> *)ignoredProperties conditionSet:(MDDConditionSet *)conditionSet;

- (BOOL)updateWithObjects:(NSArray<MDDObject> *)objects;
- (BOOL)updateWithObjects:(NSArray<MDDObject> *)objects properties:(NSSet<NSString *> *)properties;
- (BOOL)updateWithObjects:(NSArray<MDDObject> *)objects properties:(NSSet<NSString *> *)properties ignoredProperties:(NSSet<NSString *> *)ignoredProperties;
- (BOOL)updateWithObjects:(NSArray<MDDObject> *)objects properties:(NSSet<NSString *> *)properties ignoredProperties:(NSSet<NSString *> *)ignoredProperties conditionSet:(MDDConditionSet *)conditionSet;

- (BOOL)updateWithObjects:(NSArray<MDDObject> *)objects properties:(NSSet<NSString *> *)properties ignoredProperties:(NSSet<NSString *> *)ignoredProperties conditionKeys:(NSSet<NSString *> *)conditionKeys;

- (BOOL)updateWithObjectsWithBlock:(NSObject<MDDObject> *(^)(NSUInteger index, NSSet<NSString *> **propertiesPtr, NSSet<NSString *> **ignoredPropertiesPtr, MDDConditionSet **conditionSetPtr, BOOL *stop))block result:(void (^)(BOOL state, NSUInteger index, BOOL *stop))result;

- (BOOL)updateWithPrimaryValue:(id)primaryValue key:(NSString *)key value:(id)value;
- (BOOL)updateWithPrimaryValue:(id)primaryValue key:(NSString *)key value:(id)value operation:(MDDOperation)operation;
- (BOOL)updateWithKey:(NSString *)key value:(id)value operation:(MDDOperation)operation conditionKey:(NSString *)conditionKey conditionValue:(id)conditionValue;
- (BOOL)updateWithKey:(NSString *)key value:(id)value conditionSet:(MDDConditionSet *)conditionSet;
- (BOOL)updateWithKey:(NSString *)key value:(id)value operation:(MDDOperation)operation conditionSet:(MDDConditionSet *)conditionSet;
- (BOOL)updateWithKeyValues:(NSDictionary *)keyValues conditionSet:(MDDConditionSet *)conditionSet;

- (BOOL)updateWithSetter:(MDDSetter *)settter;
- (BOOL)updateWithSetter:(MDDSetter *)settter conditionSet:(MDDConditionSet *)conditionSet;
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

- (BOOL)queryWithBlock:(MDDQuery *(^)(NSRange *range, NSUInteger index, BOOL *stop))block result:(void (^)(NSObject<MDDObject> * object))result;
- (BOOL)queryWithClass:(Class<MDDObject>)class block:(MDDQuery *(^)(NSRange *range, NSUInteger index, BOOL *stop))block result:(void (^)(NSObject<MDDObject> * object))resultBlock;

- (NSUInteger)queryCountWithKey:(NSString *)key value:(id)value;
- (NSUInteger)queryCountWithConditionSet:(MDDConditionSet *)conditionSet;
- (NSUInteger)queryCountWithKey:(NSString *)key conditionSet:(MDDConditionSet *)conditionSet;
- (id)queryWithKey:(NSString *)key function:(MDDFunction)fuction conditionSet:(MDDConditionSet *)conditionSet;

- (BOOL)functionQueries:(MDDFunctionQuery *(^)(NSUInteger index, BOOL *stop))block result:(void (^)(NSUInteger index, id value))resultBlock;

@end

@protocol MDDCoreProcessor <NSObject>

- (BOOL)executeInsertDescription:(MDDTokenDescription *)description completion:(void (^)(NSUInteger rowID))completion;
- (BOOL)executeInsertDescriptions:(NSArray<MDDTokenDescription *> *)descriptions block:(void (^)(NSUInteger index, NSUInteger rowID))block;
- (BOOL)executeInsert:(MDDTokenDescription *(^)(NSUInteger index, BOOL *stop))block result:(void (^)(BOOL state, UInt64 rowID, NSUInteger index, BOOL *stop))resultBlock;

- (BOOL)executeUpdateDescription:(MDDTokenDescription *)description;
- (BOOL)executeUpdateDescriptions:(NSArray<MDDTokenDescription *> *)descriptions;
- (BOOL)executeUpdate:(MDDTokenDescription *(^)(NSUInteger index, BOOL *stop))block result:(void (^)(BOOL state, NSUInteger index, BOOL *stop))resultBlock;

- (void)executeQueryDescription:(MDDTokenDescription *)description block:(void (^)(NSDictionary *dictionary))block;
- (BOOL)executeQueryDescription:(MDDTokenDescription *(^)(NSUInteger index, BOOL *stop))block result:(void (^)(NSUInteger index, NSDictionary *dictionary, BOOL *stop))resultBlock;

- (void)executeQuery:(NSString *)query values:(NSArray *)values block:(void (^)(NSDictionary *dictionary))block;
- (BOOL)executeQuery:(NSString *(^)(NSUInteger index, NSArray **values, BOOL *stop))block result:(void (^)(NSUInteger index, NSDictionary *dictionary, BOOL *stop))resultBlock;

@end
