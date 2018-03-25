
//
//  MDDCompat+Private.h
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/25.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDCompat.h"

@class MDDColumn, MDDLocalColumn, MDDIndex, MDDLocalIndex;
@interface MDDCompat ()

@property (nonatomic, copy) MDDCompatResult (^columnIncrement)(MDDCompatOperation operation, MDDLocalColumn *localColumn, MDDColumn *column);
@property (nonatomic, copy) MDDCompatResult (^indexIncrement)(MDDCompatOperation operation, MDDLocalIndex *localIndex, MDDIndex *index);

- (MDDCompatResult)replaceLocalColumn:(MDDLocalColumn *)localColumn wtihColumn:(MDDColumn *)column;
- (MDDCompatResult)deleteLocalColumn:(MDDLocalColumn *)localColumn;
- (MDDCompatResult)appendColumn:(MDDColumn *)column;

- (MDDCompatResult)replaceLocalIndex:(MDDLocalIndex *)localIndex wtihIndex:(MDDIndex *)index;
- (MDDCompatResult)deleteLocalIndex:(MDDLocalIndex *)localIndex;
- (MDDCompatResult)appendIndex:(MDDIndex *)index;

@end
