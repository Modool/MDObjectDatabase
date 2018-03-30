//
//  MDDDescription.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDDDescription : NSObject

@property (nonatomic, copy, readonly) NSString *SQL; // Token with ?

@property (nonatomic, copy, readonly) NSArray *values;

@property (nonatomic, copy, readonly) NSString *normalizedSQL;  // Token with value

+ (instancetype)descriptionWithSQL:(NSString *)SQL;
+ (instancetype)descriptionWithSQL:(NSString *)SQL values:(NSArray *)values;

@end

