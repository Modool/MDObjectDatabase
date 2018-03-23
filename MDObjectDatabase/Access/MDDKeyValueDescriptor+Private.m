
//
//  MDDKeyValueDescriptor+Private.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDKeyValueDescriptor+Private.h"
#import "MDDDescriptor+Private.h"

#import "MDDTokenDescription.h"
#import "MDDTableInfo.h"

@implementation MDDKeyValueDescriptor (Private)

+ (MDDTokenDescription *)descriptionWithDescriptors:(NSArray<MDDKeyValueDescriptor *> *)descriptors separator:(NSString *)separator tableInfo:(MDDTableInfo *)tableInfo{
    if (!descriptors && ![descriptors count]) return nil;
    
    NSMutableArray *descriptions = [NSMutableArray new];
    NSMutableArray *values = [NSMutableArray new];
    for (MDDKeyValueDescriptor *descriptor in descriptors) {
        id value = [descriptor value];
        NSString *description = [descriptor descriptionWithTableInfo:tableInfo value:&value];
        
        if ([description length]) {
            [descriptions addObject:description];
            if ([value isKindOfClass:[NSArray class]]) {
                [values addObjectsFromArray:(NSArray *)value];
            } else {
                [values addObject:value ?: [NSNull null]];
            }
        }
    }
    if (![descriptions count]) return nil;
    
    return [MDDTokenDescription descriptionWithTokenString:[descriptions componentsJoinedByString:separator] values:values];
}

@end
