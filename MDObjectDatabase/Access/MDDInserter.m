//
//  MDDInserter.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDInserter.h"
#import "MDDDescriptor+Private.h"
#import "MDDTableInfo.h"
#import "MDDInsertSetter.h"

@implementation MDDInserter

+ (instancetype)inserterWithSetter:(NSArray<MDDInsertSetter *> *)setters;{
    return [self inserterWithSetter:setters conditionSet:nil];
}

+ (instancetype)inserterWithSetter:(NSArray<MDDInsertSetter *> *)setters conditionSet:(MDDConditionSet *)conditionSet;{
    MDDInserter *descriptor = [self new];
    descriptor->_setters = [setters copy];
    descriptor->_conditionSet = conditionSet;
    
    return descriptor;
}

- (NSString *)descriptionWithTableInfo:(MDDTableInfo *)tableInfo value:(id *)value{
    NSParameterAssert(tableInfo);
    
    return [NSString stringWithFormat:@" INSERT INTO %@ ", [tableInfo tableName]];
}

+ (MDDInserter *)inserterWithObject:(NSObject<MDDObject> *)object tableInfo:(MDDTableInfo *)tableInfo;{
    NSParameterAssert(object && tableInfo);
    
    NSArray<MDDInsertSetter *> *setters = [MDDInsertSetter settersWithModel:object tableInfo:tableInfo];
    NSParameterAssert(setters && [setters count]);
    
    return [MDDInserter inserterWithSetter:setters];
}

@end
