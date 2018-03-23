//
//  MDDatabase+Executing.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/12/1.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDatabase.h"

@interface MDDatabase (Executing)

- (void)executeInTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block;

- (BOOL)executeUpdateSQL:(NSString *)SQL;

- (BOOL)executeUpdateSQL:(NSString *)SQL withArgumentsInArray:(NSArray *)arguments;

- (BOOL)executeUpdateSQL:(NSString *)SQL withArgumentsInArray:(NSArray *)arguments completion:(void (^)(FMDatabase *database))completion;

- (void)executeQuerySQL:(NSString *)SQL block:(void (^)(NSDictionary *dictionary))block;

- (void)executeQuerySQL:(NSString *)SQL withArgumentsInArray:(NSArray *)arguments block:(void (^)(NSDictionary *dictionary))block;

@end
