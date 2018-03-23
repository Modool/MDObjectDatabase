//
//  MDDSetter+Private.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDSetter.h"

@class MDDTokenDescription;
@interface MDDSetter (Private)

+ (MDDTokenDescription *)descriptionWithSetters:(NSArray<MDDSetter *> *)setters tableInfo:(MDDTableInfo *)tableInfo;

@end
