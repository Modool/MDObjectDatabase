
//
//  MDDSetter+Private.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDSetter+Private.h"
#import "MDDKeyValueDescriptor+Private.h"

@implementation MDDSetter (Private)

+ (MDDTokenDescription *)descriptionWithSetters:(NSArray<MDDSetter *> *)setters tableInfo:(MDDTableInfo *)tableInfo{
    return [self descriptionWithDescriptors:setters separator:@" , " tableInfo:tableInfo];
}

@end
