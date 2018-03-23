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

+ (NSArray<MDDCondition *> *)conditionsWithKey:(NSString *)key integerRange:(MDDIntegerRange)integerRange;
+ (NSArray<MDDCondition *> *)conditionsWithKey:(NSString *)key integerRange:(MDDIntegerRange)integerRange positive:(BOOL)positive;

+ (NSArray<MDDCondition *> *)conditionsWithKey:(NSString *)key floatRange:(MDDFloatRange)floatRange;
+ (NSArray<MDDCondition *> *)conditionsWithKey:(NSString *)key floatRange:(MDDFloatRange)floatRange positive:(BOOL)positive;

@end
