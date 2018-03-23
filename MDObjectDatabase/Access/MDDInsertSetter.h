//
//  MDDInsertSetter.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDKeyValueDescriptor.h"

@protocol MDDObject;
@class MDDTokenDescription, MDDTableInfo;
@interface MDDInsertSetter : MDDKeyValueDescriptor

+ (instancetype)setterWithModel:(NSObject<MDDObject> *)model forPropertyWithName:(NSString *)propertyName tableInfo:(MDDTableInfo *)tableInfo;

+ (NSArray<MDDInsertSetter *> *)settersWithModel:(NSObject<MDDObject> *)model tableInfo:(MDDTableInfo *)tableInfo;

@end

