//
//  MDDPropertyValueDescriptor.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDPropertyValueDescriptor.h"
#import "MDDDescription.h"

@implementation MDDPropertyValueDescriptor

+ (instancetype)descriptorWithTableInfo:(id<MDDTableInfo>)tableInfo property:(id<MDDItem>)property value:(id<MDDItem>)value;{
    NSParameterAssert(tableInfo);
    MDDPropertyValueDescriptor *descriptor = [super descriptorWithTableInfo:tableInfo];
    descriptor->_property = property;
    descriptor->_value = [(id)value isKindOfClass:[NSSet class]] ? (id)[(NSSet *)value allObjects] : value;
    
    return descriptor;
}

+ (MDDDescription *)descriptionWithDescriptors:(NSArray<MDDPropertyValueDescriptor *> *)descriptors separator:(NSString *)separator{
    if (![descriptors count]) return nil;
    
    NSMutableArray *SQLs = [NSMutableArray array];
    NSMutableArray *values = [NSMutableArray array];
    for (MDDPropertyValueDescriptor *descriptor in descriptors) {
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
    return [[self dictionaryWithValuesForKeys:@[@"property", @"value"]] description];
}

@end

