//
//  MDDatabaseIndex+Private.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/5.
//  Copyright © 2018年 modool. All rights reserved.
//

#import "MDDatabaseIndex.h"

@class MDDatabaseTableInfo;
@interface MDDatabaseIndex ()

@property (nonatomic, copy, readonly) NSString *tableName;

@property (nonatomic, copy, readonly) NSSet<NSString *> *columnNames;

@property (nonatomic, copy, readonly) NSString *creatingSQL;

@property (nonatomic, strong) MDDatabaseTableInfo *tableInfo;

@end

@interface MDDatabaseLocalIndex ()

@property (nonatomic, copy, readonly) NSString *droppingSQL;

@end
