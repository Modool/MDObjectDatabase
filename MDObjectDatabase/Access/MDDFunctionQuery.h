//
//  MDDFunctionQuery.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDQuery.h"

@class MDDFuntionProperty;
@interface MDDFunctionQuery : MDDQuery

@property (nonatomic, copy, readonly) NSString *alias;

+ (instancetype)fuctionQueryWithProperty:(MDDFuntionProperty *)property;
+ (instancetype)fuctionQueryWithProperty:(MDDFuntionProperty *)property conditionSet:(MDDConditionSet *)conditionSet;
+ (instancetype)fuctionQueryWithProperty:(MDDFuntionProperty *)property set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet;

+ (instancetype)fuctionQueryWithProperty:(MDDFuntionProperty *)property alias:(NSString *)alias;
+ (instancetype)fuctionQueryWithProperty:(MDDFuntionProperty *)property conditionSet:(MDDConditionSet *)conditionSet alias:(NSString *)alias;
+ (instancetype)fuctionQueryWithProperty:(MDDFuntionProperty *)property set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet alias:(NSString *)alias;

@end

