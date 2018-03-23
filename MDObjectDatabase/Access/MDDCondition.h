//
//  MDDCondition.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDKeyValueDescriptor.h"
#import "MDDAccessorConstants.h"

@interface MDDCondition : MDDKeyValueDescriptor

@property (nonatomic, assign, readonly) MDDOperation operation;

+ (instancetype)conditionWithPrimaryValue:(id<NSObject, NSCopying>)value;
+ (instancetype)conditionWithPrimaryValue:(id<NSObject, NSCopying>)value operation:(MDDOperation)operation;

+ (instancetype)conditionWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value;
+ (instancetype)conditionWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value operation:(MDDOperation)operation;

@end
