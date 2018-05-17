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

@protocol MDDObject, MDDTableInfo, MDDReferenceDatabase;
@class MDDatabase, MDDConditionSet, MDDSetter, MDDSort, MDDQuery, MDDFunctionQuery, MDDDescriptor, MDDInserter, MDDUpdater, MDDQuery, MDDDeleter;

@protocol MDDProcessor <NSObject>

@property (nonatomic, strong, readonly) id<MDDTableInfo> tableInfo;

- (id<MDDTableInfo>)tableInfoForClass:(Class<MDDObject>)class;

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

- (BOOL)updateWithObjects:(NSArray *)objects properties:(NSSet<NSString *> *)properties ignoredProperties:(NSSet<NSString *> *)ignoredProperties conditionPropertys:(NSSet<NSString *> *)conditionPropertys;

- (BOOL)updateWithObjectsWithBlock:(id(^)(NSUInteger index, NSSet<NSString *> **propertiesPtr, NSSet<NSString *> **ignoredPropertiesPtr, MDDConditionSet **conditionSetPtr, BOOL *stop))block result:(void (^)(BOOL state, NSUInteger index, BOOL *stop))result;

- (BOOL)updateWithPrimaryValue:(id)primaryValue property:(NSString *)property value:(id)value;
- (BOOL)updateWithPrimaryValue:(id)primaryValue property:(NSString *)property value:(id)value operation:(MDDOperation)operation;
- (BOOL)updateWithProperty:(NSString *)property value:(id)value operation:(MDDOperation)operation conditionProperty:(NSString *)conditionProperty conditionValue:(id)conditionValue;
- (BOOL)updateWithProperty:(NSString *)property value:(id)value conditionSet:(MDDConditionSet *)conditionSet;
- (BOOL)updateWithProperty:(NSString *)property value:(id)value operation:(MDDOperation)operation conditionSet:(MDDConditionSet *)conditionSet;
- (BOOL)updateWithPropertyValues:(NSDictionary *)keyValues conditionSet:(MDDConditionSet *)conditionSet;

- (BOOL)updateWithSetter:(MDDSetter *)settter;
- (BOOL)updateWithSetter:(MDDSetter *)settter conditionSet:(MDDConditionSet *)conditionSet;
- (BOOL)updateWithSetters:(NSArray<MDDSetter *> *)settters conditionSet:(MDDConditionSet *)conditionSet;

#pragma mark - Delete

- (BOOL)deleteWithPrimaryValue:(id)value;
- (BOOL)deleteWithPrimaryValues:(NSSet *)primaryValues;
- (BOOL)deleteWithProperty:(NSString *)property value:(id)value;
- (BOOL)deleteWithProperty:(NSString *)property value:(id)value operation:(MDDOperation)operation;
- (BOOL)deleteWithProperty:(NSString *)property likeValue:(id)value;
- (BOOL)deleteWithProperty:(NSString *)property likeValue:(id)value format:(NSString *)format;
- (BOOL)deleteWithProperty:(NSString *)property inValues:(NSSet *)values;
- (BOOL)deleteWithConditionSet:(MDDConditionSet *)conditionSet;

#pragma mark - Fetch

- (id)queryWithPrimaryValue:(id)value;

- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues;
- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues range:(NSRange)range;
- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues range:(NSRange)range orderByProperty:(NSString *)orderProperty ascending:(BOOL)ascending;

- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues operation:(MDDOperation)operation range:(NSRange)range;
- (NSArray *)queryWithPrimaryValues:(NSSet *)primaryValues operation:(MDDOperation)operation range:(NSRange)range orderByProperty:(NSString *)orderProperty ascending:(BOOL)ascending;

- (NSArray *)queryWithProperty:(NSString *)property inValues:(NSSet *)values;
- (NSArray *)queryWithProperty:(NSString *)property inValues:(NSSet *)values range:(NSRange)range;
- (NSArray *)queryWithProperty:(NSString *)property inValues:(NSSet *)values range:(NSRange)range orderByProperty:(NSString *)orderProperty ascending:(BOOL)ascending;
- (NSArray *)queryWithProperty:(NSString *)property inValues:(NSSet *)values operation:(MDDOperation)operation range:(NSRange)range orderByProperty:(NSString *)orderProperty ascending:(BOOL)ascending;

