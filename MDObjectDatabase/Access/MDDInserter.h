//
//  MDDInserter.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDDescriptor.h"

@protocol MDDObject;
@class MDDInsertSetter, MDDTableInfo, MDDConditionSet;
@interface MDDInserter : MDDDescriptor

@property (nonatomic, copy, readonly) NSArray<MDDInsertSetter *> *setters;

@property (nonatomic, strong, readonly) MDDConditionSet *conditionSet;

+ (instancetype)inserterWithSetter:(NSArray<MDDInsertSetter *> *)setters;
+ (instancetype)inserterWithSetter:(NSArray<MDDInsertSetter *> *)setters conditionSet:(MDDConditionSet *)conditionSet;

+ (instancetype)inserterWithObject:(NSObject<MDDObject> *)object tableInfo:(MDDTableInfo *)tableInfo;

@end

