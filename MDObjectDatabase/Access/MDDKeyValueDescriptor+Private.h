//
//  MDDKeyValueDescriptor+Private.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDKeyValueDescriptor.h"

@protocol MDDObject;
@class MDDTokenDescription, MDDTableInfo;
@interface MDDKeyValueDescriptor (Private)

+ (MDDTokenDescription *)descriptionWithDescriptors:(NSArray<MDDKeyValueDescriptor *> *)descriptors separator:(NSString *)separator tableInfo:(MDDTableInfo *)tableInfo;

@end
