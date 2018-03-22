//
//  MDDatabaseAccessor+MDDatabase.m
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/29.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDatabaseAccessor+MDDatabase.h"
#import "MDDatabase+Executing.h"

@implementation MDDatabaseAccessor (MDDatabase)

- (BOOL)executeInsertDescriptions:(NSArray<MDDatabaseTokenDescription *> *)descriptions block:(void (^)(NSUInteger index, NSUInteger rowID))block;{
    NSParameterAssert(descriptions && [descriptions count]);
    [[self database] attachTableIfNeedsWithClass:[self modelClass]];
    
    return [self executeInsert:^MDDatabaseTokenDescription *(NSUInteger index, BOOL *stop) {
        *stop = index >= (descriptions.count - 1);
        
        return descriptions[index];;
    } result:^(BOOL state, UInt64 rowID, NSUInteger index, BOOL *stop) {
        if (block) block(index, rowID);
    }];
}

- (BOOL)executeInsert:(MDDatabaseTokenDescription *(^)(NSUInteger index, BOOL *stop))block result:(void (^)(BOOL state, UInt64 rowID, NSUInteger index, BOOL *stop))resultBlock;{
    return [self _executeUpdate:block result:^(BOOL state, FMDatabase *database, NSUInteger index, BOOL *stop) {
        if (resultBlock) resultBlock(state, database.lastInsertRowId, index, stop);
    }];
}

- (BOOL)executeInsertDescription:(MDDatabaseTokenDescription *)description completion:(void (^)(NSUInteger rowID))completion;{
    return [self executeUpdateDescription:description completion:^(FMDatabase *database) {
        if (completion) completion([database lastInsertRowId]);
    }];
}

- (BOOL)executeUpdateDescription:(MDDatabaseTokenDescription *)description;{
    return [self executeUpdateDescription:description completion:nil];
}

- (BOOL)executeUpdateDescription:(MDDatabaseTokenDescription *)description completion:(void (^)(FMDatabase *database))completion;{
    NSParameterAssert(description);
    [[self database] attachTableIfNeedsWithClass:[self modelClass]];
    
    return [[self database] executeUpdateSQL:[description tokenString] withArgumentsInArray:[description values] completion:completion];
}

- (BOOL)executeUpdateDescriptions:(NSArray<MDDatabaseTokenDescription *> *)descriptions;{
    NSParameterAssert(descriptions && [descriptions count]);
    return [self _executeUpdate:^MDDatabaseTokenDescription *(NSUInteger index, BOOL *stop) {
        *stop = index >= (descriptions.count - 1);
        
        return descriptions[index];
    } result:nil];
}

- (BOOL)executeUpdate:(MDDatabaseTokenDescription *(^)(NSUInteger index, BOOL *stop))block result:(void (^)(BOOL state, NSUInteger index, BOOL *stop))resultBlock;{
    return [self _executeUpdate:block result:^(BOOL state, FMDatabase *database, NSUInteger index, BOOL *stop) {
        if (resultBlock) resultBlock(state, index, stop);
    }];
}

- (BOOL)_executeUpdate:(MDDatabaseTokenDescription *(^)(NSUInteger index, BOOL *stop))block result:(void (^)(BOOL state, FMDatabase *database, NSUInteger index, BOOL *stop))resultBlock;{
    NSParameterAssert(block);
    [[self database] attachTableIfNeedsWithClass:[self modelClass]];
    
    __block BOOL success = YES;
    [[self database] executeInTransaction:^(FMDatabase *database, BOOL *rollback) {
        @try {
            NSUInteger index = 0;
            BOOL stop = NO;
            BOOL result = YES;
            while (!stop && result) {
                MDDatabaseTokenDescription *description = block(index, &stop);
                index++;
                
                NSLog(@"Database will excute to update with SQL: %@ \nValues:%@", description.tokenString, description.values);
                if (!description) continue;
                
                NSArray *values = [description values];
                if (!values || ![values count]) {
                    result = [database executeUpdate:[description tokenString]];
                } else {
                    result = [database executeUpdate:[description tokenString] withArgumentsInArray:values];
                }
                
                NSLog(@"Database excute to update: %d \nSQL: %@ \nValues:%@", result, description.tokenString, description.values);
                if (resultBlock) resultBlock(result, database, index - 1, &stop);
            }
        } @catch (NSException *exception) {
            *rollback = YES;
            success = NO;
        }
    }];
    return success;
}

- (void)executeQueryDescription:(MDDatabaseTokenDescription *)description block:(void (^)(NSDictionary *dictionary))block;{
    NSParameterAssert(description);
    [[self database] attachTableIfNeedsWithClass:[self modelClass]];
    
    [[self database] executeQuerySQL:[description tokenString] withArgumentsInArray:[description values] block:block];
}

- (BOOL)executeQueryDescription:(MDDatabaseTokenDescription *(^)(NSUInteger index, BOOL *stop))block result:(void (^)(NSUInteger index, NSDictionary *dictionary, BOOL *stop))resultBlock;{
    return [self executeQuery:^NSString *(NSUInteger index, NSArray **values, BOOL *stop) {
        MDDatabaseTokenDescription *description = block(index, stop);
        
        *values = description.values;
        return [description tokenString];
    } result:^(NSUInteger index, NSDictionary *dictionary, BOOL *stop) {
        if (resultBlock) resultBlock(index, dictionary, stop);
    }];
}

- (void)executeQuery:(NSString *)query values:(NSArray *)values block:(void (^)(NSDictionary *dictionary))block;{
    [[self database] executeQuerySQL:query withArgumentsInArray:values block:block];
}

- (BOOL)executeQuery:(NSString *(^)(NSUInteger index, NSArray **values, BOOL *stop))block result:(void (^)(NSUInteger index, NSDictionary *dictionary, BOOL *stop))resultBlock;{
    NSParameterAssert(block && resultBlock);
    [[self database] attachTableIfNeedsWithClass:[self modelClass]];
    
    __block BOOL success = YES;
    [[self database] executeInTransaction:^(FMDatabase *database, BOOL *rollback) {
        @try {
            NSUInteger index = 0;
            BOOL stop = NO;
            while (!stop) {
                NSArray *values = nil;
                NSString *SQL = block(index, &values, &stop);
                
                index++;
                if (![SQL length]) continue;
                
                NSLog(@"Database excute to query with SQL: %@ \nValues:%@", SQL, values);
                
                FMResultSet *resultSet = nil;
                if (!values || ![values count]) {
                    resultSet = [database executeQuery:SQL];
                } else {
                    resultSet = [database executeQuery:SQL withArgumentsInArray:values];
                }
                while ([resultSet next]) {
                    if (resultBlock) resultBlock(index - 1, [resultSet resultDictionary], &stop);
                }
                [resultSet close];
            }
        } @catch (NSException *exception) {
            *rollback = YES;
            success = NO;
        }
    }];
    
    return success;
}

@end
