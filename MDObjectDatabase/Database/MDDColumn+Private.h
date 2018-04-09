//
//  MDDColumn+Private.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/30.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDColumn.h"
#import "MDDMacros.h"

@class MDDColumnConfiguration;
@interface MDDColumn ()

@property (nonatomic, assign) MDDColumnType type;
@property (nonatomic, strong) MDDColumnConfiguration *configuration;

@property (nonatomic, strong, readonly) MDPropertyAttributes *attribute;

- (BOOL)isEqualLocalColumn:(MDDLocalColumn *)localColumn;

@end

@protocol MDDTableInfo;
@interface MDDLocalColumn ()

+ (instancetype)columnWithName:(NSString *)name primary:(BOOL)primary autoincrement:(BOOL)autoincrement type:(MDDColumnType)type tableInfo:(id<MDDTableInfo>)tableInfo;

+ (NSDictionary<NSString *, MDDLocalColumn *> *)columnsWithSQL:(NSString *)SQL tableInfo:(id<MDDTableInfo>)tableInfo;

@end

MDD_EXTERN MDDColumnType MDDColumnTypeFromDescription(NSString *description);
MDD_EXTERN NSString *MDDColumnTypeDescription(MDDColumnType type);
