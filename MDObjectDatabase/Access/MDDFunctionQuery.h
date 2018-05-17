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

@property (nonatomic, copy) NSString *alias;

+ (instancetype)functionQueryWithTableInfo:(id<MDDTableInfo>)tableInfo property:(MDDFuntionProperty *)property;
+ (instancetype)functionQueryWithTableInfo:(id<MDDTableInfo>)tableInfo property:(MDDFuntionProperty *)property alias:(NSString *)alias;

@end

