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

+ (instancetype)inserterWithTableInfo:(MDDTableInfo *)tableInfo setters:(NSArray<MDDInsertSetter *> *)setters;{
    return [self inserterWithTableInfo:tableInfo setters:setters conditionSet:nil];
}

+ (instancetype)inserterWithTableInfo:(MDDTableInfo *)tableInfo setters:(NSArray<MDDInsertSetter *> *)setters conditionSet:(MDDConditionSet *)conditionSet;{
    MDDInserter *descriptor = [self descriptorWithTableInfo:tableInfo];
    descriptor->_setters = [setters copy];
    descriptor->_conditionSet = conditionSet;
    
    return descriptor;
}

+ (MDDInserter *)inserterWithObject:(id)object tableInfo:(MDDTableInfo *)tableInfo;{
    NSParameterAssert(object && tableInfo);
    
    NSArray<MDDInsertSetter *> *setters = [MDDInsertSetter settersWithObject:object tableInfo:tableInfo];
    NSParameterAssert(setters && [setters count]);
    
    return [MDDInserter inserterWithTableInfo:tableInfo setters:setters];
}

- (MDDDescription *)SQLDescription;{
    NSMutableArray *values = [NSMutableArray array];
    NSMutableString *SQL = [NSMutableString stringWithFormat:@" INSERT INTO %@ ", [[self tableInfo] tableName]];
    
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
