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

@implementation MDDInsertSetter

+ (instancetype)setterWithModel:(NSObject<MDDObject> *)model forPropertyWithName:(NSString *)propertyName tableInfo:(MDDTableInfo *)tableInfo;{
    NSParameterAssert(model && [propertyName length] && tableInfo);
    
    return [self descriptorWithKey:propertyName value:[model valueForKey:propertyName]];
}

+ (NSArray<MDDInsertSetter *> *)settersWithModel:(NSObject<MDDObject> *)model tableInfo:(MDDTableInfo *)tableInfo;{
    NSParameterAssert(model && tableInfo);
    
    NSMutableArray<MDDInsertSetter *> *setters = [NSMutableArray<MDDInsertSetter *> new];
    for (MDDColumn *column in [tableInfo columns]) {
        id value = [model valueForKey:[column propertyName]];
        
        if ([column isPrimary] && !value) continue;
        
        MDDInsertSetter *setter = [self descriptorWithKey:[column propertyName] value:value];
        if (!setter) continue;
        
        [setters addObject:setter];
    }
    
    return [setters copy];
}

@end
