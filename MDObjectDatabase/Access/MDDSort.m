
//
//  MDDSort.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDSort.h"
#import "MDDDescriptor+Private.h"

#import "MDDTableInfo.h"
#import "MDDColumn.h"
#import "MDDTokenDescription.h"

@implementation MDDSort

+ (instancetype)sortWithKey:(NSString *)key ascending:(BOOL)ascending;{
    return [[self alloc] initWithKey:key ascending:ascending];
}

- (instancetype)initWithKey:(NSString *)key ascending:(BOOL)ascending;{
    if (self = [super initWithKey:key value:nil]) {
        _ascending = ascending;
    }
    return self;
}

- (NSString *)descriptionWithTableInfo:(MDDTableInfo *)tableInfo value:(id *)value{
    NSParameterAssert(tableInfo);
    
    MDDColumn *column = [tableInfo columnForKey:[self key]];
    NSParameterAssert(column);
    
    return [NSString stringWithFormat:@"%@ %@", [column name], [self ascending] ? @"ASC" : @"DESC"];
}

@end

