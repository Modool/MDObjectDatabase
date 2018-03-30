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

#import "MDDatabase.h"
#import "MDDatabase+Private.h"
#import "MDDatabase+Executing.h"
#import "MDDReferenceDatabase.h"

#import "MDDColumnConfiguration.h"

#import "MDDCompat+Private.h"
#import "MDDIndex+Private.h"
#import "MDDColumn+Private.h"
#import "MDDTableInfo+Private.h"
#import "MDDConfiguration+Private.h"
#import "MDDReferenceDatabase.h"

#import "MDDErrorCode.h"
#import "MDDLogger.h"

NSString * const MDDatabaseQueryTableExsitSQL = @"SELECT COUNT(name) FROM sqlite_master WHERE type = 'table' AND name = '%@'";
NSString * const MDDatabaseQueryRowSQL = @"SELECT * FROM %@ LIMIT 0";

NSString * const MDDatabaseCreateTableSQL = @"CREATE TABLE IF NOT EXISTS %@ ( %@ )";
NSString * const MDDatabaseAlterTableSQL = @"ALTER TABLE %@ %@";

NSString * const MDDatabaseAddColumnCommand = @"ADD COLUMN";

NSString * const MDDatabaseQueryTableInfoSQL = @"SELECT sql FROM sqlite_master WHERE type = 'table' AND tbl_name = '%@' AND sql NOT NULL";
NSString * const MDDatabaseQueryIndexNameSQL = @"SELECT * FROM sqlite_master WHERE type = 'index' AND tbl_name = '%@' AND sql NOT NULL";

@implementation MDDatabase

+ (instancetype)databaseWithDatabaseQueue:(id<MDDReferenceDatabaseQueue>)queue;{
    NSParameterAssert(queue);
    return [[self alloc] initWithDatabaseQueue:queue];
}

