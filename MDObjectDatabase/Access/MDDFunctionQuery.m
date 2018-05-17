//
//  MDDFunctionQuery.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDFunctionQuery.h"
#import "MDDQuery+Private.h"
#import "MDDItem.h"
#import "MDDRange.h"
#import "MDDDescription.h"

@implementation MDDFunctionQuery

+ (instancetype)functionQueryWithTableInfo:(id<MDDTableInfo>)tableInfo property:(MDDFuntionProperty *)property;{
    return [self functionQueryWithTableInfo:tableInfo property:property alias:nil];
}

+ (instancetype)functionQueryWithTableInfo:(id<MDDTableInfo>)tableInfo property:(MDDFuntionProperty *)property alias:(NSString *)alias;{
    MDDFunctionQuery *query = [self descriptorWithTableInfo:tableInfo];
    query.properties = (id)[NSSet setWithObject:property];
    query.alias = alias;
    query.transform = ^id(NSDictionary *result) {
        return property.alias ? result[property.alias] : result;
    };
    
    return query;
}

- (MDDDescription *)SQLDescription{
    MDDDescription *description = [super SQLDescription];
    if (_alias) return [MDDDescription descriptionWithSQL:[NSString stringWithFormat:@" ( %@ ) AS %@", [description SQL], _alias] values:[description values]];
    return description;
}

@end

