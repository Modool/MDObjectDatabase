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

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *propertyName;

@property (nonatomic, assign, getter=isPrimary) BOOL primary;

@property (nonatomic, assign, getter=isAutoincrement) BOOL autoincrement;

@property (nonatomic, assign) MDDColumnType type;

@property (nonatomic, strong) MDPropertyAttributes *attribute;

@property (nonatomic, strong) MDDColumnConfiguration *configuration;

- (BOOL)isEqualLocalColumn:(MDDLocalColumn *)localColumn;

@end

@class MDDTableInfo;
@interface MDDLocalColumn ()

+ (instancetype)columnWithName:(NSString *)name primary:(BOOL)primary autoincrement:(BOOL)autoincrement type:(MDDColumnType)type;

+ (NSDictionary<NSString *, MDDLocalColumn *> *)columnsWithSQL:(NSString *)SQL tableInfo:(MDDTableInfo *)tableInfo;

@end

MDD_EXTERN MDDColumnType MDDColumnTypeFromDescription(NSString *description);
MDD_EXTERN NSString *MDDColumnTypeDescription(MDDColumnType type);
