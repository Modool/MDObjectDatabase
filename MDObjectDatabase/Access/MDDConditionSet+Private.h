//
//  MDDConditionSet+Private.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDConditionSet.h"

@protocol MDDObject;
@class MDDTokenDescription, MDDTableInfo, MDDCondition;
@interface MDDConditionSet (Private)

- (MDDTokenDescription *)descriptionWithTableInfo:(MDDTableInfo *)tableInfo;

+ (MDDTokenDescription *)descriptionWithConditionSet:(MDDConditionSet *)conditionSet tableInfo:(MDDTableInfo *)tableInfo;

@end
