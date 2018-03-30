//
//  MDDConditionSet+Private.h
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/26.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDConditionSet.h"

@interface MDDConditionSet ()

@property (nonatomic, assign, readonly, getter=isMultipleTable) BOOL multipleTable;

@property (nonatomic, assign) MDDConditionOperation operation;

@property (nonatomic, strong) NSMutableSet<MDDConditionSet *> *mutableSets;

@property (nonatomic, strong) NSMutableSet<MDDCondition *> *mutableConditions;

@property (nonatomic, strong) NSMutableSet<MDDTableInfo *> *mutableTableInfos;

@end
