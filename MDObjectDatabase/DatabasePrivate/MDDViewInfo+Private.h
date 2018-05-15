
//
//  MDDViewInfo+Private.h
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/4/2.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDViewInfo.h"
#import "MDDTableInfo+Private.h"

@class MDPropertyAttributes, MDDColumn;
@interface MDDViewInfo ()<MDDTableInfoPrivate>

@property (nonatomic, copy, readonly) NSDictionary<NSString *, MDDColumn *> *propertyColumns;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, MDPropertyAttributes *> *attributeMapper;

@end

