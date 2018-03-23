//
//  MDDDeleter.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDDeleter.h"

@implementation MDDDeleter

+ (instancetype)deleter;{
    return [self deleterWithConditionSet:nil];
}

+ (instancetype)deleterWithConditionSet:(MDDConditionSet *)conditionSet;{
    MDDDeleter *descriptor = [self new];
    descriptor->_conditionSet = conditionSet;
    
    return descriptor;
}

@end

