//
//  MDDFunctionQuery.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDQuery.h"

@class MDDFuntionKey;
@interface MDDFunctionQuery : MDDQuery

@property (nonatomic, copy, readonly) NSString *alias;

+ (instancetype)fuctionQueryWithKey:(MDDFuntionKey *)key;
+ (instancetype)fuctionQueryWithKey:(MDDFuntionKey *)key conditionSet:(MDDConditionSet *)conditionSet;
+ (instancetype)fuctionQueryWithKey:(MDDFuntionKey *)key set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet;

+ (instancetype)fuctionQueryWithKey:(MDDFuntionKey *)key alias:(NSString *)alias;
+ (instancetype)fuctionQueryWithKey:(MDDFuntionKey *)key conditionSet:(MDDConditionSet *)conditionSet alias:(NSString *)alias;
+ (instancetype)fuctionQueryWithKey:(MDDFuntionKey *)key set:(MDDSet *)set conditionSet:(MDDConditionSet *)conditionSet alias:(NSString *)alias;

@end

