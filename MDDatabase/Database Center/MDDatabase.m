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

#import "MDDatabaseTableInfo.h"
#import "MDDatabaseIndex+Private.h"

#import "MDDatabaseColumn+Private.h"

#import "MDDatabaseObject.h"
#import "MDDatabaseColumnConfiguration.h"

NSString * const MDDatabaseErrorDomain = @"com.modool.database.error.domain";

NSString * const MDDatabaseQueryTableExsitSQL = @"SELECT COUNT(name) FROM sqlite_master WHERE type = 'table' AND name = '%@'";
NSString * const MDDatabaseQueryRowSQL = @"SELECT * FROM %@ LIMIT 0";

NSString * const MDDatabaseCreateTableSQL = @"CREATE TABLE IF NOT EXISTS %@ ( %@ )";
NSString * const MDDatabaseAlterTableSQL = @"ALTER TABLE %@ %@";
NSString * const MDDatabaseAddColumnCommand = @"ADD";

NSString * const MDDatabaseQueryIndexNameSQL = @"SELECT * FROM sqlite_master WHERE type = 'index' AND tbl_name = '%@' AND sql NOT NULL";

@implementation MDDatabase

+ (instancetype)databaseWithFilepath:(NSString *)filepath UID:(NSString *)UID{
    NSParameterAssert([filepath length] && [UID length]);
    
    MDDatabase *database = [self new];
    
    database->_tableInfos = [NSMutableDictionary<NSString *, MDDatabaseTableInfo *> new];
    database->_databaseQueue = [[FMDatabaseQueue alloc] initWithPath:filepath];
    database->_UID = [UID copy];
    database->_lock = [[NSRecursiveLock alloc] init];
    
    return database;
}

- (void)dealloc{
    [self close];
}

#pragma mark - public

- (void)attachTableIfNeedsWithClass:(Class<MDDatabaseObject>)class;{
    [self requireTableInfoWithClass:class];
}

- (MDDatabaseTableInfo *)requireTableInfoWithClass:(Class<MDDatabaseObject>)class;{
    if (self.inTransaction) {
        return [self _requireTableInfoWithClass:class];
    }
    
    [[self lock] lock];
    MDDatabaseTableInfo *info = [self _requireTableInfoWithClass:class];
    [[self lock] unlock];
    
    return info;
}

