//
//  MDDColumn+Private.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/30.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDColumn.h"
#import "MDDMacros.h"

MDD_EXTERN NSString * const MDDObjectObjectIDName;

@interface MDDColumn ()

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *propertyName;

@property (nonatomic, assign, getter=isPrimary) BOOL primary;

@property (nonatomic, assign, getter=isAutoincrement) BOOL autoincrement;

@property (nonatomic, assign) MDDColumnType type;

@property (nonatomic, strong) MDPropertyAttributes *attribute;

@end
