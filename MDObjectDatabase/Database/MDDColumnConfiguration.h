//
//  MDDColumnConfiguration.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/30.
//  Copyright © 2017年 modool. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MDDColumn;
@interface MDDColumnConfiguration : NSObject

@property (nonatomic, assign, readonly, getter=isPrimary) BOOL primary;

@property (nonatomic, assign, getter=isNullabled) BOOL nullabled;

@property (nonatomic, assign, getter=isUnique) BOOL unique;

@property (nonatomic, strong) id checkValue;

@property (nonatomic, strong) id defaultValue;

@property (nonatomic, assign) NSUInteger length;

+ (instancetype)defaultConfigurationWithColumn:(MDDColumn *)column;

@end
