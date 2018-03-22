//
//  MDDatabaseAccessor+MDDatabase.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/29.
//  Copyright © 2017年 modool. All rights reserved.
//

#import <FMDB/FMDB.h>
#import "MDDatabaseAccessor.h"
#import "MDDatabaseDescriptor.h"

@interface MDDatabaseAccessor (MDDatabase)

- (BOOL)executeInsertDescription:(MDDatabaseTokenDescription *)description completion:(void (^)(NSUInteger rowID))completion;
- (BOOL)executeInsertDescriptions:(NSArray<MDDatabaseTokenDescription *> *)descriptions block:(void (^)(NSUInteger index, NSUInteger rowID))block;
- (BOOL)executeInsert:(MDDatabaseTokenDescription *(^)(NSUInteger index, BOOL *stop))block result:(void (^)(BOOL state, UInt64 rowID, NSUInteger index, BOOL *stop))resultBlock;

- (BOOL)executeUpdateDescription:(MDDatabaseTokenDescription *)description;
- (BOOL)executeUpdateDescriptions:(NSArray<MDDatabaseTokenDescription *> *)descriptions;
- (BOOL)executeUpdate:(MDDatabaseTokenDescription *(^)(NSUInteger index, BOOL *stop))block result:(void (^)(BOOL state, NSUInteger index, BOOL *stop))resultBlock;

- (void)executeQueryDescription:(MDDatabaseTokenDescription *)description block:(void (^)(NSDictionary *dictionary))block;
- (BOOL)executeQueryDescription:(MDDatabaseTokenDescription *(^)(NSUInteger index, BOOL *stop))block result:(void (^)(NSUInteger index, NSDictionary *dictionary, BOOL *stop))resultBlock;

- (void)executeQuery:(NSString *)query values:(NSArray *)values block:(void (^)(NSDictionary *dictionary))block;
- (BOOL)executeQuery:(NSString *(^)(NSUInteger index, NSArray **values, BOOL *stop))block result:(void (^)(NSUInteger index, NSDictionary *dictionary, BOOL *stop))resultBlock;

@end
