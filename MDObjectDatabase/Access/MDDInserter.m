//
//  MDDInserter.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDInserter.h"
#import "MDDInsertSetter.h"

#import "MDDTableInfo.h"
#import "MDDDescription.h"
#import "MDDConditionSet.h"

@implementation MDDInserter

+ (instancetype)inserterWithTableInfo:(MDDTableInfo *)tableInfo setters:(NSArray<MDDInsertSetter *> *)setters conditionSet:(MDDConditionSet *)conditionSet;{
    MDDInserter *descriptor = [self descriptorWithTableInfo:tableInfo];
    descriptor.setters = setters;
    descriptor.conditionSet = conditionSet;
    
    return descriptor;
}

+ (MDDInserter *)inserterWithObject:(id)object tableInfo:(id<MDDTableInfo>)tableInfo;{
    NSParameterAssert(object && tableInfo);
    
    NSArray<MDDInsertSetter *> *setters = [MDDInsertSetter settersWithObject:object tableInfo:tableInfo];
    NSParameterAssert(setters && [setters count]);
    
    return [MDDInserter inserterWithTableInfo:tableInfo setters:setters conditionSet:nil];
}

- (MDDDescription *)SQLDescription;{
    NSMutableArray *values = [NSMutableArray array];
    NSMutableString *SQL = [NSMutableString stringWithFormat:@" INSERT INTO %@ ", [[self tableInfo] name]];
    
    MDDDescription *description = [MDDInsertSetter descriptionWithSetters:[self setters]];
    NSParameterAssert(description);
    if ([description SQL]) {
        [SQL appendString:[description SQL]];
        [values addObjectsFromArray:[description values]];
    }
    
    if ([self conditionSet]) {
        description = [[self conditionSet] SQLDescription];
        
        if ([description SQL]) {
            [SQL appendString:[description SQL]];
            [values addObjectsFromArray:[description values]];
        }
    }
    
    return [MDDDescription descriptionWithSQL:SQL values:values];
}

- (NSString *)description{
    return [[self dictionaryWithValuesForKeys:@[@"setters", @"conditionSet"]] description];
}

@end
