//
//  MDDatabase+Executing.m
//  MDDatabase
//
//  Created by xulinfeng on 2017/12/1.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDatabase+Executing.h"
#import "MDDatabase+Private.h"
#import "MDDReferenceDatabase.h"

@implementation MDDatabase (Executing)

- (void)executeInTransaction:(void (^)(id<MDDReferenceDatabase> database, BOOL *rollback))block {
    [[self lock] lock];
    [[self databaseQueue] inTransaction:^(id<MDDReferenceDatabase> database, BOOL *rollback) {
        database.logsErrors = YES;
        
        self.inTransaction = YES;
        
        if (block) block(database, rollback);
        
        self.inTransaction = NO;
    }];
    [[self lock] unlock];
}

- (BOOL)executeUpdateSQL:(NSString *)SQL;{
    return [self executeUpdateSQL:SQL withArgumentsInArray:nil];
}

- (BOOL)executeUpdateSQL:(NSString *)SQL withArgumentsInArray:(NSArray *)arguments;{
    return [self executeUpdateSQL:SQL withArgumentsInArray:arguments block:nil];
}

- (BOOL)executeUpdateSQL:(NSString *)SQL withArgumentsInArray:(NSArray *)arguments block:(void (^)(id<MDDReferenceDatabase> database))block;{
    NSParameterAssert([SQL length]);
    __block BOOL result = NO;
    [[self lock] lock];
    [[self databaseQueue] inDatabase:^(id<MDDReferenceDatabase> database) {
        database.logsErrors = YES;
        
        if (!arguments || ![arguments count]) {
            result = [database executeUpdate:SQL];
        } else {
            result = [database executeUpdate:SQL withArgumentsInArray:arguments];
        }
        if (block) block(database);
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
    [[self databaseQueue] inDatabase:^(id<MDDReferenceDatabase> database) {
        database.logsErrors = YES;

        id<MDDReferenceDatabaseResultSet> resultSet = nil;
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
