//
//  MDDatabase.m
//  MDDatabase
//
//  Created by xulinfeng on 2017/12/1.
//  Copyright © 2017年 modool. All rights reserved.
//

#if FMDB_SQLITE_STANDALONE
#import <sqlite3/sqlite3.h>
#else
#import <sqlite3.h>
#endif

#import <FMDB/FMDB.h>

#import "MDDatabase.h"
#import "MDDatabase+Private.h"
#import "MDDatabase+Executing.h"

#import "MDDTableInfo.h"
#import "MDDIndex+Private.h"

#import "MDDColumn+Private.h"

#import "MDDObject.h"
#import "MDDColumnConfiguration.h"

NSString * const MDDatabaseErrorDomain = @"com.modool.database.error.domain";

NSString * const MDDatabaseQueryTableExsitSQL = @"SELECT COUNT(name) FROM sqlite_master WHERE type = 'table' AND name = '%@'";
NSString * const MDDatabaseQueryRowSQL = @"SELECT * FROM %@ LIMIT 0";

NSString * const MDDatabaseCreateTableSQL = @"CREATE TABLE IF NOT EXISTS %@ ( %@ )";
NSString * const MDDatabaseAlterTableSQL = @"ALTER TABLE %@ %@";
NSString * const MDDatabaseAddColumnCommand = @"ADD";

NSString * const MDDatabaseQueryIndexNameSQL = @"SELECT * FROM sqlite_master WHERE type = 'index' AND tbl_name = '%@' AND sql NOT NULL";

@implementation MDDatabase

+ (instancetype)databaseWithFilepath:(NSString *)filepath{
    NSParameterAssert([filepath length]);
    
    MDDatabase *database = [self new];
    
    database->_tableInfos = [NSMutableDictionary<NSString *, MDDTableInfo *> new];
    database->_databaseQueue = [[FMDatabaseQueue alloc] initWithPath:filepath];
    database->_lock = [[NSRecursiveLock alloc] init];
    
    return database;
}

- (void)dealloc{
    [self close];
}

#pragma mark - public

- (void)attachTableIfNeedsWithClass:(Class<MDDObject>)class;{
    [self requireTableInfoWithClass:class];
}

- (MDDTableInfo *)requireTableInfoWithClass:(Class<MDDObject>)class;{
    if (self.inTransaction) {
        return [self _requireTableInfoWithClass:class];
    }
    
    [[self lock] lock];
    MDDTableInfo *info = [self _requireTableInfoWithClass:class];
    [[self lock] unlock];
    
    return info;
}

- (BOOL)containedTableWithClass:(Class<MDDObject>)class;{
    NSString *tableName = [self _tableNameFromClass:class];
    NSParameterAssert(tableName);
    
    [[self lock] lock];
    BOOL contained = [self _containedTableWithName:tableName];
    [[self lock] unlock];
    
    return contained;
}

- (void)close;{
    [[self lock] lock];
    
    [[self databaseQueue] interrupt];
    [[self databaseQueue] close];
    
    [[self lock] unlock];
}

#pragma mark - private

- (NSString *)_tableNameFromClass:(Class<MDDObject>)class{
    if (![class conformsToProtocol:@protocol(MDDObject)]) return nil;
    
    BOOL respondTableName = [class respondsToSelector:@selector(tableName)];
    
    return respondTableName ? [class tableName] : nil;
}

- (MDDTableInfo *)_requireTableInfoWithClass:(Class<MDDObject>)class;{
    NSString *tableName = [self _tableNameFromClass:class];
    NSParameterAssert(tableName);
    
    MDDTableInfo *tableInfo = [self tableInfos][tableName];
    
    if (!tableInfo) {
        NSError *error = nil;
        BOOL success = [self _attachTableWithClass:class error:&error];
        if (success) {
            tableInfo = [self tableInfos][tableName];
        } else {
            NSLog(@"Failed to require table with error: %@", error);
        }
    }
    return tableInfo;
}

- (BOOL)_containedTableWithName:(NSString *)tableName;{
    return [[[self tableInfos] allKeys] containsObject:tableName];;
}

