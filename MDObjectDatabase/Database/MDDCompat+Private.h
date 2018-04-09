
//
//  MDDCompat+Private.h
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/25.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDCompat.h"

@class MDDColumn, MDDLocalColumn, MDDIndex, MDDLocalIndex, MDDLocalView, MDDViewInfo;
@interface MDDCompat ()

@property (nonatomic, copy) MDDCompatResult (^columnIncrement)(MDDCompatOperation operation, MDDLocalColumn *localColumn, MDDColumn *column);
@property (nonatomic, copy) MDDCompatResult (^indexIncrement)(MDDCompatOperation operation, MDDLocalIndex *localIndex, MDDIndex *index);
@property (nonatomic, copy) MDDCompatResult (^viewIncrement)(MDDCompatOperation operation, MDDLocalView *localView, MDDViewInfo *view);

- (MDDCompatResult)appendColumn:(MDDColumn *)column;

- (MDDCompatResult)alterLocalIndex:(MDDLocalIndex *)localIndex wtihIndex:(MDDIndex *)index;
- (MDDCompatResult)deleteLocalIndex:(MDDLocalIndex *)localIndex;
- (MDDCompatResult)appendIndex:(MDDIndex *)index;

@end
