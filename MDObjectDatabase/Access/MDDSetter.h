//
//  MDDSetter.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDPropertyValueDescriptor.h"
#import "MDDConstants.h"

@protocol MDDObject;
@class MDDTableInfo;
@interface MDDSetter : MDDPropertyValueDescriptor

@property (nonatomic, copy, readonly) NSString *transform;

@property (nonatomic, assign, readonly) MDDOperation operation;

+ (instancetype)setterWithTableInfo:(id<MDDTableInfo>)tableInfo property:(NSString *)property value:(id<MDDItem>)value;
+ (instancetype)setterWithTableInfo:(id<MDDTableInfo>)tableInfo property:(NSString *)property value:(id<MDDItem>)value operation:(MDDOperation)operation;
+ (instancetype)setterWithTableInfo:(id<MDDTableInfo>)tableInfo property:(NSString *)property value:(id<MDDItem>)value transform:(NSString *)transform operation:(MDDOperation)operation;

+ (NSArray<MDDSetter *> *)settersWithObject:(id)object tableInfo:(id<MDDTableInfo>)tableInfo;
+ (NSArray<MDDSetter *> *)settersWithObject:(id)object properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties tableInfo:(id<MDDTableInfo>)tableInfo;

+ (MDDDescription *)descriptionWithSetters:(NSArray<MDDSetter *> *)setters;

@end