// Default is MDDOperationEqual
- (NSArray *)queryWithProperty:(NSString *)property value:(id)value;
- (NSArray *)queryWithProperty:(NSString *)property value:(id)value range:(NSRange)range;
- (NSArray *)queryWithProperty:(NSString *)property value:(id)value range:(NSRange)range orderByProperty:(NSString *)orderProperty ascending:(BOOL)ascending;

- (NSArray *)queryWithProperty:(NSString *)property value:(id)value operation:(MDDOperation)operation;
- (NSArray *)queryWithProperty:(NSString *)property value:(id)value operation:(MDDOperation)operation range:(NSRange)range;
- (NSArray *)queryWithProperty:(NSString *)property value:(id)value operation:(MDDOperation)operation range:(NSRange)range orderByProperty:(NSString *)orderProperty ascending:(BOOL)ascending;

- (NSArray *)queryWithProperty:(NSString *)property likeValue:(id)value format:(NSString *)format;
- (NSArray *)queryWithProperty:(NSString *)property likeValue:(id)value format:(NSString *)format range:(NSRange)range;
- (NSArray *)queryWithProperty:(NSString *)property likeValue:(id)value format:(NSString *)format range:(NSRange)range orderByProperty:(NSString *)orderProperty ascending:(BOOL)ascending;

- (NSArray *)queryAllRows;
- (NSArray *)queryWithConditionSet:(MDDConditionSet *)conditionSet;
- (NSArray *)queryWithConditionSet:(MDDConditionSet *)conditionSet range:(NSRange)range;
- (NSArray *)queryWithConditionSet:(MDDConditionSet *)conditionSet range:(NSRange)range orderByProperty:(NSString *)orderProperty ascending:(BOOL)ascending;
- (NSArray *)queryWithConditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range;

- (NSUInteger)queryCountWithProperty:(NSString *)property value:(id)value;
- (NSUInteger)queryCountWithProperty:(NSString *)property conditionSet:(MDDConditionSet *)conditionSet;
- (id)queryWithProperty:(NSString *)property function:(MDDFunction)function conditionSet:(MDDConditionSet *)conditionSet;

@end

@protocol MDDCoreProcessor <NSObject>

- (BOOL)executeInserter:(MDDInserter *)inserter block:(void (^)(UInt64 rowID))block;
- (BOOL)executeInserters:(MDDInserter *(^)(NSUInteger index, BOOL *stop))block block:(void (^)(BOOL state, UInt64 rowID, NSUInteger index, BOOL *stop))resultBlock;

- (BOOL)executeDeleter:(MDDDeleter *)deleter;
- (BOOL)executeDeleters:(MDDDeleter *(^)(NSUInteger index, BOOL *stop))block block:(void (^)(BOOL state, NSUInteger index, BOOL *stop))resultBlock;

- (BOOL)executeUpdater:(MDDUpdater *)updater;
- (BOOL)executeUpdaters:(MDDUpdater *(^)(NSUInteger index, BOOL *stop))block block:(void (^)(BOOL state, NSUInteger index, BOOL *stop))resultBlock;

- (void)executeQuery:(MDDQuery *)query block:(void (^)(id result))block;
- (BOOL)executeQueries:(MDDQuery *(^)(NSUInteger index, BOOL *stop))block block:(void (^)(NSUInteger index, id result, BOOL *stop))resultBlock;

- (void)executeQuerySQL:(NSString *)SQL values:(NSArray *)values block:(void (^)(NSDictionary *dictionary))block;
- (BOOL)executeQuerySQLs:(NSString *(^)(NSUInteger index, NSArray **values, BOOL *stop))block result:(void (^)(NSUInteger index, NSDictionary *dictionary, BOOL *stop))resultBlock;

- (BOOL)executeUpdateSQL:(NSString *)query values:(NSArray *)values block:(void (^)(UInt64 lastRowID))block;
- (BOOL)executeUpdateSQLs:(NSString *(^)(NSUInteger index, NSArray **values, BOOL *stop))block block:(void (^)(BOOL state, UInt64 lastRowID, NSUInteger index, BOOL *stop))resultBlock;

@end
