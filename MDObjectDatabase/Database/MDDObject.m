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

- (id)primaryValurWithTableInfo:(id<MDDTableInfo>)tableInfo;{
    NSSet *primaryProperties = [tableInfo primaryProperties];
    NSString *primaryProperty = [primaryProperties count] == 1 ? [primaryProperties anyObject] : nil;
    
    return primaryProperty ? [self valueForKey:primaryProperty] : nil;
}

- (void)setPrimaryValue:(id)value tableInfo:(id<MDDTableInfo>)tableInfo;{
    NSSet *primaryProperties = [tableInfo primaryProperties];
    NSString *primaryProperty = [primaryProperties count] == 1 ? [primaryProperties anyObject] : nil;
    
    if (primaryProperty && ![self valueForKey:primaryProperty]) [self setValue:value forKey:primaryProperty];
}

@end

@implementation NSArray (MDDatabaseSetValue)

- (NSArray *)MDDItemMap:(id (^)(id object))block{
    NSParameterAssert(block);
    NSMutableArray *array = [NSMutableArray array];
    for (id object in self) {
        id result = block(object) ?: [NSNull null];
        
        [array addObject:result];
    }
    return array;
}
@end
