//
//  MDDSort+Private.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDSort+Private.h"
#import "MDDKeyValueDescriptor+Private.h"

@implementation MDDSort (Private)

+ (MDDTokenDescription *)descriptionWithSorts:(NSArray<MDDSort *> *)sorts tableInfo:(MDDTableInfo *)tableInfo{
    return [super descriptionWithDescriptors:sorts separator:@" , "  tableInfo:tableInfo];
}

@end
