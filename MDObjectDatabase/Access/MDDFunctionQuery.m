//
//  MDDFunctionQuery.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDFunctionQuery.h"
#import "MDDAccessorConstants.h"

@implementation MDDFunctionQuery

+ (instancetype)functionQueryWithFunction:(NSString *)function conditionSet:(MDDConditionSet *)conditionSet;{
    return [self functionQueryWithKey:nil function:function conditionSet:conditionSet];
}

+ (instancetype)functionQueryWithKey:(NSString *)key function:(NSString *)function conditionSet:(MDDConditionSet *)conditionSet;{
    MDDFunctionQuery *query = [[self alloc] init];
    query->_key = [key copy];
    query->_function = [function copy];
    query->_conditionSet = conditionSet;
    
    return query;
}

+ (instancetype)sumQueryWithConditionSet:(MDDConditionSet *)conditionSet;{
    return [self sumQueryWithKey:nil conditionSet:conditionSet];
}

+ (instancetype)sumQueryWithKey:(NSString *)key conditionSet:(MDDConditionSet *)conditionSet;{
    return [self functionQueryWithKey:key function:MDDFunctionSUM conditionSet:conditionSet];
}

@end

