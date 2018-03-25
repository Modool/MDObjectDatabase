//
//  MDDObject.m
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/25.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDDObject+Private.h"
#import "MDDTableInfo.h"

@implementation NSObject (MDDatabase)

- (id)primaryValurWithTableInfo:(MDDTableInfo *)tableInfo;{
    NSSet *primaryProperties = [tableInfo primaryProperties];
    NSString *primaryKey = [primaryProperties count] == 1 ? [primaryProperties anyObject] : nil;
    
    return primaryKey ? [self valueForKey:primaryKey] : nil;
}

- (void)setPrimaryValue:(id)value tableInfo:(MDDTableInfo *)tableInfo;{
    NSSet *primaryProperties = [tableInfo primaryProperties];
    NSString *primaryKey = [primaryProperties count] == 1 ? [primaryProperties anyObject] : nil;
    
    if (primaryKey && ![self valueForKey:primaryKey]) [self setValue:value forKey:primaryKey];
}

@end
