//
//  MDDTokenDescription.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDDTokenDescription : NSObject

@property (nonatomic, copy, readonly) NSString *tokenString; // Token with ?

@property (nonatomic, copy, readonly) NSArray *values;

@property (nonatomic, copy, readonly) NSString *normalizeDescription;  // Token with value

+ (instancetype)descriptionWithTokenString:(NSString *)tokenString values:(NSArray *)values;

@end

