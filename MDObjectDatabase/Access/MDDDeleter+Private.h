//
//  MDDDeleter+Private.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDDeleter.h"

@class MDDTokenDescription, MDDTableInfo;
@interface MDDDeleter (Private)

- (NSString *)descriptionWithTableInfo:(MDDTableInfo *)tableInfo;
+ (MDDTokenDescription *)descriptionWithDeleter:(MDDDeleter *)deleter tableInfo:(MDDTableInfo *)tableInfo;

@end
