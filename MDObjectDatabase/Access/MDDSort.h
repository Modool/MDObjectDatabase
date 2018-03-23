//
//  MDDSort.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDKeyValueDescriptor.h"

@interface MDDSort : MDDKeyValueDescriptor

@property (nonatomic, assign, readonly) BOOL ascending;

+ (instancetype)sortWithKey:(NSString *)key ascending:(BOOL)ascending;

@end

