//
//  MDDDescriptor.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/29.
//  Copyright © 2017年 modool. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MDDTableInfo;
@class MDDDescription;
@interface MDDDescriptor : NSObject

@property (nonatomic, strong, readonly) id<MDDTableInfo> tableInfo;

@property (nonatomic, strong, readonly) MDDDescription *SQLDescription;

+ (instancetype)descriptorWithTableInfo:(id<MDDTableInfo>)tableInfo;
- (instancetype)initWithTableInfo:(id<MDDTableInfo>)tableInfo NS_DESIGNATED_INITIALIZER;

@end

