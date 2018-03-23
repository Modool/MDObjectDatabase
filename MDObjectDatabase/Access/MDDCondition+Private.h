//
//  MDDCondition+Private.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDCondition.h"

@protocol MDDObject;
@class MDDTokenDescription, MDDTableInfo;
@interface MDDCondition (Private)

+ (MDDTokenDescription *)descriptionWithConditions:(NSArray<MDDCondition *> *)conditions operation:(MDDConditionOperation)operation tableInfo:(MDDTableInfo *)tableInfo;

@end
