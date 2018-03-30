//
//  MDDDescriptor.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/29.
//  Copyright © 2017年 modool. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MDDTableInfo, MDDDescription;
@interface MDDDescriptor : NSObject

@property (nonatomic, strong, readonly) MDDTableInfo *tableInfo;

@property (nonatomic, strong, readonly) MDDDescription *SQLDescription;

+ (instancetype)descriptorWithTableInfo:(MDDTableInfo *)tableInfo;
- (instancetype)initWithTableInfo:(MDDTableInfo *)tableInfo NS_DESIGNATED_INITIALIZER;

@end

