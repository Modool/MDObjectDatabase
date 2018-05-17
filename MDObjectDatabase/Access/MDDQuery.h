//
//  MDDQuery.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDDescriptor.h"

@protocol MDDItem, MDDObject;
@class MDDSort, MDDConditionSet, MDDSet, MDDItem;
@interface MDDQuery : MDDDescriptor

@property (nonatomic, strong) MDDSet *set;
@property (nonatomic, strong) MDDConditionSet *conditionSet;
@property (nonatomic, assign) NSRange range;

@property (nonatomic, copy) NSSet<MDDItem *> *properties;
@property (nonatomic, copy) NSArray<MDDSort *> *sorts;

@property (nonatomic, copy) id (^transform)(NSDictionary *result);

+ (instancetype)queryWithTableInfo:(id<MDDTableInfo>)tableInfo objectClass:(Class<MDDObject>)objectClass;

@end

