//
//  MDDQuery+Private.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDQuery.h"

@class MDDTokenDescription, MDDTableInfo;
@interface MDDQuery (Private)

+ (MDDTokenDescription *)descriptionWithQuery:(MDDQuery *)query range:(NSRange)range tableInfo:(MDDTableInfo *)tableInfo;

@end
