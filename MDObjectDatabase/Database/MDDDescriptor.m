//
//  MDDDescriptor.m
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/29.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDDescriptor.h"

@implementation MDDDescriptor

+ (instancetype)descriptorWithTableInfo:(id<MDDTableInfo>)tableInfo;{
    return [[self alloc] initWithTableInfo:tableInfo];
}

- (instancetype)initWithTableInfo:(id<MDDTableInfo>)tableInfo;{
    if (self = [super init]) {
        _tableInfo = tableInfo;
    }
    return self;
}

- (instancetype)init{
    return [self initWithTableInfo:nil];
}

- (NSString *)descriptionWithTableInfo:(id<MDDTableInfo>)tableInfo value:(id *)value;{
    return nil;
}

- (MDDDescription *)SQLDescription{
    return nil;
}

@end

