//
//  MDDAccessor+MDDatabase.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/29.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDAccessor.h"

@class MDDTokenDescription;
@interface MDDAccessor (MDDatabase)

- (BOOL)executeInsertDescription:(MDDTokenDescription *)description completion:(void (^)(NSUInteger rowID))completion;
- (BOOL)executeInsertDescriptions:(NSArray<MDDTokenDescription *> *)descriptions block:(void (^)(NSUInteger index, NSUInteger rowID))block;
- (BOOL)executeInsert:(MDDTokenDescription *(^)(NSUInteger index, BOOL *stop))block result:(void (^)(BOOL state, UInt64 rowID, NSUInteger index, BOOL *stop))resultBlock;

- (BOOL)executeUpdateDescription:(MDDTokenDescription *)description;
- (BOOL)executeUpdateDescriptions:(NSArray<MDDTokenDescription *> *)descriptions;
- (BOOL)executeUpdate:(MDDTokenDescription *(^)(NSUInteger index, BOOL *stop))block result:(void (^)(BOOL state, NSUInteger index, BOOL *stop))resultBlock;

- (void)executeQueryDescription:(MDDTokenDescription *)description block:(void (^)(NSDictionary *dictionary))block;
- (BOOL)executeQueryDescription:(MDDTokenDescription *(^)(NSUInteger index, BOOL *stop))block result:(void (^)(NSUInteger index, NSDictionary *dictionary, BOOL *stop))resultBlock;

- (void)executeQuery:(NSString *)query values:(NSArray *)values block:(void (^)(NSDictionary *dictionary))block;
- (BOOL)executeQuery:(NSString *(^)(NSUInteger index, NSArray **values, BOOL *stop))block result:(void (^)(NSUInteger index, NSDictionary *dictionary, BOOL *stop))resultBlock;

@end
