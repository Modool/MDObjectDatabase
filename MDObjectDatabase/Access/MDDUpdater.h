//
//  MDDUpdater.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDDescriptor.h"

@protocol MDDObject;
@class MDDSetter, MDDConditionSet, MDDTableInfo;
@interface MDDUpdater : MDDDescriptor

@property (nonatomic, copy) NSArray<MDDSetter *> *setters;

@property (nonatomic, strong) MDDConditionSet *conditionSet;

+ (instancetype)updaterWithSetter:(NSArray<MDDSetter *> *)setters conditionSet:(MDDConditionSet *)conditionSet;

+ (instancetype)updaterWithObject:(id)object tableInfo:(MDDTableInfo *)tableInfo;
+ (instancetype)updaterWithObject:(id)object properties:(NSSet *)properties tableInfo:(MDDTableInfo *)tableInfo;
+ (instancetype)updaterWithObject:(id)object properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties conditionSet:(MDDConditionSet *)conditionSet tableInfo:(id<MDDTableInfo>)tableInfo;

@end