- (BOOL)containedTableWithClass:(Class<MDDatabaseObject>)class;{
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

- (NSString *)_tableNameFromClass:(Class<MDDatabaseObject>)class{
    if (![class conformsToProtocol:@protocol(MDDatabaseObject)]) return nil;
    
    BOOL respondTableName = [class respondsToSelector:@selector(tableName)];
    
    return respondTableName ? [class tableName] : nil;
}

- (MDDatabaseTableInfo *)_requireTableInfoWithClass:(Class<MDDatabaseObject>)class;{
    NSString *tableName = [self _tableNameFromClass:class];
    NSParameterAssert(tableName);
    
    MDDatabaseTableInfo *tableInfo = [self tableInfos][tableName];
    
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

- (BOOL)_attachTableWithClass:(Class<MDDatabaseObject>)class error:(NSError **)error;{
    if (![class conformsToProtocol:@protocol(MDDatabaseObject)]) {
        if (error) *error = [NSError errorWithDomain:MDDatabaseErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Class %@ didn't comform protocol %@", class, @protocol(MDDatabaseObject)]}];
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
    
    MDDatabaseTableInfo *info = [MDDatabaseTableInfo infoWithTableName:tableName class:class error:error];
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

- (BOOL)_createTableWithInfo:(MDDatabaseTableInfo *)info class:(Class<MDDatabaseObject>)class{
    NSArray<NSString *> *columnDescriptions = [self descriptionsForColumns:[info columns] class:class command:nil];
    NSString *SQL = [NSString stringWithFormat:MDDatabaseCreateTableSQL, [info tableName], [columnDescriptions componentsJoinedByString:@","]];
    
    __block BOOL success = NO;
    [[self databaseQueue] inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:SQL];
    }];
    return success;
}

- (BOOL)_verifyColumnsWithInfo:(MDDatabaseTableInfo *)info class:(Class<MDDatabaseObject>)class{
    NSArray<NSString *> *columnNames = [self columnNamesInDatabaseWithInfo:info];
    NSMutableArray<MDDatabaseColumn *> *appendColumns = [NSMutableArray<MDDatabaseColumn *> new];
    for (MDDatabaseColumn *column in [info columns]) {
        if ([columnNames containsObject:[column name]]) continue;
        
        [appendColumns addObject:column];
    }
    if (![appendColumns count]) return YES;
    
    return [self _appendColumns:appendColumns tableName:[info tableName] class:class];
}

- (BOOL)_appendColumns:(NSArray<MDDatabaseColumn *> *)columns tableName:(NSString *)tableName class:(Class<MDDatabaseObject>)class{
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

- (NSArray<NSString *> *)columnNamesInDatabaseWithInfo:(MDDatabaseTableInfo *)info{
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

- (NSArray<NSString *> *)descriptionsForColumns:(NSArray<MDDatabaseColumn *> *)columns class:(Class<MDDatabaseObject>)class command:(NSString *)command{
    NSMutableArray<NSString *> *descriptions = [NSMutableArray<NSString *> new];
    
    for (MDDatabaseColumn *column in columns) {
        NSString *description = [self columnDescriptionWithColumn:column class:class];
        
        [descriptions addObject:[NSString stringWithFormat:@" %@ %@ ", command ?: @"", description ?: @""]];
    }
    
    return [descriptions copy];
}

- (NSString *)columnDescriptionWithColumn:(MDDatabaseColumn *)column class:(Class<MDDatabaseObject>)class;{
    MDDatabaseColumnConfiguration *configuration = [self defaultConfigurationForColumn:column];
    
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

- (MDDatabaseColumnConfiguration *)defaultConfigurationForColumn:(MDDatabaseColumn *)column{
    return [MDDatabaseColumnConfiguration defaultConfigurationWithColumn:column];
}

- (NSString *)descriptionForDatabaseType:(MDDatabaseColumnType)type{
    static NSDictionary *descriptions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        descriptions = @{@(MDDatabaseColumnTypeText): @"TEXT",
                         @(MDDatabaseColumnTypeInteger): @"INTEGER",
                         @(MDDatabaseColumnTypeFloat): @"FLOAT",
                         @(MDDatabaseColumnTypeDouble): @"DOUBLE",
                         @(MDDatabaseColumnTypeBoolean): @"BLOB",
                         };
    });
    
    return descriptions[@(type)];
}

- (BOOL)_verifyIndexesWithInfo:(MDDatabaseTableInfo *)info class:(Class<MDDatabaseObject>)class {
    NSArray<NSString *> *indexNames =  [info indexNames];
    NSArray<MDDatabaseIndex *> *indexes =  [info indexes];
    
    NSArray<MDDatabaseLocalIndex *> *localIndexes = [self _localIndexNamesWithInfo:info];
    
    NSMutableSet<MDDatabaseIndex *> *appendIndexes = [NSMutableSet new];
    NSMutableSet<MDDatabaseLocalIndex *> *deleteIndexes = [NSMutableSet new];
    
    for (MDDatabaseIndex *index in indexes) {
        index.tableInfo = info;
        
        MDDatabaseLocalIndex *localIndex = [self _localIndexWithName:[index name] indexes:localIndexes];
        if (!localIndex) [appendIndexes addObject:index];
        else if (![[localIndex SQL] isEqualToString:[index creatingSQL]]) {
            [appendIndexes addObject:index];
            [deleteIndexes addObject:localIndex];
        }
    }
    for (MDDatabaseLocalIndex *localIndex in localIndexes) {
        if ([indexNames containsObject:[localIndex name]]) continue;
        
        [deleteIndexes addObject:localIndex];
    }
    if ([deleteIndexes count]) {
        if (![self _deleteLocalIndexes:deleteIndexes]) return NO;
    }
    
    if ([appendIndexes count]) {
        if (![self _appendIndexes:appendIndexes]) return NO;
    }
    return  YES;
}

- (BOOL)_appendIndexes:(NSSet<MDDatabaseIndex *> *)indexes{
    __block BOOL success = NO;
    [self executeInTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (MDDatabaseIndex *index in indexes) {
            BOOL state = [db executeUpdate:[index creatingSQL]];
            *rollback = !state;
            if (!state) break;
        }
        success = !(*rollback);
    }];
    return success;
}

- (BOOL)_deleteLocalIndexes:(NSSet<MDDatabaseLocalIndex *> *)indexes{
    __block BOOL success = NO;
    [self executeInTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (MDDatabaseLocalIndex *index in indexes) {
            BOOL state = [db executeUpdate:[index droppingSQL]];
            
            *rollback = !state;
            if (!state) break;
        }
        success = !(*rollback);
    }];
    return success;
}

- (MDDatabaseLocalIndex *)_localIndexWithName:(NSString *)name indexes:(NSArray<MDDatabaseLocalIndex *> *)indexes{
    for (MDDatabaseLocalIndex *index in indexes) {
        if (![name isEqualToString:[index name]]) continue;
        
        return index;
    }
    return nil;
}

- (NSArray<MDDatabaseLocalIndex *> *)_localIndexNamesWithInfo:(MDDatabaseTableInfo *)info{
    NSMutableArray *indexes = [NSMutableArray new];
    [[self databaseQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:[NSString stringWithFormat:MDDatabaseQueryIndexNameSQL, info.tableName]];
        while ([set next]) {
            NSString *name = [set stringForColumn:@"name"];
            NSString *SQL = [set stringForColumn:@"sql"];
            
            [indexes addObject:[MDDatabaseLocalIndex indexWithName:name tableName:[info tableName] SQL:SQL]];
        }
        [set close];
    }];
    return [indexes copy];
}

@end
