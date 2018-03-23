//
//  MDDQuery.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDDescriptor.h"

@class MDDSort, MDDConditionSet;
@interface MDDQuery : MDDDescriptor

@property (nonatomic, copy, readonly) NSSet<NSString *> *keys;

@property (nonatomic, copy, readonly) NSSet<NSString *> *indexKeys;

@property (nonatomic, copy, readonly) NSArray<MDDSort *> *sorts;

@property (nonatomic, strong, readonly) MDDConditionSet *conditionSet;

+ (instancetype)query;
+ (instancetype)queryWithSorts:(NSArray<MDDSort *> *)sorts;
+ (instancetype)queryWithConditionSet:(MDDConditionSet *)conditionSet;

+ (instancetype)queryWithKeys:(NSSet<NSString *> *)keys;
+ (instancetype)queryWithKeys:(NSSet<NSString *> *)keys sorts:(NSArray<MDDSort *> *)sorts;

+ (instancetype)queryWithKeys:(NSSet<NSString *> *)keys conditionSet:(MDDConditionSet *)conditionSet;
+ (instancetype)queryWithKeys:(NSSet<NSString *> *)keys sorts:(NSArray<MDDSort *> *)sorts conditionSet:(MDDConditionSet *)conditionSet;

@end

