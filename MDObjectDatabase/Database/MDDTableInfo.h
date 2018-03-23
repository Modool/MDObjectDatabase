//
//  MDDTableInfo.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/29.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDObject.h"

@class MDDColumn, MDDIndex, MDDConditionSet;
@interface MDDTableInfo : NSObject

@property (nonatomic, copy, readonly) Class class;
@property (nonatomic, copy, readonly) NSString *tableName;

@property (nonatomic, copy, readonly) NSSet<NSString *> *primaryProperties;

@property (nonatomic, copy, readonly) NSArray<NSString *> *columnNames;
@property (nonatomic, copy, readonly) NSArray<MDDColumn *> *columns;

@property (nonatomic, copy, readonly) NSArray<NSString *> *indexNames;
@property (nonatomic, copy, readonly) NSArray<MDDIndex *> *indexes;

+ (instancetype)infoWithTableName:(NSString *)tableName class:(Class)class error:(NSError **)error;

- (MDDColumn *)columnForKey:(id)key;
- (MDDIndex *)indexForKeys:(NSSet<NSString *> *)keys;
- (MDDIndex *)indexForConditionSet:(MDDConditionSet *)conditionSet;

@end
