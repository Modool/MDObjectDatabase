//
//  MDDDeleter.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDDescriptor.h"

@class MDDConditionSet;
@interface MDDDeleter : MDDDescriptor

@property (nonatomic, strong, readonly) MDDConditionSet *conditionSet;

+ (instancetype)deleter;
+ (instancetype)deleterWithConditionSet:(MDDConditionSet *)conditionSet;

@end

