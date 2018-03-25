//
//  MDDInserter+Private.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDInserter.h"

@protocol MDDObject;
@class MDDTokenDescription, MDDTableInfo;
@interface MDDInserter (Private)

+ (MDDTokenDescription *)descriptionWithInserter:(MDDInserter *)inserter tableInfo:(MDDTableInfo *)tableInfo;

+ (MDDTokenDescription *)descriptionWithObject:(NSObject<MDDObject> *)object tableInfo:(MDDTableInfo *)tableInfo;

@end
