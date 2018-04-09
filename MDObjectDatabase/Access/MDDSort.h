//
//  MDDSort.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDPropertyValueDescriptor.h"

@interface MDDSort : MDDPropertyValueDescriptor

@property (nonatomic, assign, readonly) BOOL ascending;

+ (instancetype)sortWithTableInfo:(id<MDDTableInfo>)tableInfo property:(id<MDDItem>)property ascending:(BOOL)ascending;

+ (MDDDescription *)descriptionWithSorts:(NSArray<MDDSort *> *)sorts;

@end

