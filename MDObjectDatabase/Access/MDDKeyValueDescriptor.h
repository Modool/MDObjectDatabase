//
//  MDDKeyValueDescriptor.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDDescriptor.h"

@interface MDDKeyValueDescriptor : MDDDescriptor

@property (nonatomic, copy, readonly) NSString *key;

@property (nonatomic, copy, readonly) id<NSObject, NSCopying> value;

+ (instancetype)descriptorWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value;
- (instancetype)initWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value;

@end
