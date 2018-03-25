//
//  MDDatabase.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/12/1.
//  Copyright © 2017年 modool. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MDDObject;
@class MDDTableInfo, MDDConfiguration, MDDCompat;
@interface MDDatabase : NSObject

@property (nonatomic, copy, readonly) NSString *filepath;

+ (instancetype)databaseWithFilepath:(NSString *)filepath;
- (instancetype)initWithFilepath:(NSString *)filepath;

- (MDDTableInfo *)requireTableInfoWithClass:(Class<MDDObject>)class error:(NSError **)error;
- (BOOL)existTableForClass:(Class<MDDObject>)class;
- (void)close;

- (MDDCompat *)addConfiguration:(MDDConfiguration *)configuration error:(NSError **)error;

@end
