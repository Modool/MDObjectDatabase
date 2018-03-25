//
//  MDDTableInfo+Private.h
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/25.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <MDObjectDatabase/MDObjectDatabase.h>

@interface MDDTableInfo ()

@property (nonatomic, copy, readonly) NSDictionary<NSString *, MDDColumn *> *columnMapping;

@property (nonatomic, copy, readonly) NSDictionary<NSString *, MDDIndex *> *indexeMapping;

@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *propertyMapping;

@end
