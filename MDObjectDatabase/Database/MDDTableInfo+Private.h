//
//  MDDTableInfo+Private.h
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/25.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDTableInfo.h"

@interface MDDTableInfo ()

@property (nonatomic, copy, readonly) NSDictionary<NSString *, MDDColumn *> *columnMapper;

@property (nonatomic, copy, readonly) NSDictionary<NSString *, MDDIndex *> *indexMapper;

@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *propertyColumnMapper;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *columnPropertyMapper;

@end
