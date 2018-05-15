//
//  MDDatabase+Private.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/12/1.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDatabase.h"

@protocol MDDReferenceDatabaseQueue, MDDTableInfo, MDDTableConfiguration;
@class MDDTableConfiguration, MDDViewConfiguration, MDDCompat, MDDLogger;
@interface MDDatabase ()

@property (nonatomic, strong, readonly) NSRecursiveLock *lock;

@property (nonatomic, strong, readonly) id<MDDReferenceDatabaseQueue> databaseQueue;

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, Class> *classes;

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, id<MDDTableInfo>> *infos;

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, id<MDDTableConfiguration>> *configurations;

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, MDDCompat *> *compats;

@end

