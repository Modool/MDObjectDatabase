//
//  MDDPropertyValueDescriptor.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDDescriptor.h"

@protocol MDDItem;
@interface MDDPropertyValueDescriptor : MDDDescriptor

@property (nonatomic, strong, readonly) id<MDDItem> property;

@property (nonatomic, strong, readonly) id<MDDItem> value;

+ (instancetype)descriptorWithTableInfo:(id<MDDTableInfo>)tableInfo property:(id<MDDItem>)property value:(id<MDDItem>)value;

+ (MDDDescription *)descriptionWithDescriptors:(NSArray<MDDPropertyValueDescriptor *> *)descriptors separator:(NSString *)separator;

@end
