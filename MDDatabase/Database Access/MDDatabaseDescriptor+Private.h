//
//  MDDatabaseDescriptor+Private.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/30.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDatabaseDescriptor.h"

@interface MDDatabaseConditionSet (Private)

+ (MDDatabaseTokenDescription *)descriptionWithClass:(Class<MDDatabaseObject>)class conditionSet:(MDDatabaseConditionSet *)conditionSet tableInfo:(MDDatabaseTableInfo *)tableInfo;

@end

@interface MDDatabaseConditionDescriptor (Private)

+ (MDDatabaseTokenDescription *)descriptionWithClass:(Class<MDDatabaseObject>)class conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions tableInfo:(MDDatabaseTableInfo *)tableInfo;

@end

@interface MDDatabaseSetterDescriptor (Private)

+ (MDDatabaseTokenDescription *)descriptionWithClass:(Class<MDDatabaseObject>)class setters:(NSArray<MDDatabaseSetterDescriptor *> *)setters tableInfo:(MDDatabaseTableInfo *)tableInfo;

@end

@interface MDDatabaseSortDescriptor (Private)

+ (MDDatabaseTokenDescription *)descriptionWithClass:(Class<MDDatabaseObject>)class sorts:(NSArray<MDDatabaseSortDescriptor *> *)sorts tableInfo:(MDDatabaseTableInfo *)tableInfo;

@end

@interface MDDatabaseQueryDescriptor (Private)

+ (MDDatabaseTokenDescription *)descriptionWithClass:(Class<MDDatabaseObject>)class query:(MDDatabaseQueryDescriptor *)query range:(NSRange)range tableInfo:(MDDatabaseTableInfo *)tableInfo;

@end

@interface MDDatabaseUpdaterDescriptor (Private)

+ (MDDatabaseTokenDescription *)descriptionWithClass:(Class<MDDatabaseObject>)class updater:(MDDatabaseUpdaterDescriptor *)updater tableInfo:(MDDatabaseTableInfo *)tableInfo;

+ (MDDatabaseTokenDescription *)descriptionWithObject:(id<MDDatabaseObject>)object properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions tableInfo:(MDDatabaseTableInfo *)tableInfo;

@end

@interface MDDatabaseInserterDescriptor (Private)

+ (MDDatabaseTokenDescription *)descriptionWithClass:(Class<MDDatabaseObject>)class inserter:(MDDatabaseInserterDescriptor *)inserter tableInfo:(MDDatabaseTableInfo *)tableInfo;

+ (MDDatabaseInserterDescriptor *)inserterWithObject:(id<MDDatabaseObject>)object tableInfo:(MDDatabaseTableInfo *)tableInfo;
+ (MDDatabaseTokenDescription *)descriptionWithObject:(id<MDDatabaseObject>)object tableInfo:(MDDatabaseTableInfo *)tableInfo;

@end

@interface MDDatabaseDeleterDescriptor (Private)

+ (MDDatabaseTokenDescription *)descriptionWithClass:(Class<MDDatabaseObject>)class deleter:(MDDatabaseDeleterDescriptor *)deleter tableInfo:(MDDatabaseTableInfo *)tableInfo;

@end
