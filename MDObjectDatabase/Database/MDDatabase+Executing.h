//
//  MDDatabase+Executing.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/12/1.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDatabase.h"

@protocol MDDReferenceDatabase;
@interface MDDatabase (Executing)

- (BOOL)executeInTransaction:(void (^)(BOOL (^update)(NSString *SQL, NSArray *arguments, UInt64 *lastRowID), void (^query)(NSString *SQL, NSArray *arguments, void (^taker)(NSDictionary *dictionary)), BOOL *rollback))block;

- (BOOL)executeUpdateSQL:(NSString *)SQL;

- (BOOL)executeUpdateSQL:(NSString *)SQL withArgumentsInArray:(NSArray *)arguments;

- (BOOL)executeUpdateSQL:(NSString *)SQL withArgumentsInArray:(NSArray *)arguments block:(void (^)(id<MDDReferenceDatabase> database))block;

- (void)executeQuerySQL:(NSString *)SQL block:(void (^)(NSDictionary *dictionary))block;

- (void)executeQuerySQL:(NSString *)SQL withArgumentsInArray:(NSArray *)arguments block:(void (^)(NSDictionary *dictionary))block;

@end
