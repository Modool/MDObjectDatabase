//
//  MDDCompat.m
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/25.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDCompat.h"
#import "MDDCompat+Private.h"
#import "MDDLogger.h"

#import "MDDColumn.h"
#import "MDDIndex.h"

@implementation MDDCompat

+ (instancetype)compat;{
    return [[self alloc] init];
}

- (MDDCompatResult)alterLocalColumn:(MDDLocalColumn *)localColumn wtihColumn:(MDDColumn *)column;{
    if (_columnIncrement) return _columnIncrement(MDDCompatOperationAlter, localColumn, column);

    MDDLog(MDDLoggerLevelWarning, @"There isn't any compat to replace local column: %@ with column: %@", localColumn.name, column.name);
    return MDDCompatResultContinue;
}

- (MDDCompatResult)deleteLocalColumn:(MDDLocalColumn *)localColumn;{
    if (_columnIncrement) return _columnIncrement(MDDCompatOperationDelete, localColumn, nil);
    
    MDDLog(MDDLoggerLevelWarning, @"There isn't any compat to delete local column: %@", localColumn.name);
    return MDDCompatResultIgnore;
}

- (MDDCompatResult)appendColumn:(MDDColumn *)column;{
    if (_columnIncrement) return _columnIncrement(MDDCompatOperationAdd, nil, column);
    
    MDDLog(MDDLoggerLevelWarning, @"There isn't any compat to append column: %@", column.name);
    return MDDCompatResultContinue;
}

- (MDDCompatResult)alterLocalIndex:(MDDLocalIndex *)localIndex wtihIndex:(MDDIndex *)index;{
    if (_indexIncrement) return _indexIncrement(MDDCompatOperationAlter, localIndex, index);
    return MDDCompatResultContinue;
}

- (MDDCompatResult)deleteLocalIndex:(MDDLocalIndex *)localIndex;{
    if (_indexIncrement) return _indexIncrement(MDDCompatOperationDelete, localIndex, nil);
    
    MDDLog(MDDLoggerLevelWarning, @"There isn't any compat to delete local index: %@", localIndex.name);
    return MDDCompatResultContinue;
}

- (MDDCompatResult)appendIndex:(MDDIndex *)index;{
    if (_indexIncrement) return _indexIncrement(MDDCompatOperationAdd, nil, index);
    
    MDDLog(MDDLoggerLevelWarning, @"There isn't any compat to append index: %@", index.name);
    return MDDCompatResultContinue;
}

- (void)bindColumnIncrement:(MDDCompatResult (^)(MDDCompatOperation operation, MDDLocalColumn *localColumn, MDDColumn *column))increment;{
    NSParameterAssert(increment);
    
    self.columnIncrement = increment;
}

- (void)bindIndexIncrement:(MDDCompatResult (^)(MDDCompatOperation operation, MDDLocalIndex *localIndex, MDDIndex *index))increment;{
    NSParameterAssert(increment);
    
    self.indexIncrement = increment;
}

- (void)bindViewIncrement:(MDDCompatResult (^)(MDDCompatOperation operation, MDDLocalView *localView, MDDViewInfo *view))increment;{
    
}

@end
