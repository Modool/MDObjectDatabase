//
//  MDDCompat.h
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/25.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MDDCompatOperation) {
    MDDCompatOperationNone,
    MDDCompatOperationAdd,
    MDDCompatOperationAlter,
    MDDCompatOperationDelete,
};

typedef NS_ENUM(NSUInteger, MDDCompatResult) {
    MDDCompatResultIgnore,
    MDDCompatResultContinue,
};

@class MDDLocalColumn, MDDColumn, MDDLocalIndex, MDDIndex, MDDLocalView, MDDViewInfo;
@interface MDDCompat : NSObject

+ (instancetype)compat;

- (void)bindColumnIncrement:(MDDCompatResult (^)(MDDCompatOperation operation, MDDLocalColumn *localColumn, MDDColumn *column))increment;

- (void)bindIndexIncrement:(MDDCompatResult (^)(MDDCompatOperation operation, MDDLocalIndex *localIndex, MDDIndex *index))increment;

- (void)bindViewIncrement:(MDDCompatResult (^)(MDDCompatOperation operation, MDDLocalView *localView, MDDViewInfo *view))increment;

@end
