//
//  MDDProcessor+MDDatabase.m
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/29.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDProcessor+MDDatabase.h"
#import "MDDatabase+Executing.h"

#import "MDDReferenceDatabase.h"

#import "MDDDescriptor.h"
#import "MDDDescription.h"

#import "MDDQuery+Private.h"
#import "MDDInserter.h"
#import "MDDUpdater.h"
#import "MDDDeleter.h"
#import "MDDLogger.h"

@implementation MDDProcessor (MDDatabase)

- (BOOL)executeInserter:(MDDInserter *)inserter block:(void (^)(UInt64 rowID))block;{
    NSParameterAssert(inserter);
    MDDDescription *description = [inserter SQLDescription];
    return [self executeUpdateSQL:[description SQL] values:[description values] block:^(UInt64 lastRowID) {
        if (block) block(lastRowID);
    }];
}

- (BOOL)executeInserters:(MDDInserter *(^)(NSUInteger index, BOOL *stop))block block:(void (^)(BOOL state, UInt64 rowID, NSUInteger index, BOOL *stop))resultBlock;{
    NSParameterAssert(block);
    return [self executeUpdateSQLs:^NSString *(NSUInteger index, NSArray **values, BOOL *stop) {
        MDDInserter *inserter = block(index, stop);
        NSParameterAssert(inserter);
        
        MDDDescription *description = [inserter SQLDescription];
        NSParameterAssert(description);
        
        *values = [description values];
        return [description SQL];
    } block:^(BOOL state, UInt64 lastRowID, NSUInteger index, BOOL *stop) {
        if (resultBlock) resultBlock(state, lastRowID, index, stop);
    }];
}

- (BOOL)executeDeleter:(MDDDeleter *)deleter;{
    NSParameterAssert(deleter);
    MDDDescription *description = [deleter SQLDescription];
    return [self executeUpdateSQL:[description SQL] values:[description values] block:nil];
}

- (BOOL)executeDeleters:(MDDDeleter *(^)(NSUInteger index, BOOL *stop))block block:(void (^)(BOOL state, NSUInteger index, BOOL *stop))resultBlock;{
    NSParameterAssert(block);
    return [self executeUpdateSQLs:^NSString *(NSUInteger index, NSArray **values, BOOL *stop) {
        MDDDeleter *deleter = block(index, stop);
        NSParameterAssert(deleter);
        
        MDDDescription *description = [deleter SQLDescription];
        NSParameterAssert(description);
        
        *values = [description values];
        return [description SQL];
    } block:^(BOOL state, UInt64 lastRowID, NSUInteger index, BOOL *stop) {
        if (resultBlock) resultBlock(state, index, stop);
    }];
}

- (BOOL)executeUpdater:(MDDUpdater *)updater;{
    NSParameterAssert(updater);
    MDDDescription *description = [updater SQLDescription];
    return [self executeUpdateSQL:[description SQL] values:[description values] block:nil];
}

- (BOOL)executeUpdaters:(MDDUpdater *(^)(NSUInteger index, BOOL *stop))block block:(void (^)(BOOL state, NSUInteger index, BOOL *stop))resultBlock;{
    NSParameterAssert(block);
    return [self executeUpdateSQLs:^NSString *(NSUInteger index, NSArray **values, BOOL *stop) {
        MDDUpdater *updater = block(index, stop);
        NSParameterAssert(updater);
        
        MDDDescription *description = [updater SQLDescription];
        NSParameterAssert(description);
        
        *values = [description values];
        return [description SQL];
    } block:^(BOOL state, UInt64 lastRowID, NSUInteger index, BOOL *stop) {
        if (resultBlock) resultBlock(state, index, stop);
    }];
}

- (void)executeQuery:(MDDQuery *)query block:(void (^)(id result))block;{
    NSParameterAssert(query);
    MDDDescription *description = [query SQLDescription];
    return [self executeQuerySQL:[description SQL] values:[description values] block:^(NSDictionary *dictionary) {
        if (block) block([query transformValue:dictionary]);
    }];
}

