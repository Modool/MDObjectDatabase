//
//  MDDCondition+Private.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDCondition+Private.h"
#import "MDDKeyValueDescriptor+Private.h"
#import "MDDAccessorConstants.h"

@implementation MDDCondition (Private)

+ (MDDTokenDescription *)descriptionWithConditions:(NSArray<MDDCondition *> *)conditions operation:(MDDConditionOperation)operation tableInfo:(MDDTableInfo *)tableInfo;{
    NSString *operationDescription = MDConditionOperationDescription(operation);
    return [super descriptionWithDescriptors:conditions separator:[NSString stringWithFormat:@" %@ ", operationDescription] tableInfo:tableInfo];
}

@end
