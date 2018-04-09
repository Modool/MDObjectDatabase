//
//  MDDCondition.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDPropertyValueDescriptor.h"
#import "MDDConstants.h"
#import "MDDItem.h"

#define MDDConditionPrimary1(INFO, PRIMARY_VALUE)             [MDDCondition conditionWithTableInfo:INFO primaryValue:PRIMARY_VALUE]
#define MDDConditionPrimary2(INFO, PRIMARY_VALUE, OPERATION)  [MDDCondition conditionWithTableInfo:INFO primaryValue:PRIMARY_VALUE operation:OPERATION]

#define MDDConditionProperty1(INFO, KEY, VALUE)                [MDDCondition conditionWithTableInfo:INFO property:KEY value:VALUE]
#define MDDConditionProperty2(INFO, KEY, VALUE, OPERATION)     [MDDCondition conditionWithTableInfo:INFO property:KEY value:VALUE operation:OPERATION]

@interface MDDCondition : MDDPropertyValueDescriptor

@property (nonatomic, assign, readonly) MDDOperation operation;

// eg: ((property + 2) / 3 + 6) / 20
@property (nonatomic, copy, readonly) NSArray<NSString *> *transforms;

+ (instancetype)conditionWithTableInfo:(id<MDDTableInfo>)tableInfo primaryValue:(id<MDDItem>)value;
+ (instancetype)conditionWithTableInfo:(id<MDDTableInfo>)tableInfo primaryValue:(id<MDDItem>)value operation:(MDDOperation)operation;

+ (instancetype)conditionWithTableInfo:(id<MDDTableInfo>)tableInfo property:(id<MDDItem>)property value:(id<MDDItem>)value;
+ (instancetype)conditionWithTableInfo:(id<MDDTableInfo>)tableInfo property:(id<MDDItem>)property value:(id<MDDItem>)value operation:(MDDOperation)operation;
+ (instancetype)conditionWithTableInfo:(id<MDDTableInfo>)tableInfo property:(id<MDDItem>)property value:(id<MDDItem>)value operation:(MDDOperation)operation transform:(NSString *)transform;
+ (instancetype)conditionWithTableInfo:(id<MDDTableInfo>)tableInfo property:(id<MDDItem>)property value:(id<MDDItem>)value operation:(MDDOperation)operation transforms:(NSArray<NSString *> *)transforms;

+ (MDDDescription *)descriptionWithConditions:(NSArray<MDDCondition *> *)conditions operation:(MDDConditionOperation)operation;

- (MDDDescription *)SQLDescriptionInSet:(MDDSet *)set;

@end
