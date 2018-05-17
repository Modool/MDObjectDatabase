//
//  MDDQuery.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDQuery.h"
#import "MDDQuery+Private.h"
#import "MDDColumn.h"
#import "MDDTableInfo.h"
#import "MDDIndex.h"
#import "MDDItem.h"
#import "MDDDescription.h"
#import "MDDRange.h"
#import "MDDSort.h"
#import "MDDConditionSet+Private.h"

@implementation MDDQuery
@dynamic tableInfo;

+ (instancetype)queryWithTableInfo:(id<MDDTableInfo>)tableInfo objectClass:(Class<MDDObject>)objectClass;{
    MDDQuery *query = [self descriptorWithTableInfo:tableInfo];
    query.transform = ^id(NSDictionary *result) {
        return [objectClass objectWithDictionary:result];
    };
    
    return query;
}

- (id)transformValue:(NSDictionary *)value;{
    if (_transform) return _transform(value);
    
    return value;
}

- (id<MDDTableInfo>)tableInfo{
    return [super tableInfo] ?: [[self conditionSet] tableInfo];
}

- (NSString *)description{
    return [[self dictionaryWithValuesForKeys:@[@"tableInfo", @"set", @"conditionSet", @"range", @"property", @"sorts"]] description];
}

#pragma mark - accessor

- (MDDDescription *)SQLDescription{
    NSMutableArray *values = [NSMutableArray array];
    NSMutableArray<NSString *> *columns = [NSMutableArray<NSString *> array];
    
    NSMutableSet<MDDTableInfo> *tableInfos = [NSMutableSet<MDDTableInfo> set];
    [tableInfos unionSet:[[self conditionSet] mutableTableInfos]];
    
    for (MDDItem *property in [self properties]) {
        MDDDescription *description = [property SQLDescription];
        if ([property tableInfo]) [tableInfos addObject:[property tableInfo]];
        
        [columns addObject:[description SQL]];
        [values addObjectsFromArray:[description values]];
    }
    
    NSString *property = [columns componentsJoinedByString:@", "];
    property = [property length] ? property : @" * ";
    
    MDDIndex *index = [[self conditionSet] index];
    NSString *indexString = index ? [NSString stringWithFormat:@" INDEXED BY %@ ", [index name]] : @"";
    
    MDDDescription *description = [[self set] SQLDescription];
    NSString *tableSet = nil;
    if (description) {
        tableSet = [description SQL];
        [values addObjectsFromArray:[description values]];
    } else {
        tableSet = [[[tableInfos allObjects] valueForKey:@MDDKeyPath(MDDTableInfo, name)] componentsJoinedByString:@" , "];
    }
    NSMutableString *SQL = [NSMutableString stringWithFormat:@" SELECT %@ FROM %@ %@ ", property, tableSet, indexString];
    
    if (self.set) description = [[self conditionSet] SQLDescriptionInSet:self.set];
    else description = [[self conditionSet] SQLDescription];
     
    if ([description SQL]) {
        [SQL appendFormat:@" WHERE %@ ", [description SQL]];
        [values addObjectsFromArray:description.values];
    }
    
    description = [MDDSort descriptionWithSorts:[self sorts]];
    if ([description SQL]) {
        [SQL appendFormat:@" ORDER BY %@ ", [description SQL] ?: @""];
    }
    
    NSRange range = [self range];
    if (range.location || range.length) {
        range.length = range.length ?: INT_MAX;
        [SQL appendFormat:@" LIMIT %lu OFFSET %ld ", (unsigned long)range.length, (unsigned long)range.location];
    }
    
    return [MDDDescription descriptionWithSQL:SQL values:values];
}

@end
