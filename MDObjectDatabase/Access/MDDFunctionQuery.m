//
//  MDDFunctionQuery.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDFunctionQuery.h"
#import "MDDQuery+Private.h"
#import "MDDItem.h"
#import "MDDRange.h"
#import "MDDDescription.h"

@implementation MDDFunctionQuery

+ (instancetype)fuctionQueryWithKey:(MDDFuntionKey *)key;{
    return [self fuctionQueryWithKey:key conditionSet:nil];
}

+ (instancetype)fuctionQueryWithKey:(MDDFuntionKey *)key conditionSet:(MDDConditionSet *)conditionSet;{
    return [self fuctionQueryWithKey:key set:nil conditionSet:conditionSet];
}

+ (instancetype)fuctionQueryWithKey:(MDDFuntionKey *)key set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet;{
    return [self fuctionQueryWithKey:key set:set conditionSet:conditionSet alias:nil];
}

+ (instancetype)fuctionQueryWithKey:(MDDFuntionKey *)key alias:(NSString *)alias;{
    return [self fuctionQueryWithKey:key conditionSet:nil alias:alias];
}

+ (instancetype)fuctionQueryWithKey:(MDDFuntionKey *)key conditionSet:(MDDConditionSet *)conditionSet alias:(NSString *)alias;{
    return [self fuctionQueryWithKey:key set:nil conditionSet:conditionSet alias:alias];
}

+ (instancetype)fuctionQueryWithKey:(MDDFuntionKey *)key set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet alias:(NSString *)alias;{
    MDDFunctionQuery *query = [self queryWithKeys:(id)[NSSet setWithObject:key] set:set conditionSet:conditionSet sorts:nil range:NSRangeZore transform:^id(NSDictionary *result) {
        return key.alias ? result[key.alias] : result;
    }];
    query->_alias = alias;
    
    return query;
}

- (MDDDescription *)SQLDescription{
    MDDDescription *description = [super SQLDescription];
    if (_alias) return [MDDDescription descriptionWithSQL:[NSString stringWithFormat:@" ( %@ ) AS %@", [description SQL], _alias] values:[description values]];
    return description;
}

@end

