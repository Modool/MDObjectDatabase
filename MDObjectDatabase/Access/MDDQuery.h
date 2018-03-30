//
//  MDDQuery.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDDescriptor.h"

@protocol MDDItem, MDDObject;
@class MDDSort, MDDConditionSet, MDDSet, MDDKey;
@interface MDDQuery : MDDDescriptor

@property (nonatomic, strong, readonly) MDDTableInfo *tableInfo NS_UNAVAILABLE;
@property (nonatomic, strong, readonly) MDDSet *set;
@property (nonatomic, strong, readonly) MDDConditionSet *conditionSet;
@property (nonatomic, assign, readonly) NSRange range;

@property (nonatomic, copy, readonly) NSSet<MDDKey *> *keys;
@property (nonatomic, copy, readonly) NSArray<MDDSort *> *sorts;

+ (instancetype)queryWithSorts:(NSArray<MDDSort *> *)sorts;
+ (instancetype)queryWithSorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range;

+ (instancetype)queryWithConditionSet:(MDDConditionSet *)conditionSet;
+ (instancetype)queryWithConditionSet:(MDDConditionSet *)conditionSet range:(NSRange)range;

+ (instancetype)queryWithKey:(MDDKey *)key;
+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys;
+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys range:(NSRange)range;

+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys sorts:(NSArray<MDDSort *> *)sorts;
+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range;

+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys conditionSet:(MDDConditionSet *)conditionSet;
+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts;
+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range;
+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range objectClass:(Class<MDDObject>)objectClass;
+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range transform:(id (^)(NSDictionary *result))transform;

+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys set:(MDDSet *)set;
+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet;
+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts;
+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range;
+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range objectClass:(Class<MDDObject>)objectClass;
+ (instancetype)queryWithKeys:(NSSet<MDDKey *> *)keys set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet sorts:(NSArray<MDDSort *> *)sorts range:(NSRange)range transform:(id (^)(NSDictionary *result))transform;

@end

