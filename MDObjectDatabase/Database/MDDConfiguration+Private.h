//
//  MDDConfiguration+Private.h
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/25.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDConfiguration.h"

@interface MDDConfiguration ()

@property (nonatomic, copy, readonly) NSMutableDictionary<NSString *, MDDColumnConfiguration *> *columnConfigurations;

@end
