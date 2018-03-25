//
//  MDDUpdater+Private.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDUpdater.h"

@class MDDTokenDescription, MDDCondition, MDDTableInfo;
@interface MDDUpdater (Private)

+ (MDDTokenDescription *)descriptionWithUpdater:(MDDUpdater *)updater tableInfo:(MDDTableInfo *)tableInfo;

+ (MDDTokenDescription *)descriptionWithObject:(NSObject<MDDObject> *)object tableInfo:(MDDTableInfo *)tableInfo;

+ (MDDTokenDescription *)descriptionWithObject:(NSObject<MDDObject> *)object properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties conditionSet:(MDDConditionSet *)conditionSet tableInfo:(MDDTableInfo *)tableInfo;

@end
