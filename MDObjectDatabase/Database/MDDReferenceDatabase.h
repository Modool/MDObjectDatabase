//
//  MDDReferenceDatabase.h
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/29.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MDDReferenceDatabaseResultSet <NSObject>

@property (atomic, assign, readonly) void *statementData;
@property (nonatomic, strong, readonly) NSDictionary *resultDictionary;

- (int)columnIndexForName:(NSString *)columnName;
- (id)objectForColumnIndex:(int)columnIdx;

- (BOOL)next;
- (void)close;

@end

@protocol MDDReferenceDatabase <NSObject>

@property (atomic, assign) BOOL logsErrors;
@property (nonatomic, assign, readonly) UInt64 lastInsertRowId;

- (BOOL)executeUpdate:(NSString*)sql, ...;
- (BOOL)executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray *)arguments;

- (id<MDDReferenceDatabaseResultSet>)executeQuery:(NSString *)sql, ...;
- (id<MDDReferenceDatabaseResultSet>)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray *)arguments;

@end

@protocol MDDReferenceDatabaseQueue <NSObject>

@property (atomic, copy) NSString *path;

- (void)inTransaction:(__attribute__((noescape)) void (^)(id<MDDReferenceDatabase> database, BOOL *rollback))block;
- (void)inDatabase:(void (^)(id<MDDReferenceDatabase> database))block;

- (BOOL)interrupt;
- (void)close;

@end
