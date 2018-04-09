//
//  MDDCondition+MDDConditionSet.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDCondition+MDDConditionSet.h"
#import "MDDConditionSet.h"

@implementation MDDCondition (MDDConditionSet)

- (MDDConditionSet *)and:(MDDCondition *)condition;{
    return [MDDConditionSet setWithConditions:@[condition, self] operation:MDDConditionOperationAnd];
}

- (MDDConditionSet *)or:(MDDCondition *)condition;{
    return [MDDConditionSet setWithConditions:@[condition, self] operation:MDDConditionOperationOr];
}

+ (NSArray<MDDCondition *> *)conditionsWithTableInfo:(id<MDDTableInfo>)tableInfo property:(id<MDDItem>)property integerRange:(MDDIntegerRange)integerRange;{
    return [self conditionsWithTableInfo:tableInfo property:property integerRange:integerRange positive:YES];
}

+ (NSArray<MDDCondition *> *)conditionsWithTableInfo:(id<MDDTableInfo>)tableInfo property:(id<MDDItem>)property integerRange:(MDDIntegerRange)integerRange positive:(BOOL)positive;{
    MDDCondition *condition1 = [self conditionWithTableInfo:tableInfo property:property value:@(integerRange.minimum) operation:positive ? MDDOperationGreaterThanOrEqual : MDDOperationLessThanOrEqual];
    MDDCondition *condition2 = [self conditionWithTableInfo:tableInfo property:property value:@(integerRange.maximum) operation:positive ? MDDOperationLessThanOrEqual : MDDOperationGreaterThanOrEqual];
    
    return @[condition1, condition2];
}

+ (NSArray<MDDCondition *> *)conditionsWithTableInfo:(id<MDDTableInfo>)tableInfo property:(id<MDDItem>)property floatRange:(MDDFloatRange)floatRange;{
    return [self conditionsWithTableInfo:tableInfo property:property floatRange:floatRange positive:YES];
}

+ (NSArray<MDDCondition *> *)conditionsWithTableInfo:(id<MDDTableInfo>)tableInfo property:(id<MDDItem>)property floatRange:(MDDFloatRange)floatRange positive:(BOOL)positive;{
    MDDCondition *condition1 = [self conditionWithTableInfo:tableInfo property:property value:@(floatRange.minimum) operation:positive ? MDDOperationGreaterThanOrEqual : MDDOperationLessThanOrEqual];
    MDDCondition *condition2 = [self conditionWithTableInfo:tableInfo property:property value:@(floatRange.maximum) operation:positive ? MDDOperationLessThanOrEqual : MDDOperationGreaterThanOrEqual];
    
    return @[condition1, condition2];
}

@end

