
//
//  MDDSort.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDSort.h"
#import "MDDTableInfo.h"
#import "MDDColumn.h"
#import "MDDDescription.h"

@implementation MDDSort

+ (instancetype)sortWithTableInfo:(MDDTableInfo *)tableInfo property:(id<MDDItem>)property ascending:(BOOL)ascending;{
    MDDSort *sort = [super descriptorWithTableInfo:tableInfo property:property value:nil];
    sort->_ascending = ascending;
    
    return sort;
}

- (NSString *)description{
    return [[self dictionaryWithValuesForKeys:@[@"property", @"ascending"]] description];
}

- (MDDDescription *)SQLDescription{
    MDDColumn *column = [self.tableInfo columnForProperty:[self property]];
    NSParameterAssert(column);
    
    NSString *SQL = [NSString stringWithFormat:@"%@ %@", [column name], [self ascending] ? @"ASC" : @"DESC"];
    return [MDDDescription descriptionWithSQL:SQL values:nil];
}

+ (MDDDescription *)descriptionWithSorts:(NSArray<MDDSort *> *)sorts{
    return [super descriptionWithDescriptors:sorts separator:@" , "];
}

@end

