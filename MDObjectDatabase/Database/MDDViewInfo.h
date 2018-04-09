//
//  MDDViewInfo.h
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/30.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDTableInfo.h"

@class MDDViewConfiguration, MDDColumn, MDDConditionSet;
@interface MDDViewInfo : NSObject <MDDTableInfo>

@property (nonatomic, strong, readonly) MDDConditionSet *conditionSet;

+ (instancetype)infoWithConfiguration:(MDDViewConfiguration *)configuration error:(NSError **)error;

- (MDDColumn *)columnForProperty:(NSString *)property;

@end

@interface MDDLocalView : MDDViewInfo

@end
