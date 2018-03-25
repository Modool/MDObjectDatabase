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

@property (nonatomic, copy, readonly) NSArray<MDDSetter *> *setters;

@property (nonatomic, strong, readonly) MDDConditionSet *conditionSet;

+ (instancetype)updaterWithSetter:(NSArray<MDDSetter *> *)setters;
+ (instancetype)updaterWithSetter:(NSArray<MDDSetter *> *)setters conditionSet:(MDDConditionSet *)conditionSet;

+ (instancetype)updaterWithObject:(NSObject<MDDObject> *)object tableInfo:(MDDTableInfo *)tableInfo;
+ (instancetype)updaterWithObject:(NSObject<MDDObject> *)object properties:(NSSet *)properties tableInfo:(MDDTableInfo *)tableInfo;
+ (instancetype)updaterWithObject:(NSObject<MDDObject> *)object properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties conditionSet:(MDDConditionSet *)conditionSet tableInfo:(MDDTableInfo *)tableInfo;

@end

