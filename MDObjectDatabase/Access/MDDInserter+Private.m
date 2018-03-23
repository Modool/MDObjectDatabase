//
//  MDDInserter+Private.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDInserter+Private.h"
#import "MDDDescriptor+Private.h"
#import "MDDInsertSetter+Private.h"
#import "MDDConditionSet+Private.h"

#import "MDDTokenDescription.h"

@implementation MDDInserter (Private)

+ (MDDTokenDescription *)descriptionWithInserter:(MDDInserter *)inserter tableInfo:(MDDTableInfo *)tableInfo;{
    NSParameterAssert(inserter && tableInfo);
    NSString *tokenString = [inserter descriptionWithTableInfo:tableInfo value:nil];
    
    NSArray *values = @[];
    MDDTokenDescription *setterDescription = [MDDInsertSetter descriptionWithSetters:[inserter setters] tableInfo:tableInfo];
    NSParameterAssert(setterDescription);
    
    values = [values arrayByAddingObjectsFromArray:[setterDescription values]];
    tokenString = [tokenString stringByAppendingString:[setterDescription tokenString]];
    
    if ([inserter conditionSet]) {
        MDDTokenDescription *conditionDescription = [MDDConditionSet descriptionWithConditionSet:[inserter conditionSet] tableInfo:tableInfo];
        if (conditionDescription && [conditionDescription tokenString]) {
            values = [values arrayByAddingObjectsFromArray:[conditionDescription values]];
            tokenString = [tokenString stringByAppendingFormat:@" WHERE %@ ", [conditionDescription tokenString]];
        }
    }
    
    return [MDDTokenDescription descriptionWithTokenString:tokenString values:values];
}

+ (MDDTokenDescription *)descriptionWithObject:(id<MDDObject>)object tableInfo:(MDDTableInfo *)tableInfo;{
    MDDInserter *inserter = [self inserterWithObject:object tableInfo:tableInfo];
    NSParameterAssert(inserter);
    
    return [self descriptionWithInserter:inserter tableInfo:tableInfo];
}

@end
