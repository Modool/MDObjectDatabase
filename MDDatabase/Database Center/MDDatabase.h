//
//  MDDatabase.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/12/1.
//  Copyright © 2017年 modool. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MDDatabaseTableInfo;
@protocol MDDatabaseObject;
@interface MDDatabase : NSObject

@property (nonatomic, copy, readonly) NSString *UID;

+ (instancetype)databaseWithFilepath:(NSString *)filepath UID:(NSString *)UID;

- (void)attachTableIfNeedsWithClass:(Class<MDDatabaseObject>)class;

- (BOOL)containedTableWithClass:(Class<MDDatabaseObject>)class;

- (MDDatabaseTableInfo *)requireTableInfoWithClass:(Class<MDDatabaseObject>)class;

- (void)close;

@end
