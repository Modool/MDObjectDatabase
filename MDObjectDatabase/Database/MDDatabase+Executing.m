//
//  MDDatabase+Executing.m
//  MDDatabase
//
//  Created by xulinfeng on 2017/12/1.
//  Copyright © 2017年 modool. All rights reserved.
//

#import <FMDB/FMDB.h>
#import "MDDatabase+Executing.h"
#import "MDDatabase+Private.h"

@implementation MDDatabase (Executing)

- (void)executeInTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block {
    [[self lock] lock];
    [[self databaseQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        db.logsErrors = YES;
        
        self.inTransaction = YES;
        
        if (block) block(db, rollback);
        
        self.inTransaction = NO;
    }];
    [[self lock] unlock];
}

- (BOOL)executeUpdateSQL:(NSString *)SQL;{
    return [self executeUpdateSQL:SQL withArgumentsInArray:nil];
}

- (BOOL)executeUpdateSQL:(NSString *)SQL withArgumentsInArray:(NSArray *)arguments;{
    return [self executeUpdateSQL:SQL withArgumentsInArray:arguments completion:nil];
}

- (BOOL)executeUpdateSQL:(NSString *)SQL withArgumentsInArray:(NSArray *)arguments completion:(void (^)(FMDatabase *database))completion;{
    NSParameterAssert([SQL length]);
    __block BOOL result = NO;
    [[self lock] lock];
    [[self databaseQueue] inDatabase:^(FMDatabase *database) {
        database.logsErrors = YES;
        
        if (!arguments || ![arguments count]) {
            result = [database executeUpdate:SQL];
        } else {
            result = [database executeUpdate:SQL withArgumentsInArray:arguments];
        }
        if (completion) completion(database);
    }];
    [[self lock] unlock];
    
    return result;
}

- (void)executeQuerySQL:(NSString *)SQL block:(void (^)(NSDictionary *dictionary))block;{
    [self executeQuerySQL:SQL withArgumentsInArray:nil block:block];
}

- (void)executeQuerySQL:(NSString *)SQL withArgumentsInArray:(NSArray *)arguments block:(void (^)(NSDictionary *dictionary))block;{
    NSParameterAssert([SQL length]);
    
    [[self lock] lock];
    [[self databaseQueue] inDatabase:^(FMDatabase *database) {
        database.logsErrors = YES;

        FMResultSet *resultSet = nil;
        if (!arguments || ![arguments count]) {
            resultSet = [database executeQuery:SQL];
        } else {
            resultSet = [database executeQuery:SQL withArgumentsInArray:arguments];
        }
        while ([resultSet next]) {
            block([resultSet resultDictionary]);
        }
        [resultSet close];
    }];
    
    [[self lock] unlock];
}

@end
