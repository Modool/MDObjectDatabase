//
//  MDDSetter.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDKeyValueDescriptor.h"
#import "MDDAccessorConstants.h"

@protocol MDDObject;
@class MDDTableInfo;
@interface MDDSetter : MDDKeyValueDescriptor

@property (nonatomic, copy, readonly) NSString *transform;

@property (nonatomic, assign, readonly) MDDOperation operation;

+ (instancetype)setterWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value;
+ (instancetype)setterWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value operation:(MDDOperation)operation;
+ (instancetype)setterWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value transform:(NSString *)transform operation:(MDDOperation)operation;

+ (NSArray<MDDSetter *> *)settersWithModel:(NSObject<MDDObject> *)model tableInfo:(MDDTableInfo *)tableInfo;
+ (NSArray<MDDSetter *> *)settersWithModel:(NSObject<MDDObject> *)model properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties tableInfo:(MDDTableInfo *)tableInfo;

@end
