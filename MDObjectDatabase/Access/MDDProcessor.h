//
//  MDDProcessor.h
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/24.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDDRange.h"
#import "MDDConstants.h"

@protocol MDDObject, MDDReferenceDatabase;
@class MDDatabase, MDDTableInfo, MDDConditionSet, MDDSetter, MDDSort, MDDQuery, MDDFunctionQuery, MDDDescriptor, MDDInserter, MDDUpdater, MDDQuery, MDDDeleter;

@protocol MDDProcessor <NSObject>

@property (nonatomic, strong, readonly) MDDTableInfo *tableInfo;

- (MDDTableInfo *)tableInfoForClass:(Class<MDDObject>)class;

#pragma mark - Append
- (BOOL)insertWithObject:(id)object;
- (BOOL)insertWithObjects:(NSArray *)objects;

- (BOOL)insertWithObjectsWithBlock:(id(^)(NSUInteger index, BOOL *stop))block block:(void (^)(BOOL state, UInt64 rowID, NSUInteger index, BOOL *stop))resultBlock;

#pragma mark - Update

- (BOOL)updateWithObject:(id)object;
- (BOOL)updateWithObject:(id)object properties:(NSSet<NSString *> *)properties;
- (BOOL)updateWithObject:(id)object properties:(NSSet<NSString *> *)properties ignoredProperties:(NSSet<NSString *> *)ignoredProperties;
- (BOOL)updateWithObject:(id)object properties:(NSSet<NSString *> *)properties ignoredProperties:(NSSet<NSString *> *)ignoredProperties conditionSet:(MDDConditionSet *)conditionSet;

- (BOOL)updateWithObjects:(NSArray *)objects;
- (BOOL)updateWithObjects:(NSArray *)objects properties:(NSSet<NSString *> *)properties;
- (BOOL)updateWithObjects:(NSArray *)objects properties:(NSSet<NSString *> *)properties ignoredProperties:(NSSet<NSString *> *)ignoredProperties;
- (BOOL)updateWithObjects:(NSArray *)objects properties:(NSSet<NSString *> *)properties ignoredProperties:(NSSet<NSString *> *)ignoredProperties conditionSet:(MDDConditionSet *)conditionSet;

- (BOOL)updateWithObjects:(NSArray *)objects properties:(NSSet<NSString *> *)properties ignoredProperties:(NSSet<NSString *> *)ignoredProperties conditionKeys:(NSSet<NSString *> *)conditionKeys;

- (BOOL)updateWithObjectsWithBlock:(id(^)(NSUInteger index, NSSet<NSString *> **propertiesPtr, NSSet<NSString *> **ignoredPropertiesPtr, MDDConditionSet **conditionSetPtr, BOOL *stop))block result:(void (^)(BOOL state, NSUInteger index, BOOL *stop))result;

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

- (NSUInteger)queryCountWithKey:(NSString *)key value:(id)value;
- (NSUInteger)queryCountWithConditionSet:(MDDConditionSet *)conditionSet;
- (NSUInteger)queryCountWithKey:(NSString *)key conditionSet:(MDDConditionSet *)conditionSet;
- (id)queryWithKey:(NSString *)key function:(MDDFunction)function conditionSet:(MDDConditionSet *)conditionSet;

@end

@protocol MDDCoreProcessor <NSObject>

- (BOOL)executeInserter:(MDDInserter *)inserter block:(void (^)(NSUInteger rowID))block;
- (BOOL)executeInserters:(MDDInserter *(^)(NSUInteger index, BOOL *stop))block block:(void (^)(BOOL state, UInt64 rowID, NSUInteger index, BOOL *stop))resultBlock;

- (BOOL)executeDeleter:(MDDDeleter *)deleter;
- (BOOL)executeDeleters:(MDDDeleter *(^)(NSUInteger index, BOOL *stop))block block:(void (^)(BOOL state, NSUInteger index, BOOL *stop))resultBlock;

- (BOOL)executeUpdater:(MDDUpdater *)updater;
- (BOOL)executeUpdaters:(MDDUpdater *(^)(NSUInteger index, BOOL *stop))block block:(void (^)(BOOL state, NSUInteger index, BOOL *stop))resultBlock;

- (void)executeQuery:(MDDQuery *)query block:(void (^)(id result))block;
- (BOOL)executeQueries:(MDDQuery *(^)(NSUInteger index, BOOL *stop))block block:(void (^)(NSUInteger index, id result, BOOL *stop))resultBlock;

- (void)executeQuerySQL:(NSString *)SQL values:(NSArray *)values block:(void (^)(NSDictionary *dictionary))block;
- (BOOL)executeQuerySQLs:(NSString *(^)(NSUInteger index, NSArray **values, BOOL *stop))block result:(void (^)(NSUInteger index, NSDictionary *dictionary, BOOL *stop))resultBlock;

- (BOOL)executeUpdateSQL:(NSString *)query values:(NSArray *)values block:(void (^)(id<MDDReferenceDatabase> database))block;
- (BOOL)executeUpdateSQLs:(NSString *(^)(NSUInteger index, NSArray **values, BOOL *stop))block block:(void (^)(BOOL state, id<MDDReferenceDatabase>  database, NSUInteger index, BOOL *stop))resultBlock;

@end