- (BOOL)executeQueries:(MDDQuery *(^)(NSUInteger index, BOOL *stop))block block:(void (^)(NSUInteger index, id result, BOOL *stop))resultBlock;{
    NSParameterAssert(block);
    return [self executeQuerySQLs:^NSString *(NSUInteger index, NSArray **values, BOOL *stop) {
        MDDQuery *query = block(index, stop);
        NSParameterAssert(query);
        
        MDDDescription *description = [query SQLDescription];
        NSParameterAssert(description);
        
        *values = [description values];
        return [description SQL];
    } result:^(NSUInteger index, NSDictionary *dictionary, BOOL *stop) {
        MDDQuery *query = block(index, stop);
        NSParameterAssert(query);
        
        if (resultBlock) resultBlock(index, [query transformValue:dictionary], stop);
    }];
}

- (void)executeQuerySQL:(NSString *)SQL values:(NSArray *)values block:(void (^)(NSDictionary *dictionary))block;{
    MDDLog(MDDLoggerLevelInfo, @"%@\n%@", SQL, values);
    [[self database] executeQuerySQL:SQL withArgumentsInArray:values block:block];
}

- (BOOL)executeQuerySQLs:(NSString *(^)(NSUInteger index, NSArray **values, BOOL *stop))block result:(void (^)(NSUInteger index, NSDictionary *dictionary, BOOL *stop))resultBlock;{
    NSParameterAssert(block && resultBlock);
    
    return [[self database] executeInTransaction:^(BOOL (^update)(NSString *SQL, NSArray *arguments, UInt64 *lastRowID), void (^query)(NSString *SQL, NSArray *arguments, void (^taker)(NSDictionary *dictionary)), BOOL *rollback) {
        NSUInteger index = 0;
        __block BOOL stop = NO;
        while (!stop) {
            NSArray *values = nil;
            NSString *SQL = block(index, &values, &stop);
            
            index++;
            if (![SQL length]) continue;
            
            MDDLog(MDDLoggerLevelInfo, @"%@\n%@", SQL, values);
            query(SQL, values, ^(NSDictionary *dictionary){
                if (resultBlock) resultBlock(index - 1, dictionary, &stop);
            });
        }
    }];
}

- (BOOL)executeUpdateSQL:(NSString *)SQL values:(NSArray *)values block:(void (^)(id<MDDReferenceDatabase> database))block;{
    MDDLog(MDDLoggerLevelInfo, @"%@\n%@", SQL, values);
    
    return [[self database] executeUpdateSQL:SQL withArgumentsInArray:values block:block];
}

- (BOOL)executeUpdateSQLs:(NSString *(^)(NSUInteger index, NSArray **values, BOOL *stop))block block:(void (^)(BOOL state, UInt64 lastRowID, NSUInteger index, BOOL *stop))resultBlock;{
    NSParameterAssert(block && resultBlock);
    return [[self database] executeInTransaction:^(BOOL (^update)(NSString *SQL, NSArray *arguments, UInt64 *lastRowID), void (^query)(NSString *SQL, NSArray *arguments, void (^taker)(NSDictionary *dictionary)), BOOL *rollback) {
        NSUInteger index = 0;
        BOOL stop = NO;
        BOOL result = YES;
        while (!stop && result) {
            NSArray *values = nil;
            NSString *SQL = block(index, &values, &stop);
            index++;
            
            if (![SQL length]) continue;
            
            MDDLog(MDDLoggerLevelInfo, @"%@\n%@", SQL, values);
            UInt64 lastRowID = 0;
            result = update(SQL, values, &lastRowID);
            
            if (resultBlock) resultBlock(result, lastRowID, index - 1, &stop);
        }
        *rollback = !result;
    }];
    
}

@end
