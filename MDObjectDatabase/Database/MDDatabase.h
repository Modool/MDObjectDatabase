//
//  MDDatabase.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/12/1.
//  Copyright © 2017年 modool. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MDDObject, MDDReferenceDatabaseQueue;
@class MDDTableInfo, MDDConfiguration, MDDCompat;
@interface MDDatabase : NSObject

+ (instancetype)databaseWithDatabaseQueue:(id<MDDReferenceDatabaseQueue>)queue;
- (instancetype)initWithDatabaseQueue:(id<MDDReferenceDatabaseQueue>)queue;

- (MDDTableInfo *)requireTableInfoWithClass:(Class<MDDObject>)class error:(NSError **)error;
- (BOOL)existTableForClass:(Class<MDDObject>)class;

- (BOOL)prepare;
- (void)close;

- (MDDCompat *)addConfiguration:(MDDConfiguration *)configuration error:(NSError **)error;

@end
