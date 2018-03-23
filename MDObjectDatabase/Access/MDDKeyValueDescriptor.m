//
//  MDDKeyValueDescriptor.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDKeyValueDescriptor.h"

@implementation MDDKeyValueDescriptor

+ (instancetype)descriptorWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value;{
    return [[self alloc] initWithKey:key value:value];
}

- (instancetype)initWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value;{
    if (self = [super init]) {
        _key = key;
        _value = [value isKindOfClass:[NSSet class]] ? [(NSSet *)value allObjects] : value;
    }
    return self;
}

@end

