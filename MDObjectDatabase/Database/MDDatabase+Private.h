//
//  MDDatabase+Private.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/12/1.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDatabase.h"

@class FMDatabaseQueue, MDDConfiguration, MDDCompat, MDDLogger;
@interface MDDatabase ()

@property (nonatomic, strong, readonly) NSRecursiveLock *lock;

@property (nonatomic, strong, readonly) FMDatabaseQueue *databaseQueue;

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, MDDTableInfo *> *tableInfos;

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, MDDConfiguration *> *configurations;

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, Class> *tableClasses;

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, MDDCompat *> *compats;

@property (nonatomic, assign) BOOL inTransaction;

@end

