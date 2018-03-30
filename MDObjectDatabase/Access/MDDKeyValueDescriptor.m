//
//  MDDKeyValueDescriptor.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDKeyValueDescriptor.h"
#import "MDDDescription.h"

@implementation MDDKeyValueDescriptor

+ (instancetype)descriptorWithTableInfo:(MDDTableInfo *)tableInfo key:(id<MDDItem>)key value:(id<NSObject, NSCopying>)value;{
    NSParameterAssert(tableInfo);
    MDDKeyValueDescriptor *descriptor = [super descriptorWithTableInfo:tableInfo];
    descriptor->_key = key;
    descriptor->_value = [value isKindOfClass:[NSSet class]] ? [(NSSet *)value allObjects] : value;
    
    return descriptor;
}

+ (MDDDescription *)descriptionWithDescriptors:(NSArray<MDDKeyValueDescriptor *> *)descriptors separator:(NSString *)separator{
    if (![descriptors count]) return nil;
    
    NSMutableArray *SQLs = [NSMutableArray array];
    NSMutableArray *values = [NSMutableArray array];
    for (MDDKeyValueDescriptor *descriptor in descriptors) {
        MDDDescription *description = descriptor.SQLDescription;
        
        if (description) {
            [SQLs addObject:[description SQL]];
            [values addObjectsFromArray:[description values]];
        }
    }
    if (![SQLs count]) return nil;
    
    return [MDDDescription descriptionWithSQL:[SQLs componentsJoinedByString:separator] values:values];
}

- (NSString *)description{
    return [[self dictionaryWithValuesForKeys:@[@"key", @"value"]] description];
}

@end

