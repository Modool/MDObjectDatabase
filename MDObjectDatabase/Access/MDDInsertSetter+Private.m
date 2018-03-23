//
//  MDDInsertSetter+Private.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDInsertSetter+Private.h"

#import "MDDColumn.h"
#import "MDDInsertSetter.h"
#import "MDDTableInfo.h"
#import "MDDTokenDescription.h"
#import "MDDAccessorConstants.h"

@implementation MDDInsertSetter (Private)

+ (MDDTokenDescription *)descriptionWithSetters:(NSArray<MDDInsertSetter *> *)setters tableInfo:(MDDTableInfo *)tableInfo;{
    NSParameterAssert(tableInfo);
    
    NSMutableArray<NSString *> *columns = [NSMutableArray<NSString *> new];
    NSMutableArray<NSString *> *tokens = [NSMutableArray<NSString *> new];
    NSMutableArray *values = [NSMutableArray new];
    
    for (MDDInsertSetter *setter in setters) {
        id key = [setter key];
        id value = [setter value];
        
        MDDColumn *column = [tableInfo columnForKey:key];
        NSParameterAssert(column);
        value = [column transformValue:value];
        
        [columns addObject:[column name]];
        [values addObject:value ?: [NSNull null]];
        [tokens addObject:MDDatabaseToken];
    }
    
    NSString *tokenString = [NSString stringWithFormat:@" ( %@ ) VALUES ( %@ )", [columns componentsJoinedByString:@","], [tokens componentsJoinedByString:@","]];
    
    return [MDDTokenDescription descriptionWithTokenString:tokenString values:values];
}

@end
