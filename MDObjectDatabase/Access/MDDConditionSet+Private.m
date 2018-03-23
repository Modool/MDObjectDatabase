//
//  MDDConditionSet+Private.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDConditionSet+Private.h"
#import "MDDTokenDescription.h"
#import "MDDCondition+Private.h"

@implementation MDDConditionSet (Private)

- (MDDTokenDescription *)descriptionWithTableInfo:(MDDTableInfo *)tableInfo;{
    NSString *operation = MDConditionOperationDescription([self operation]);
    
    NSMutableString *description = [NSMutableString string];
    NSMutableArray *values = [NSMutableArray array];
    
    NSArray<MDDConditionSet *> *sets = [self sets];
    NSArray<MDDCondition *> *conditions = [self conditions];
    
    // ((a OR b OR c) AND (c OR d OR e) AND (f OR g OR h) ) OR (i AND j AND k)
    [sets enumerateObjectsUsingBlock:^(MDDConditionSet *set, NSUInteger index, BOOL *stop) {
        MDDTokenDescription *token = [set descriptionWithTableInfo:tableInfo];
        [description appendFormat:@" ( %@ ) %@", [token tokenString], index < ([sets count] - 1) ? operation : @""];
        [values addObjectsFromArray:[token values]];
    }];
    
    MDDTokenDescription *token = [MDDCondition descriptionWithConditions:conditions operation:[self operation] tableInfo:tableInfo];
    [description appendFormat:@" %@ %@", [description length] ? operation : @"", [token tokenString]];
    [values addObjectsFromArray:[token values]];
    
    return [MDDTokenDescription descriptionWithTokenString:description values:values];
}

+ (MDDTokenDescription *)descriptionWithConditionSet:(MDDConditionSet *)conditionSet tableInfo:(MDDTableInfo *)tableInfo;{
    return [conditionSet descriptionWithTableInfo:tableInfo];
}

@end
