//
//  MDDatabase+Private.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/12/1.
//  Copyright © 2017年 modool. All rights reserved.
//

#import <FMDB/FMDB.h>
#import "MDDatabase.h"

@interface MDDatabase ()

@property (nonatomic, strong, readonly) NSRecursiveLock *lock;

@property (nonatomic, strong, readonly) FMDatabaseQueue *databaseQueue;

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, MDDatabaseTableInfo *> *tableInfos;

@property (nonatomic, assign) BOOL inTransaction;

@end

