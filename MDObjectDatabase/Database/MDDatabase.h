//
//  MDDatabase.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/12/1.
//  Copyright © 2017年 modool. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MDDTableInfo;
@protocol MDDObject;
@interface MDDatabase : NSObject

+ (instancetype)databaseWithFilepath:(NSString *)filepath;

- (void)attachTableIfNeedsWithClass:(Class<MDDObject>)class;

- (BOOL)containedTableWithClass:(Class<MDDObject>)class;

- (MDDTableInfo *)requireTableInfoWithClass:(Class<MDDObject>)class;

- (void)close;

@end
