//
//  MDDObject+Private.h
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/25.
//  Copyright © 2018年 markejave. All rights reserved.
//

@class MDDTableInfo;
@interface NSObject (MDDatabase)

- (id)primaryValurWithTableInfo:(MDDTableInfo *)tableInfo;
- (void)setPrimaryValue:(id)value tableInfo:(MDDTableInfo *)tableInfo;

@end

@interface NSArray (MDDatabaseSetValue)

- (NSArray *)MDDItemMap:(id (^)(id object))block;

@end
