//
//  MDDSort+Private.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDSort.h"

@protocol MDDObject;
@class MDDTokenDescription, MDDTableInfo;
@interface MDDSort (Private)

+ (MDDTokenDescription *)descriptionWithSorts:(NSArray<MDDSort *> *)sorts tableInfo:(MDDTableInfo *)tableInfo;

@end
