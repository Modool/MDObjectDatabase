//
//  MDDConditionSet.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDDescriptor.h"
#import "MDDConstants.h"

#define MDDConditionSet1(CONDITION)                     [MDDConditionSet setWithCondition:CONDITION]
#define MDDConditionSet2(CONDITIONS)                    [MDDConditionSet setWithConditions:CONDITIONS]
#define MDDConditionSet3(CONDITIONS, OPERATION)         [MDDConditionSet setWithConditions:CONDITIONS operation:OPERATION]

#define MDDConditionSet4(CONDITIONS, SET, OPERATION)    [MDDConditionSet setWithConditions:CONDITIONS set:SET operation:OPERATION]
#define MDDConditionSet5(CONDITIONS, SETS, OPERATION)   [MDDConditionSet setWithConditions:CONDITIONS sets:SETS operation:OPERATION]

@protocol MDDItem;
@class MDDCondition, MDDIndex, MDDSet;
@interface MDDConditionSet : MDDDescriptor

@property (nonatomic, strong, readonly) MDDIndex *index;

// Default is MDDOperationConditionAnd
@property (nonatomic, assign, readonly) MDDConditionOperation operation;

@property (nonatomic, copy, readonly) NSArray<MDDConditionSet *> *sets;

@property (nonatomic, copy, readonly) NSArray<MDDCondition *> *conditions;

- (NSArray<MDDItem> *)allPropertysIgnoreMultipleTable:(BOOL)ignore;

+ (instancetype)setWithCondition:(MDDCondition *)condition;
+ (instancetype)setWithConditions:(NSArray<MDDCondition *> *)conditions;
+ (instancetype)setWithConditions:(NSArray<MDDCondition *> *)conditions operation:(MDDConditionOperation)operation;
+ (instancetype)setWithConditions:(NSArray<MDDCondition *> *)conditions set:(MDDConditionSet *)set operation:(MDDConditionOperation)operation;
+ (instancetype)setWithConditions:(NSArray<MDDCondition *> *)conditions sets:(NSArray<MDDConditionSet *> *)sets operation:(MDDConditionOperation)operation;

- (MDDDescription *)SQLDescriptionInSet:(MDDSet *)set;

- (MDDConditionSet *)and:(MDDCondition *)condition;
- (MDDConditionSet *)or:(MDDCondition *)condition;

- (MDDConditionSet *)andSet:(MDDConditionSet *)set;
- (MDDConditionSet *)orSet:(MDDConditionSet *)set;

@end