- (instancetype)initWithDatabaseQueue:(id<MDDReferenceDatabaseQueue>)queue;{
    NSParameterAssert(queue);
    if (self = [super init]) {
        _databaseQueue = queue;
        
        _tableInfos = [NSMutableDictionary<NSString *, MDDTableInfo *> dictionary];
        _configurations = [NSMutableDictionary<NSString *, MDDConfiguration *> dictionary];
        _compats = [NSMutableDictionary<NSString *, MDDCompat *> dictionary];
        _tableClasses = [NSMutableDictionary<NSString *, Class> dictionary];
        _lock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

- (void)dealloc{
    [self close];
}

- (NSString *)description{
    return [[self dictionaryWithValuesForKeys:@[@"tableInfos", @"configurations", @"tableClasses", @"compats", @"inTransaction", @"databaseQueue"]] description];
}

#pragma mark - public

- (MDDCompat *)addConfiguration:(MDDConfiguration *)configuration error:(NSError **)error;{
    if ([[self configurations] objectForKey:[configuration tableName]]) {
        if (error) *error = [NSError errorWithDomain:MDDatabaseErrorDomain code:MDDErrorCodeConfigurationExisted userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Exist configuration of table: %@", [configuration tableName]]}];
        return nil;
    }
    self.configurations[[configuration tableName]] = configuration;
    self.tableClasses[[configuration tableName]] = [configuration objectClass];
    
    MDDCompat *compat = [MDDCompat compat];
    self.compats[[configuration tableName]] = compat;
    
    return compat;
}

- (MDDTableInfo *)requireTableInfoWithClass:(Class<MDDObject>)class error:(NSError **)error;{
    if (self.inTransaction) {
        return [self _requireTableInfoWithClass:class error:error];
    }
    
    [[self lock] lock];
    MDDTableInfo *info = [self _requireTableInfoWithClass:class error:error];
    [[self lock] unlock];
    
    return info;
}

- (BOOL)existTableForClass:(Class<MDDObject>)class;{
    NSString *tableName = [self _tableNameFromClass:class];
    if (![tableName length]) return NO;
    
    [[self lock] lock];
    BOOL contained = [self _existTableNamed:tableName];
    [[self lock] unlock];
    
    return contained;
}

- (BOOL)prepare;{
    [[self lock] lock];
    BOOL state = [self _prepare];
    [[self lock] unlock];
    return state;
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
    
    return [[[self tableClasses] allKeysForObject:class] firstObject];
}

- (MDDTableInfo *)_requireTableInfoWithClass:(Class<MDDObject>)class error:(NSError **)error;{
    NSString *tableName = [self _tableNameFromClass:class];
    NSParameterAssert(tableName);
    
    MDDTableInfo *tableInfo = [self tableInfos][tableName];
    if (!tableInfo) {
        BOOL success = [self _initialTableWithClass:class error:error];
        if (success) {
            tableInfo = [self tableInfos][tableName];
        }
    }
    return tableInfo;
}

- (BOOL)_existTableNamed:(NSString *)tableName;{
    return [[[self tableInfos] allKeys] containsObject:tableName];;
}

- (BOOL)_initialTableWithClass:(Class<MDDObject>)class error:(NSError **)error;{
    if (![class conformsToProtocol:@protocol(MDDObject)]) {
        if (error) *error = [NSError errorWithDomain:MDDatabaseErrorDomain code:MDDErrorCodeNonconformProtocol userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Class %@ didn't comform protocol %@", class, @protocol(MDDObject)]}];
        return NO;
    }
    
    NSString *tableName = [self _tableNameFromClass:class];
    if (![tableName length]) {
        if (error) *error = [NSError errorWithDomain:MDDatabaseErrorDomain code:MDDErrorCodeTableNonexistent userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Table is non-exsit for class: %@", class]}];
        return NO;
    }
    
    if ([self _existTableNamed:tableName]) return YES;
    
    MDDConfiguration *configuration = self.configurations[tableName];
    MDDTableInfo *info = [MDDTableInfo infoWithConfiguration:configuration error:error];
    if (!info) return NO;
    
    MDDCompat *compat = self.compats[tableName];
    BOOL exsit = [self _exsitDatabaseTable:tableName];
    if (!exsit) {
        BOOL success = [self _createTableWithInfo:info configuration:configuration];
        if (!success) {
            if (error) *error = [NSError errorWithDomain:MDDatabaseErrorDomain code:MDDErrorCodeTableCreateFailed userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to create table %@ of class %@", tableName, class]}];
            return NO;
        }
    } else {
        BOOL success = [self _compatColumnsWithInfo:info configuration:configuration compat:compat];
        if (!success) {
            if (error) *error = [NSError errorWithDomain:MDDatabaseErrorDomain code:MDDErrorCodeTableCompatFailed userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to compat table %@ of class %@", tableName, class]}];
            return NO;
        }
    }
    BOOL success = [self _compatIndexesWithInfo:info configuration:configuration compat:compat];
    if (!success) {
        if (error) *error = [NSError errorWithDomain:MDDatabaseErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to verify indexes for table %@ of class %@", tableName, class]}];
        
        return NO;
    }
    self.tableInfos[tableName] = info;
    return YES;
}

- (BOOL)_exsitDatabaseTable:(NSString *)tableName{
    __block BOOL exsit = NO;
    NSString *SQL = [NSString stringWithFormat:MDDatabaseQueryTableExsitSQL, tableName];
    [[self databaseQueue] inDatabase:^(id<MDDReferenceDatabase> database) {
        id<MDDReferenceDatabaseResultSet> set = [database executeQuery:SQL];
        if ([set next]) {
            exsit = [[set objectForColumnIndex:0] intValue] > 0;
        }
        [set close];
    }];
    return exsit;
}

- (NSString *)SQLForCreatingTableWithInfo:(MDDTableInfo *)info configuration:(MDDConfiguration *)configuration{
    NSArray<NSString *> *columnDescriptions = [self descriptionsWithInfo:info configurations:[configuration columnConfigurations] command:nil];
    return [NSString stringWithFormat:MDDatabaseCreateTableSQL, [info tableName], [columnDescriptions componentsJoinedByString:@","]];
}

- (BOOL)_createTableWithInfo:(MDDTableInfo *)info configuration:(MDDConfiguration *)configuration{
    NSString *SQL = [self SQLForCreatingTableWithInfo:info configuration:configuration];
    
    __block BOOL success = NO;
    [[self databaseQueue] inDatabase:^(id<MDDReferenceDatabase> database) {
        success = [database executeUpdate:SQL];
    }];
    return success;
}

- (BOOL)_compatColumnsWithInfo:(MDDTableInfo *)info configuration:(MDDConfiguration *)configuration compat:(MDDCompat *)compat{
    NSDictionary<NSString *, MDDColumn *> *columns = [info columnMapper];
    NSDictionary<NSString *, MDDLocalColumn *> *localColumns = [self localColumnsWithInfo:info];
    
    NSMutableSet<MDDColumn *> *insertColumns = [NSMutableSet set];
    
    for (NSString *name in [columns allKeys]) {
        MDDColumn *column = columns[name];
        MDDLocalColumn *localColumn = localColumns[name];
        
        if (!localColumn) {
            MDDCompatResult operation = [compat appendColumn:column];
            if (operation == MDDCompatResultIgnore) continue;
            
            [insertColumns addObject:column];
        } else if (![column isEqualLocalColumn:localColumn]) {
            MDDLog(MDDLoggerLevelWarning, @"The column info is difference between database and class,\nname:%@\ndatabase: %@\nclass: %@", column.name, localColumn, column);
        }
    }
    
    if ([insertColumns count]) {
        BOOL state = [self _appendColumns:insertColumns info:info configurations:configuration.columnConfigurations];
        if (!state) return NO;
    }    
    return YES;
}

- (BOOL)_appendColumns:(NSSet<MDDColumn *> *)columns info:(MDDTableInfo *)info configurations:(NSDictionary<NSString *, MDDColumnConfiguration *> *)configurations{
    __block BOOL success = NO;
    [self executeInTransaction:^(id<MDDReferenceDatabase> db, BOOL *rollback) {
        for (MDDColumn *column in columns) {
            MDDColumnConfiguration *configuration = configurations[[column propertyName]];
            NSString *description = [self columnDescriptionWithColumn:column configuration:configuration union:NO];
            description = [NSString stringWithFormat:@" %@ %@ ", MDDatabaseAddColumnCommand, description ?: @""];
            
            NSString *SQL = [NSString stringWithFormat:MDDatabaseAlterTableSQL, info.tableName, description];
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
    
    NSMutableArray<NSString *> *columnNames = [NSMutableArray array];
    [[self databaseQueue] inDatabase:^(id<MDDReferenceDatabase> database) {
        id<MDDReferenceDatabaseResultSet> set = [database executeQuery:SQL];
        
        int columnCount = sqlite3_column_count(set.statementData);
        for (int index = 0; index < columnCount; index++) {
            NSString *columnName = [NSString stringWithUTF8String:sqlite3_column_name(set.statementData, index)];
            
            [columnNames addObject:columnName];
        }
        [set close];
    }];
    return columnNames;
}

- (NSDictionary<NSString *, MDDLocalColumn *> *)localColumnsWithInfo:(MDDTableInfo *)info{
    NSString *SQL = [NSString stringWithFormat:MDDatabaseQueryTableInfoSQL, [info tableName]];
    
    __block NSDictionary<NSString *, MDDLocalColumn *> *columns = nil;
    [[self databaseQueue] inDatabase:^(id<MDDReferenceDatabase> database) {
        id<MDDReferenceDatabaseResultSet> set = [database executeQuery:SQL];
        while ([set next]) {
            columns = [MDDLocalColumn columnsWithSQL:[set objectForColumnIndex:0] tableInfo:info];
        }
        [set close];
    }];
    return columns;
}

- (NSArray<NSString *> *)descriptionsWithInfo:(MDDTableInfo *)info configurations:(NSDictionary<NSString *, MDDColumnConfiguration *> *)configurations command:(NSString *)command{
    NSMutableArray<NSString *> *descriptions = [NSMutableArray<NSString *> array];
    BOOL union_ = [[info primaryProperties] count] > 1;
    NSString *compositeKeyName = nil;
    
    for (MDDColumn *column in info.columns) {
        MDDColumnConfiguration *configuration = configurations[[column propertyName]];
        if (compositeKeyName && [configuration compositeKeyName] && [compositeKeyName isEqualToString:compositeKeyName]) {
            MDDLog(MDDLoggerLevelError, @"Can't define multiple compoiste key names %@.", compositeKeyName, [configuration compositeKeyName]); return nil;
        } else if ([configuration compositeKeyName]){
            compositeKeyName = [configuration compositeKeyName];
        }
            
        NSString *description = [self columnDescriptionWithColumn:column configuration:configuration union:union_];
        
        [descriptions addObject:[NSString stringWithFormat:@" %@ %@ ", command ?: @"", description ?: @""]];
    }
    if (!union_) return [descriptions copy];
    
    NSString *constraint = compositeKeyName ? [NSString stringWithFormat:@" CONSTRAINT %@", compositeKeyName] : @"";
    NSArray<NSString *> *columnNames = [[info propertyColumnMapper] objectsForKeys:[[info primaryProperties] allObjects] notFoundMarker:@""];
    
    [descriptions addObject:[NSString stringWithFormat:@" %@ PRIMARY KEY( %@ ) ", constraint, [columnNames componentsJoinedByString:@","]]];
    
    return [descriptions copy];
}

- (NSString *)columnDescriptionWithColumn:(MDDColumn *)column configuration:(MDDColumnConfiguration *)configuration union:(BOOL)union_;{
    configuration = configuration ?: [self defaultConfigurationForColumn:column];
    
    NSMutableString *description = [NSMutableString stringWithString:[column name]];
    [description appendFormat:@" %@", MDDColumnTypeDescription([column type]) ?: @"TEXT"];
    
    if ([configuration length]) {
        [description appendFormat:@"(%ld)", (long)[configuration length]];
    }
    
    if (!union_ && [column isPrimary]) {
        [description appendString:@" PRIMARY KEY "];
    }
    
    if (!union_ && [column isAutoincrement]) {
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

- (BOOL)_compatIndexesWithInfo:(MDDTableInfo *)info configuration:(MDDConfiguration *)configuration compat:(MDDCompat *)compat {
    NSArray<NSString *> *indexNames =  [info indexNames];
    NSArray<MDDIndex *> *indexes =  [info indexes];
    
    NSArray<MDDLocalIndex *> *localIndexes = [self _localIndexNamesWithInfo:info];
    
    NSMutableSet<MDDIndex *> *insertIndexes = [NSMutableSet set];
    NSMutableSet<MDDLocalIndex *> *deleteIndexes = [NSMutableSet set];
    
    for (MDDIndex *index in indexes) {
        index.tableInfo = info;
        
        MDDLocalIndex *localIndex = [self _localIndexWithName:[index name] indexes:localIndexes];
        if (!localIndex) {
            MDDCompatResult operation = [compat appendIndex:index];
            if (operation == MDDCompatResultIgnore) continue;
            
            [insertIndexes addObject:index];
        } else if (![[localIndex SQL] isEqualToString:[index creatingSQL]]) {
            MDDCompatResult operation = [compat alterLocalIndex:localIndex wtihIndex:index];
            if (operation == MDDCompatResultIgnore) continue;
            
            [insertIndexes addObject:index];
            [deleteIndexes addObject:localIndex];
        }
    }
    for (MDDLocalIndex *localIndex in localIndexes) {
        if ([indexNames containsObject:[localIndex name]]) continue;
        
        MDDCompatResult operation = [compat deleteLocalIndex:localIndex];
        if (operation == MDDCompatResultIgnore) continue;
        
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
    [self executeInTransaction:^(id<MDDReferenceDatabase> database, BOOL *rollback) {
        for (MDDIndex *index in indexes) {
            BOOL state = [database executeUpdate:[index creatingSQL]];
            *rollback = !state;
            if (!state) break;
        }
        success = !(*rollback);
    }];
    return success;
}

- (BOOL)_deleteLocalIndexes:(NSSet<MDDLocalIndex *> *)indexes{
    __block BOOL success = NO;
    [self executeInTransaction:^(id<MDDReferenceDatabase> database, BOOL *rollback) {
        for (MDDLocalIndex *index in indexes) {
            BOOL state = [database executeUpdate:[index droppingSQL]];
            
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
    NSMutableArray *indexes = [NSMutableArray array];
    [[self databaseQueue] inDatabase:^(id<MDDReferenceDatabase> database) {
        id<MDDReferenceDatabaseResultSet> set = [database executeQuery:[NSString stringWithFormat:MDDatabaseQueryIndexNameSQL, info.tableName]];
        while ([set next]) {
            NSString *name = [set objectForColumnIndex:[set columnIndexForName:@"name"]];
            NSString *SQL = [set objectForColumnIndex:[set columnIndexForName:@"sql"]];
            
            [indexes addObject:[MDDLocalIndex indexWithName:name tableName:[info tableName] SQL:SQL]];
        }
        [set close];
    }];
    return [indexes copy];
}

- (BOOL)_prepare{
    NSError *error = nil;
    for (Class<MDDObject> class in [[self tableClasses] allValues]) {
        BOOL state = [self _initialTableWithClass:class error:&error];
        if (!state) return NO;
    }
    return YES;
}

@end
