//
//  MDDInsertSetter+Private.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDInsertSetter.h"

@interface MDDInsertSetter (Private)

+ (MDDTokenDescription *)descriptionWithSetters:(NSArray<MDDInsertSetter *> *)setters tableInfo:(MDDTableInfo *)tableInfo;

@end