- (BOOL)_attachTableWithClass:(Class<MDDObject>)class error:(NSError **)error;{
    if (![class conformsToProtocol:@protocol(MDDObject)]) {
        if (error) *error = [NSError errorWithDomain:MDDatabaseErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Class %@ didn't comform protocol %@", class, @protocol(MDDObject)]}];
        return NO;
    }
    
    if (![class respondsToSelector:@selector(tableName)]) {
        if (error) *error = [NSError errorWithDomain:MDDatabaseErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Class %@ didn't respond selector %@", class, NSStringFromSelector(@selector(tableName))]}];
        return NO;
    }
    
    NSString *tableName = [class tableName];
    if (![tableName length]) {
        if (error) *error = [NSError errorWithDomain:MDDatabaseErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Table name is nil for class %@ ", class]}];
        return NO;
    }
    
    if ([self _containedTableWithName:tableName]) return YES;
    
    MDDTableInfo *info = [MDDTableInfo infoWithTableName:tableName class:class error:error];
    if (!info) return NO;
    
    BOOL exsit = [self _exsitWithName:tableName];
    if (!exsit) {
        BOOL sucess = [self _createTableWithInfo:info class:class];
        if (!sucess) {
            if (error) *error = [NSError errorWithDomain:MDDatabaseErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to create table %@ of class %@", tableName, class]}];
            return NO;
        }
    } else {
        BOOL sucess = [self _verifyColumnsWithInfo:info class:class];
        if (!sucess) {
            if (error) *error = [NSError errorWithDomain:MDDatabaseErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to verify columns for table %@ of class %@", tableName, class]}];
            return NO;
        }
    }
    
    BOOL success = [self _verifyIndexesWithInfo:info class:class];
    if (!success) {
        if (error) *error = [NSError errorWithDomain:MDDatabaseErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to verify indexes for table %@ of class %@", tableName, class]}];
        
        return NO;
    }
    self.tableInfos[tableName] = info;
    
    return YES;
}

- (BOOL)_exsitWithName:(NSString *)tableName{
    __block BOOL exsit = NO;
    NSString *SQL = [NSString stringWithFormat:MDDatabaseQueryTableExsitSQL, tableName];
    [[self databaseQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:SQL];
        if ([set next]) {
            exsit = [set intForColumnIndex:0] > 0;
        }
        [set close];
    }];
    return exsit;
}

- (BOOL)_createTableWithInfo:(MDDTableInfo *)info class:(Class<MDDObject>)class{
    NSArray<NSString *> *columnDescriptions = [self descriptionsForColumns:[info columns] class:class command:nil];
    NSString *SQL = [NSString stringWithFormat:MDDatabaseCreateTableSQL, [info tableName], [columnDescriptions componentsJoinedByString:@","]];
    
    __block BOOL success = NO;
    [[self databaseQueue] inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:SQL];
    }];
    return success;
}

- (BOOL)_verifyColumnsWithInfo:(MDDTableInfo *)info class:(Class<MDDObject>)class{
    NSArray<NSString *> *columnNames = [self columnNamesInDatabaseWithInfo:info];
    NSMutableArray<MDDColumn *> *insertColumns = [NSMutableArray<MDDColumn *> new];
    for (MDDColumn *column in [info columns]) {
        if ([columnNames containsObject:[column name]]) continue;
        
        [insertColumns addObject:column];
    }
    if (![insertColumns count]) return YES;
    
    return [self _appendColumns:insertColumns tableName:[info tableName] class:class];
}

- (BOOL)_appendColumns:(NSArray<MDDColumn *> *)columns tableName:(NSString *)tableName class:(Class<MDDObject>)class{
    NSArray<NSString *> *columnDescriptions = [self descriptionsForColumns:columns class:class command:MDDatabaseAddColumnCommand];
    
    __block BOOL success = NO;
    [self executeInTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (NSString *description in columnDescriptions) {
            NSString *SQL = [NSString stringWithFormat:MDDatabaseAlterTableSQL, tableName, description];
            
            BOOL state = [db executeUpdate:SQL];
            
            *rollback = !state;
            if (!state) break;
        }
        success = !(*rollback);
    }];
    return success;
}

- (NSArray<NSString *> *)columnNamesInDatabaseWithInfo:(MDDTableInfo *)info{
    NSString *SQL = [NSString stringWithFormat:MDDatabaseQueryRowSQL, [info tableName]];
    
    NSMutableArray<NSString *> *columnNames = [NSMutableArray new];
    [[self databaseQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:SQL];
        
        int columnCount = sqlite3_column_count(set.statement.statement);
        for (int index = 0; index < columnCount; index++) {
            NSString *columnName = [NSString stringWithUTF8String:sqlite3_column_name(set.statement.statement, index)];
            
            [columnNames addObject:columnName];
        }
        [set close];
    }];
    return columnNames;
}

- (NSArray<NSString *> *)descriptionsForColumns:(NSArray<MDDColumn *> *)columns class:(Class<MDDObject>)class command:(NSString *)command{
    NSMutableArray<NSString *> *descriptions = [NSMutableArray<NSString *> new];
    
    for (MDDColumn *column in columns) {
        NSString *description = [self columnDescriptionWithColumn:column class:class];
        
        [descriptions addObject:[NSString stringWithFormat:@" %@ %@ ", command ?: @"", description ?: @""]];
    }
    
    return [descriptions copy];
}

- (NSString *)columnDescriptionWithColumn:(MDDColumn *)column class:(Class<MDDObject>)class;{
    MDDColumnConfiguration *configuration = [self defaultConfigurationForColumn:column];
    
    if ([class respondsToSelector:@selector(configuration:forColumn:)]) {
        [class configuration:configuration forColumn:column];
    }
    
    NSMutableString *description = [NSMutableString stringWithString:[column name]];
    [description appendFormat:@" %@", ([self descriptionForDatabaseType:[column type]] ?: @"TEXT")];
    
    if ([configuration length]) {
        [description appendFormat:@"(%ld)", (long)[configuration length]];
    }
    
    if ([column isPrimary]) {
        [description appendString:@" PRIMARY KEY "];
    }
    
    if ([column isAutoincrement]) {
        [description appendString:@" AUTOINCREMENT "];
    }
    
    if (![configuration isNullabled]) {
        [description appendString:@" NOT NULL "];
    }
    
    if ([configuration isUnique]) {
        [description appendString:@" UNIQUE "];
    }
    
    if ([configuration checkValue]) {
        [description appendFormat:@" CHECK(%@) ", [configuration checkValue]];
    }
    
    if ([configuration defaultValue]) {
        [description appendFormat:@" DEFAULT %@ ", [configuration defaultValue]];
    }
    
    return [description copy];
}

- (MDDColumnConfiguration *)defaultConfigurationForColumn:(MDDColumn *)column{
    return [MDDColumnConfiguration defaultConfigurationWithColumn:column];
}

- (NSString *)descriptionForDatabaseType:(MDDColumnType)type{
    static NSDictionary *descriptions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        descriptions = @{@(MDDColumnTypeText): @"TEXT",
                         @(MDDColumnTypeInteger): @"INTEGER",
                         @(MDDColumnTypeFloat): @"FLOAT",
                         @(MDDColumnTypeDouble): @"DOUBLE",
                         @(MDDColumnTypeBoolean): @"BLOB",
                         };
    });
    
    return descriptions[@(type)];
}

