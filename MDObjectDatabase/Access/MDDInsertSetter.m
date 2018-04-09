//
//  MDDInsertSetter.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDInsertSetter.h"
#import "MDDColumn.h"
#import "MDDInsertSetter.h"
#import "MDDTableInfo.h"
#import "MDDItem.h"
#import "MDDDescription.h"
#import "MDDConstants.h"

@implementation MDDInsertSetter
@dynamic SQLDescription;

+ (instancetype)setterWithModel:(id)object propertyName:(NSString *)propertyName tableInfo:(MDDTableInfo *)tableInfo;{
    NSParameterAssert(object && [propertyName length] && tableInfo);
    
    return [self descriptorWithTableInfo:tableInfo property:propertyName value:[object valueForKey:propertyName]];
}

+ (NSArray<MDDInsertSetter *> *)settersWithObject:(id)object tableInfo:(MDDTableInfo *)tableInfo;{
    NSParameterAssert(object && tableInfo);
    
    NSMutableArray<MDDInsertSetter *> *setters = [NSMutableArray<MDDInsertSetter *> array];
    for (MDDColumn *column in [tableInfo columns]) {
        id value = [object valueForKey:[column propertyName]];
        
        if ([column isPrimary] && !value) continue;
        
        MDDInsertSetter *setter = [self descriptorWithTableInfo:tableInfo property:[column propertyName] value:value];
        if (!setter) continue;
        
        [setters addObject:setter];
    }
    
    return [setters copy];
}

+ (MDDDescription *)descriptionWithSetters:(NSArray<MDDInsertSetter *> *)setters;{
    NSParameterAssert([setters count]);
    NSMutableArray<NSString *> *columns = [NSMutableArray<NSString *> array];
    NSMutableArray<NSString *> *tokens = [NSMutableArray<NSString *> array];
    NSMutableArray *values = [NSMutableArray array];
    
    for (MDDInsertSetter *setter in setters) {
        id property = [setter property];
        id value = [setter value];
        if ([value isKindOfClass:[MDDValue class]]) {
            MDDValue *_value = value;
            MDDDescription *description = [_value SQLDescription];
            [columns addObject:[description SQL]];
            [values addObject:[description values]];
        } else {
            MDDColumn *column = [setter.tableInfo columnForProperty:property];
            NSParameterAssert(column);
            value = [column transformValue:value];
            value = value ?: [NSNull null];
            
            [values addObject:value];
            [columns addObject:[column name]];
            [tokens addObject:MDDatabaseToken];
        }
    }
    NSString *SQL = [NSString stringWithFormat:@" ( %@ ) VALUES ( %@ )", [columns componentsJoinedByString:@","], [tokens componentsJoinedByString:@","]];
    
    return [MDDDescription descriptionWithSQL:SQL values:values];
}

@end
