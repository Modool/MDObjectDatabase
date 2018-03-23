//
//  MDDFunctionQuery+Private.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDFunctionQuery+Private.h"
#import "MDDTokenDescription.h"
#import "MDDTableInfo.h"
#import "MDDColumn.h"

#import "MDDConditionSet+Private.h"

@implementation MDDFunctionQuery (Private)

+ (MDDTokenDescription *)descriptionWithQuery:(MDDFunctionQuery *)query alias:(NSString *)alias tableInfo:(MDDTableInfo *)tableInfo;{
    MDDColumn *column = [tableInfo columnForKey:query.key];
    NSParameterAssert(column);
    
    MDDTokenDescription *conditionDescription = [MDDConditionSet descriptionWithConditionSet:query.conditionSet tableInfo:tableInfo];
    NSString *where = (conditionDescription && [conditionDescription tokenString]) ? [NSString stringWithFormat:@" WHERE %@", [conditionDescription tokenString]] : @"";
    
    NSString *SQL = [NSString stringWithFormat:@"SELECT %@(%@) AS %@ FROM %@ %@", query.function, [column name], alias, [tableInfo tableName], where];
    
    return [MDDTokenDescription descriptionWithTokenString:SQL values:[conditionDescription values]];
}


@end
