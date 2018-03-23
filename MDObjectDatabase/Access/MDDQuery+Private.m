//
//  MDDQuery+Private.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDQuery+Private.h"
#import "MDDDescriptor+Private.h"
#import "MDDConditionSet+Private.h"
#import "MDDSort+Private.h"

#import "MDDTableInfo.h"
#import "MDDTokenDescription.h"

@implementation MDDQuery (Private)

+ (MDDTokenDescription *)descriptionWithQuery:(MDDQuery *)query range:(NSRange)range tableInfo:(MDDTableInfo *)tableInfo;{
    NSParameterAssert(query && tableInfo);
    
    NSString *tokenString = [query descriptionWithTableInfo:tableInfo value:nil];
    
    MDDTokenDescription *conditionDescription = [MDDConditionSet descriptionWithConditionSet:[query conditionSet] tableInfo:tableInfo];
    NSArray *values = [conditionDescription values];
    
    if (conditionDescription && [conditionDescription tokenString]) {
        tokenString = [tokenString stringByAppendingFormat:@" WHERE %@ ", [conditionDescription tokenString]];
    }
    
    MDDTokenDescription *sortDescription = [MDDSort descriptionWithSorts:[query sorts] tableInfo:tableInfo];
    if (sortDescription) {
        tokenString = [tokenString stringByAppendingFormat:@" ORDER BY %@ ", [sortDescription tokenString] ?: @""];
    }
    
    if (range.location || range.length) {
        range.length = range.length ?: INT_MAX;
        tokenString = [tokenString stringByAppendingFormat:@" LIMIT %lu OFFSET %ld ", (unsigned long)range.length, (unsigned long)range.location];
    }
    
    return [MDDTokenDescription descriptionWithTokenString:tokenString values:values];
}

@end
