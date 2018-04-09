//
//  MDDDeleter.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDDeleter.h"
#import "MDDTableInfo.h"
#import "MDDConditionSet.h"
#import "MDDDescription.h"

@implementation MDDDeleter

+ (instancetype)deleterWithTableInfo:(MDDTableInfo *)tableInfo;{
    return [self deleterWithTableInfo:tableInfo conditionSet:nil];
}

+ (instancetype)deleterWithTableInfo:(MDDTableInfo *)tableInfo conditionSet:(MDDConditionSet *)conditionSet;{
    MDDDeleter *descriptor = [self descriptorWithTableInfo:tableInfo];
    descriptor->_conditionSet = conditionSet;
    
    return descriptor;
}

- (MDDDescription *)SQLDescription{
    NSMutableString *SQL = [NSMutableString stringWithFormat:@" DELETE FROM %@ ", [[self tableInfo] name]];
    
    NSMutableArray *values = [NSMutableArray array];
    MDDDescription *description = [[self conditionSet] SQLDescription];
    if ([description SQL]) {
        [values addObjectsFromArray:[description values]];
        [SQL appendFormat:@" WHERE %@ ", [description SQL]];
    }
    
    return [MDDDescription descriptionWithSQL:SQL values:values];
}

- (NSString *)description{
    return [[self conditionSet] description];
}

@end

