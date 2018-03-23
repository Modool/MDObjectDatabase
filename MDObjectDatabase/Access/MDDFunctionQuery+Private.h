//
//  MDDFunctionQuery+Private.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDFunctionQuery.h"

@protocol MDDObject;
@class MDDTokenDescription, MDDTableInfo;
@interface MDDFunctionQuery (Private)

+ (MDDTokenDescription *)descriptionWithQuery:(MDDFunctionQuery *)query alias:(NSString *)alias tableInfo:(MDDTableInfo *)tableInfo;

@end
