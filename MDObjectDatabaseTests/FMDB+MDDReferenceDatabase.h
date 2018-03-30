//
//  FMDB+MDDReferenceDatabase.h
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/29.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <FMDB/FMDB.h>
#import <MDObjectDatabase/MDObjectDatabase.h>

@interface FMDatabaseQueue (MDDReferenceDatabase) <MDDReferenceDatabaseQueue>
@end

@interface FMDatabase (MDDReferenceDatabase) <MDDReferenceDatabase>
@end

@interface FMResultSet (MDDReferenceDatabase) <MDDReferenceDatabaseResultSet>
@end
