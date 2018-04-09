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

+ (instancetype)fuctionQueryWithProperty:(MDDFuntionProperty *)property;{
    return [self fuctionQueryWithProperty:property conditionSet:nil];
}

+ (instancetype)fuctionQueryWithProperty:(MDDFuntionProperty *)property conditionSet:(MDDConditionSet *)conditionSet;{
    return [self fuctionQueryWithProperty:property set:nil conditionSet:conditionSet];
}

+ (instancetype)fuctionQueryWithProperty:(MDDFuntionProperty *)property set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet;{
    return [self fuctionQueryWithProperty:property set:set conditionSet:conditionSet alias:nil];
}

+ (instancetype)fuctionQueryWithProperty:(MDDFuntionProperty *)property alias:(NSString *)alias;{
    return [self fuctionQueryWithProperty:property conditionSet:nil alias:alias];
}

+ (instancetype)fuctionQueryWithProperty:(MDDFuntionProperty *)property conditionSet:(MDDConditionSet *)conditionSet alias:(NSString *)alias;{
    return [self fuctionQueryWithProperty:property set:nil conditionSet:conditionSet alias:alias];
}

+ (instancetype)fuctionQueryWithProperty:(MDDFuntionProperty *)property set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet alias:(NSString *)alias;{
    MDDFunctionQuery *query = [self queryWithPropertys:(id)[NSSet setWithObject:property] set:set conditionSet:conditionSet sorts:nil range:NSRangeZore transform:^id(NSDictionary *result) {
        return property.alias ? result[property.alias] : result;
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

