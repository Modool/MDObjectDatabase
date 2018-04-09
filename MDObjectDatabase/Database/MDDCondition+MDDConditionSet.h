//
//  MDDCondition+MDDConditionSet.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDCondition.h"
#import "MDDRange.h"

@class MDDConditionSet;
@interface MDDCondition (MDDConditionSet)

- (MDDConditionSet *)and:(MDDCondition *)condition;
- (MDDConditionSet *)or:(MDDCondition *)condition;

+ (NSArray<MDDCondition *> *)conditionsWithTableInfo:(id<MDDTableInfo>)tableInfo property:(id<MDDItem>)property integerRange:(MDDIntegerRange)integerRange;
+ (NSArray<MDDCondition *> *)conditionsWithTableInfo:(id<MDDTableInfo>)tableInfo property:(id<MDDItem>)property integerRange:(MDDIntegerRange)integerRange positive:(BOOL)positive;

+ (NSArray<MDDCondition *> *)conditionsWithTableInfo:(id<MDDTableInfo>)tableInfo property:(id<MDDItem>)property floatRange:(MDDFloatRange)floatRange;
+ (NSArray<MDDCondition *> *)conditionsWithTableInfo:(id<MDDTableInfo>)tableInfo property:(id<MDDItem>)property floatRange:(MDDFloatRange)floatRange positive:(BOOL)positive;

@end
