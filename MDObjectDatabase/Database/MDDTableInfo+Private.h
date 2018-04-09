//
//  MDDTableInfo+Private.h
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/25.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDTableInfo.h"

@protocol MDDTableInfoPrivate <MDDTableInfo>

@property (nonatomic, copy, readonly) NSDictionary<NSString *, MDDColumn *> *columnMapper;

@end

@interface MDDTableInfo ()<MDDTableInfoPrivate>

@property (nonatomic, copy, readonly) NSDictionary<NSString *, MDDIndex *> *indexMapper;

@end
