//
//  MDDKeyValueDescriptor.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDDescriptor.h"

@protocol MDDItem;
@interface MDDKeyValueDescriptor : MDDDescriptor

@property (nonatomic, strong, readonly) id<MDDItem> key;

@property (nonatomic, strong, readonly) id<NSObject> value;

+ (instancetype)descriptorWithTableInfo:(MDDTableInfo *)tableInfo key:(id<MDDItem>)key value:(id<NSObject, NSCopying>)value;

+ (MDDDescription *)descriptionWithDescriptors:(NSArray<MDDKeyValueDescriptor *> *)descriptors separator:(NSString *)separator;

@end
