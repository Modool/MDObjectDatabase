//
//  MDDFunctionQuery.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDDAccessorConstants.h"

@class MDDConditionSet;
@interface MDDFunctionQuery : NSObject

@property (nonatomic, copy, readonly) NSString *key;
@property (nonatomic, copy, readonly) MDDFunction function;
@property (nonatomic, strong, readonly) MDDConditionSet *conditionSet;

+ (instancetype)functionQueryWithFunction:(MDDFunction)function conditionSet:(MDDConditionSet *)conditionSet;
+ (instancetype)functionQueryWithKey:(NSString *)key function:(MDDFunction)function conditionSet:(MDDConditionSet *)conditionSet;

+ (instancetype)sumQueryWithConditionSet:(MDDConditionSet *)conditionSet;
+ (instancetype)sumQueryWithKey:(NSString *)key conditionSet:(MDDConditionSet *)conditionSet;

@end

