//
//  MDDatabaseTableInfo.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/29.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDatabaseObject.h"

@class MDDatabaseColumn, MDDatabaseIndex, MDDatabaseConditionDescriptor;
@interface MDDatabaseTableInfo : NSObject

@property (nonatomic, copy, readonly) Class class;
@property (nonatomic, copy, readonly) NSString *tableName;

@property (nonatomic, copy, readonly) NSSet<NSString *> *primaryProperties;

@property (nonatomic, copy, readonly) NSArray<NSString *> *columnNames;
@property (nonatomic, copy, readonly) NSArray<MDDatabaseColumn *> *columns;

@property (nonatomic, copy, readonly) NSArray<NSString *> *indexNames;
@property (nonatomic, copy, readonly) NSArray<MDDatabaseIndex *> *indexes;

+ (instancetype)infoWithTableName:(NSString *)tableName class:(Class)class error:(NSError **)error;

- (MDDatabaseColumn *)columnForKey:(id)key;
- (MDDatabaseIndex *)indexForKeys:(NSSet<NSString *> *)keys;
- (MDDatabaseIndex *)indexForConditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;

@end
