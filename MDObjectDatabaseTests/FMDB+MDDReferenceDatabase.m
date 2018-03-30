//
//  FMDB+MDDReferenceDatabase.m
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/29.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "FMDB+MDDReferenceDatabase.h"

@implementation FMDatabaseQueue (MDDReferenceDatabase)
@end

@implementation FMDatabase (MDDReferenceDatabase)
@end

@implementation FMResultSet (MDDReferenceDatabase)

- (void *)statementData{
    return [[self statement] statement];
}

@end