- (BOOL)_verifyIndexesWithInfo:(MDDTableInfo *)info class:(Class<MDDObject>)class {
    NSArray<NSString *> *indexNames =  [info indexNames];
    NSArray<MDDIndex *> *indexes =  [info indexes];
    
    NSArray<MDDLocalIndex *> *localIndexes = [self _localIndexNamesWithInfo:info];
    
    NSMutableSet<MDDIndex *> *insertIndexes = [NSMutableSet new];
    NSMutableSet<MDDLocalIndex *> *deleteIndexes = [NSMutableSet new];
    
    for (MDDIndex *index in indexes) {
        index.tableInfo = info;
        
        MDDLocalIndex *localIndex = [self _localIndexWithName:[index name] indexes:localIndexes];
        if (!localIndex) [insertIndexes addObject:index];
        else if (![[localIndex SQL] isEqualToString:[index creatingSQL]]) {
            [insertIndexes addObject:index];
            [deleteIndexes addObject:localIndex];
        }
    }
    for (MDDLocalIndex *localIndex in localIndexes) {
        if ([indexNames containsObject:[localIndex name]]) continue;
        
        [deleteIndexes addObject:localIndex];
    }
    if ([deleteIndexes count]) {
        if (![self _deleteLocalIndexes:deleteIndexes]) return NO;
    }
    
    if ([insertIndexes count]) {
        if (![self _appendIndexes:insertIndexes]) return NO;
    }
    return  YES;
}

- (BOOL)_appendIndexes:(NSSet<MDDIndex *> *)indexes{
    __block BOOL success = NO;
    [self executeInTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (MDDIndex *index in indexes) {
            BOOL state = [db executeUpdate:[index creatingSQL]];
            *rollback = !state;
            if (!state) break;
        }
        success = !(*rollback);
    }];
    return success;
}

- (BOOL)_deleteLocalIndexes:(NSSet<MDDLocalIndex *> *)indexes{
    __block BOOL success = NO;
    [self executeInTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (MDDLocalIndex *index in indexes) {
            BOOL state = [db executeUpdate:[index droppingSQL]];
            
            *rollback = !state;
            if (!state) break;
        }
        success = !(*rollback);
    }];
    return success;
}

- (MDDLocalIndex *)_localIndexWithName:(NSString *)name indexes:(NSArray<MDDLocalIndex *> *)indexes{
    for (MDDLocalIndex *index in indexes) {
        if (![name isEqualToString:[index name]]) continue;
        
        return index;
    }
    return nil;
}

- (NSArray<MDDLocalIndex *> *)_localIndexNamesWithInfo:(MDDTableInfo *)info{
    NSMutableArray *indexes = [NSMutableArray new];
    [[self databaseQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:[NSString stringWithFormat:MDDatabaseQueryIndexNameSQL, info.tableName]];
        while ([set next]) {
            NSString *name = [set stringForColumn:@"name"];
            NSString *SQL = [set stringForColumn:@"sql"];
            
            [indexes addObject:[MDDLocalIndex indexWithName:name tableName:[info tableName] SQL:SQL]];
        }
        [set close];
    }];
    return [indexes copy];
}

@end
