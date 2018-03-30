//
//  MDDQuery+Private.h
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/27.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDQuery.h"

@interface MDDQuery ()

@property (nonatomic, copy, readonly) id (^transform)(NSDictionary *result);

- (id)transformValue:(NSDictionary *)value;

@end

