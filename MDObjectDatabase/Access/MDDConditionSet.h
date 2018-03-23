//
//  MDDConditionSet.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDDescriptor.h"
#import "MDDAccessorConstants.h"

@class MDDCondition;
@interface MDDConditionSet : MDDDescriptor

// Default is MDDOperationConditionAnd
@property (nonatomic, assign, readonly) MDDConditionOperation operation;

@property (nonatomic, strong, readonly) NSArray<MDDConditionSet *> *sets;

@property (nonatomic, copy, readonly) NSArray<MDDCondition *> *conditions;

@property (nonatomic, copy, readonly) NSArray<NSString *> *allKeys;

+ (instancetype)setWithCondition:(MDDCondition *)condition;
+ (instancetype)setWithConditions:(NSArray<MDDCondition *> *)conditions;
+ (instancetype)setWithConditions:(NSArray<MDDCondition *> *)conditions operation:(MDDConditionOperation)operation;
+ (instancetype)setWithConditions:(NSArray<MDDCondition *> *)conditions set:(MDDConditionSet *)set operation:(MDDConditionOperation)operation;
+ (instancetype)setWithConditions:(NSArray<MDDCondition *> *)conditions sets:(NSArray<MDDConditionSet *> *)sets operation:(MDDConditionOperation)operation;

- (MDDConditionSet *)and:(MDDCondition *)condition;
- (MDDConditionSet *)or:(MDDCondition *)condition;

- (MDDConditionSet *)andSet:(MDDConditionSet *)set;
- (MDDConditionSet *)orSet:(MDDConditionSet *)set;

@end

