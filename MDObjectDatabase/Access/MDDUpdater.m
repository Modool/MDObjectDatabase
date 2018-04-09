
//
//  MDDUpdater.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDUpdater.h"
#import "MDDTableInfo.h"
#import "MDDConditionSet.h"
#import "MDDDescription.h"
#import "MDDSetter.h"

@implementation MDDUpdater

+ (instancetype)updaterWithSetter:(NSArray<MDDSetter *> *)setters;{
    return [self updaterWithSetter:setters conditionSet:nil];
}

+ (instancetype)updaterWithSetter:(NSArray<MDDSetter *> *)setters conditionSet:(MDDConditionSet *)conditionSet;{
    MDDUpdater *descriptor = [self descriptorWithTableInfo:[[setters firstObject] tableInfo]];
    descriptor->_setters = [setters copy];
    descriptor->_conditionSet = conditionSet;
    
    return descriptor;
}

+ (instancetype)updaterWithObject:(id)object tableInfo:(MDDTableInfo *)tableInfo;{
    return [self updaterWithObject:object properties:nil ignoredProperties:nil conditionSet:nil tableInfo:tableInfo];
}

+ (instancetype)updaterWithObject:(id)object properties:(NSSet *)properties tableInfo:(MDDTableInfo *)tableInfo;{
    return [self updaterWithObject:object properties:properties ignoredProperties:nil conditionSet:nil tableInfo:tableInfo];
}

+ (instancetype)updaterWithObject:(id)object properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties conditionSet:(MDDConditionSet *)conditionSet tableInfo:(id<MDDTableInfo>)tableInfo;{
    
    NSArray<MDDSetter *> *setters = [MDDSetter settersWithObject:object properties:properties ignoredProperties:ignoredProperties tableInfo:tableInfo];
    NSParameterAssert(setters && [setters count]);
    
    return [self updaterWithSetter:setters conditionSet:conditionSet];
}

- (MDDDescription *)SQLDescription{
    NSMutableString *SQL = [NSMutableString stringWithFormat:@" UPDATE %@ ", [[self tableInfo] name]];
    
    NSMutableArray *values = [NSMutableArray array];
    MDDDescription *description = [MDDSetter descriptionWithSetters:[self setters]];
    NSParameterAssert(description);
    
    if ([description SQL]) {
        [SQL appendFormat:@" SET %@ ", [description SQL]];
        [values addObjectsFromArray:[description values]];
    }
    
    description = [[self conditionSet] SQLDescription];
    if ([description SQL]) {
        [SQL appendFormat:@" WHERE %@ ", [description SQL]];
        [values addObjectsFromArray:[description values]];
    }
    
    return [MDDDescription descriptionWithSQL:SQL values:values];
}

- (NSString *)description{
    return [[self dictionaryWithValuesForKeys:@[@"setters", @"conditionSet"]] description];
}

@end
