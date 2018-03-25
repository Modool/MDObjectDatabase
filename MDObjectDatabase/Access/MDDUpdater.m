
//
//  MDDUpdater.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDUpdater.h"
#import "MDDSetter.h"
#import "MDDTableInfo.h"

@implementation MDDUpdater

+ (instancetype)updaterWithSetter:(NSArray<MDDSetter *> *)setters;{
    return [self updaterWithSetter:setters conditionSet:nil];
}

+ (instancetype)updaterWithSetter:(NSArray<MDDSetter *> *)setters conditionSet:(MDDConditionSet *)conditionSet;{
    MDDUpdater *descriptor = [self new];
    descriptor->_setters = [setters copy];
    descriptor->_conditionSet = conditionSet;
    
    return descriptor;
}

+ (instancetype)updaterWithObject:(NSObject<MDDObject> *)object tableInfo:(MDDTableInfo *)tableInfo;{
    return [self updaterWithObject:object properties:nil ignoredProperties:nil conditionSet:nil tableInfo:tableInfo];
}

+ (instancetype)updaterWithObject:(NSObject<MDDObject> *)object properties:(NSSet *)properties tableInfo:(MDDTableInfo *)tableInfo;{
    return [self updaterWithObject:object properties:properties ignoredProperties:nil conditionSet:nil tableInfo:tableInfo];
}

+ (instancetype)updaterWithObject:(NSObject<MDDObject> *)object properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties conditionSet:(MDDConditionSet *)conditionSet tableInfo:(MDDTableInfo *)tableInfo;{
    
    NSArray<MDDSetter *> *setters = [MDDSetter settersWithModel:object properties:properties ignoredProperties:ignoredProperties tableInfo:tableInfo];
    NSParameterAssert(setters && [setters count]);
    
    return [MDDUpdater updaterWithSetter:setters conditionSet:conditionSet];
}

- (NSString *)descriptionWithTableInfo:(MDDTableInfo *)tableInfo value:(id *)value;{
    NSParameterAssert(tableInfo);
    
    return [NSString stringWithFormat:@" UPDATE %@ ", [tableInfo tableName]];
}

@end
