//
//  MDDCondition.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDKeyValueDescriptor.h"
#import "MDDConstants.h"
#import "MDDItem.h"

#define MDDConditionPrimary1(INFO, PRIMARY_VALUE)             [MDDCondition conditionWithTableInfo:INFO primaryValue:PRIMARY_VALUE]
#define MDDConditionPrimary2(INFO, PRIMARY_VALUE, OPERATION)  [MDDCondition conditionWithTableInfo:INFO primaryValue:PRIMARY_VALUE operation:OPERATION]

#define MDDConditionKey1(INFO, KEY, VALUE)                [MDDCondition conditionWithTableInfo:INFO key:KEY value:VALUE]
#define MDDConditionKey2(INFO, KEY, VALUE, OPERATION)     [MDDCondition conditionWithTableInfo:INFO key:KEY value:VALUE operation:OPERATION]

@interface MDDCondition : MDDKeyValueDescriptor

@property (nonatomic, assign, readonly) MDDOperation operation;

// eg: ((key + 2) / 3 + 6) / 20
@property (nonatomic, copy, readonly) NSArray<NSString *> *transforms;

+ (instancetype)conditionWithTableInfo:(MDDTableInfo *)tableInfo primaryValue:(id<NSObject, NSCopying>)value;
+ (instancetype)conditionWithTableInfo:(MDDTableInfo *)tableInfo primaryValue:(id<NSObject, NSCopying>)value operation:(MDDOperation)operation;

+ (instancetype)conditionWithTableInfo:(MDDTableInfo *)tableInfo key:(id<MDDItem>)key value:(id<NSObject, NSCopying>)value;
+ (instancetype)conditionWithTableInfo:(MDDTableInfo *)tableInfo key:(id<MDDItem>)key value:(id<NSObject, NSCopying>)value operation:(MDDOperation)operation;
+ (instancetype)conditionWithTableInfo:(MDDTableInfo *)tableInfo key:(id<MDDItem>)key value:(id<NSObject, NSCopying>)value operation:(MDDOperation)operation transform:(NSString *)transform;
+ (instancetype)conditionWithTableInfo:(MDDTableInfo *)tableInfo key:(id<MDDItem>)key value:(id<NSObject, NSCopying>)value operation:(MDDOperation)operation transforms:(NSArray<NSString *> *)transforms;

+ (MDDDescription *)descriptionWithConditions:(NSArray<MDDCondition *> *)conditions operation:(MDDConditionOperation)operation;

@end
