//
//  MDDSetter.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDKeyValueDescriptor.h"
#import "MDDConstants.h"

@protocol MDDObject;
@class MDDTableInfo;
@interface MDDSetter : MDDKeyValueDescriptor

@property (nonatomic, copy, readonly) NSString *transform;

@property (nonatomic, assign, readonly) MDDOperation operation;

+ (instancetype)setterWithTableInfo:(MDDTableInfo *)tableInfo key:(NSString *)key value:(id<NSObject, NSCopying>)value;
+ (instancetype)setterWithTableInfo:(MDDTableInfo *)tableInfo key:(NSString *)key value:(id<NSObject, NSCopying>)value operation:(MDDOperation)operation;
+ (instancetype)setterWithTableInfo:(MDDTableInfo *)tableInfo key:(NSString *)key value:(id<NSObject, NSCopying>)value transform:(NSString *)transform operation:(MDDOperation)operation;

+ (NSArray<MDDSetter *> *)settersWithObject:(id)object tableInfo:(MDDTableInfo *)tableInfo;
+ (NSArray<MDDSetter *> *)settersWithObject:(id)object properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties tableInfo:(MDDTableInfo *)tableInfo;

+ (MDDDescription *)descriptionWithSetters:(NSArray<MDDSetter *> *)setters;

@end
