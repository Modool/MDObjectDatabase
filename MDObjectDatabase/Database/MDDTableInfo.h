//
//  MDDTableInfo.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/29.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDObject.h"

@protocol MDDItem;
@class MDDColumn, MDDIndex, MDDConditionSet, MDDTableConfiguration;
@protocol MDDTableInfo <NSObject>

@property (nonatomic, copy, readonly) Class objectClass;
@property (nonatomic, copy, readonly) NSString *name;

@property (nonatomic, copy, readonly) NSArray<NSString *> *columnNames;
@property (nonatomic, copy, readonly) NSArray<MDDColumn *> *columns;

@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *propertyColumnMapper;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *columnPropertyMapper;

- (MDDColumn *)columnForProperty:(id)property;

@optional
@property (nonatomic, copy, readonly) NSSet<NSString *> *primaryProperties;

- (MDDIndex *)indexForPropertys:(NSSet<NSString *> *)property;
- (MDDIndex *)indexForConditionSet:(MDDConditionSet *)conditionSet;

@end

@interface MDDTableInfo : NSObject <MDDTableInfo>

@property (nonatomic, copy, readonly) NSArray<NSString *> *indexNames;
@property (nonatomic, copy, readonly) NSArray<MDDIndex *> *indexes;

+ (instancetype)infoWithConfiguration:(MDDTableConfiguration *)configuration error:(NSError **)error;

@end
