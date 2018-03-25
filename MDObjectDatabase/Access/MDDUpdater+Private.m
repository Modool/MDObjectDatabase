//
//  MDDUpdater+Private.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDUpdater+Private.h"
#import "MDDDescriptor+Private.h"
#import "MDDSetter+Private.h"
#import "MDDConditionSet+Private.h"

#import "MDDTokenDescription.h"

@implementation MDDUpdater (Private)

+ (MDDTokenDescription *)descriptionWithUpdater:(MDDUpdater *)updater tableInfo:(MDDTableInfo *)tableInfo;{
    NSParameterAssert(updater && tableInfo);
    
    NSMutableString *tokenString = [[updater descriptionWithTableInfo:tableInfo value:nil] ?: @"" mutableCopy];
    NSMutableArray *values = [NSMutableArray array];
    MDDTokenDescription *setterDescription = [MDDSetter descriptionWithSetters:[updater setters] tableInfo:tableInfo];
    NSParameterAssert(setterDescription);
    
    if ([[setterDescription values] count]) {
        [values addObjectsFromArray:[setterDescription values]];
    }
    if ([[setterDescription tokenString] length]) {
        [tokenString appendFormat:@" SET %@ ", [setterDescription tokenString]];
    }
    
    MDDTokenDescription *conditionDescription = [MDDConditionSet descriptionWithConditionSet:[updater conditionSet] tableInfo:tableInfo];
    if ([[conditionDescription values] count]) {
        [values addObjectsFromArray:[conditionDescription values]];
    }
    if ([[conditionDescription tokenString] length]) {
        [tokenString appendFormat:@" WHERE %@ ", [conditionDescription tokenString]];
    }
    
    return [MDDTokenDescription descriptionWithTokenString:tokenString values:values];
}

+ (MDDTokenDescription *)descriptionWithObject:(NSObject<MDDObject> *)object tableInfo:(MDDTableInfo *)tableInfo;{
    return [self descriptionWithObject:object properties:nil ignoredProperties:nil conditionSet:nil tableInfo:tableInfo];
}

+ (MDDTokenDescription *)descriptionWithObject:(NSObject<MDDObject> *)object properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties conditionSet:(MDDConditionSet *)conditionSet tableInfo:(MDDTableInfo *)tableInfo;{
    NSParameterAssert(tableInfo);
    
    MDDUpdater *updater = [self updaterWithObject:object properties:properties ignoredProperties:ignoredProperties conditionSet:conditionSet tableInfo:tableInfo];
    NSParameterAssert(updater);
    
    return [self descriptionWithUpdater:updater tableInfo:tableInfo];
}

@end
