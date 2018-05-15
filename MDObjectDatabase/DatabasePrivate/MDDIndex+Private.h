//
//  MDDIndex+Private.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/5.
//  Copyright © 2018年 modool. All rights reserved.
//

#import "MDDIndex.h"

@class MDDTableInfo;
@interface MDDIndex ()

@property (nonatomic, copy, readonly) NSString *tableName;

@property (nonatomic, copy, readonly) NSSet<NSString *> *columnNames;

@property (nonatomic, copy, readonly) NSString *creatingSQL;

@property (nonatomic, strong) MDDTableInfo *tableInfo;

@end

@interface MDDLocalIndex ()

@property (nonatomic, copy, readonly) NSString *droppingSQL;

@end
