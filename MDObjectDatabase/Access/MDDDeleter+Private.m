//
//  MDDDeleter+Private.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDDeleter+Private.h"
#import "MDDConditionSet+Private.h"

#import "MDDTableInfo.h"
#import "MDDTokenDescription.h"

@implementation MDDDeleter (Private)

- (NSString *)descriptionWithTableInfo:(MDDTableInfo *)tableInfo{
    NSParameterAssert(tableInfo);
    
    return [NSString stringWithFormat:@" DELETE FROM %@ ", [tableInfo tableName]];
}

+ (MDDTokenDescription *)descriptionWithDeleter:(MDDDeleter *)deleter tableInfo:(MDDTableInfo *)tableInfo;{
    NSString *tokenString = [deleter descriptionWithTableInfo:tableInfo];
    
    NSArray *values = @[];
    MDDTokenDescription *conditionDescription = [MDDConditionSet descriptionWithConditionSet:[deleter conditionSet] tableInfo:tableInfo];
    if (conditionDescription && [conditionDescription tokenString]) {
        values = [values arrayByAddingObjectsFromArray:[conditionDescription values]];
        tokenString = [tokenString stringByAppendingFormat:@" WHERE %@ ", [conditionDescription tokenString]];
    }
    
    return [MDDTokenDescription descriptionWithTokenString:tokenString values:values];
}

@end
