//
//  MDDInsertSetter.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDPropertyValueDescriptor.h"

@protocol MDDObject;
@class MDDDescription, MDDTableInfo;
@interface MDDInsertSetter : MDDPropertyValueDescriptor

@property (nonatomic, strong, readonly) MDDDescription *SQLDescription NS_UNAVAILABLE;

+ (instancetype)setterWithModel:(id)object propertyName:(NSString *)propertyName tableInfo:(MDDTableInfo *)tableInfo;

+ (NSArray<MDDInsertSetter *> *)settersWithObject:(id)object tableInfo:(MDDTableInfo *)tableInfo;

+ (MDDDescription *)descriptionWithSetters:(NSArray<MDDInsertSetter *> *)setters;

@end

