//
//  MDDQuery.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDDescriptor.h"

@protocol MDDItem, MDDObject;
@class MDDSort, MDDConditionSet, MDDSet, MDDItem;
@interface MDDQuery : MDDDescriptor

@property (nonatomic, strong, readonly) id<MDDTableInfo> tableInfo NS_UNAVAILABLE;
@property (nonatomic, strong, readonly) MDDSet *set;
@property (nonatomic, strong, readonly) MDDConditionSet *conditionSet;
@property (nonatomic, assign, readonly) NSRange range;

@property (nonatomic, copy, readonly) NSSet<MDDItem *> *property;
@property (nonatomic, copy, readonly) NSArray<MDDSort *> *sorts;

+ (instancetype)queryWithSorts:(NSArray<MDDSort *> *)sorts;
+ (instancetype)queryWithSorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range;

+ (instancetype)queryWithConditionSet:(MDDConditionSet *)conditionSet;
+ (instancetype)queryWithConditionSet:(MDDConditionSet *)conditionSet range:(NSRange)range;

+ (instancetype)queryWithProperty:(MDDItem *)property;
+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property;
+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property range:(NSRange)range;

+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property sorts:(NSArray<MDDSort *> *)sorts;
+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range;

+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property conditionSet:(MDDConditionSet *)conditionSet;
+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts;
+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range;
+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range objectClass:(Class<MDDObject>)objectClass;
+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range transform:(id (^)(NSDictionary *result))transform;

+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property set:(MDDSet *)set;
+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet;
+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts;
+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range;
+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range objectClass:(Class<MDDObject>)objectClass;
+ (instancetype)queryWithPropertys:(NSSet<MDDItem *> *)property set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range transform:(id (^)(NSDictionary *result))transform;

@end

