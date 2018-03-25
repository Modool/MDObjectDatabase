//
//  MDDLogger.h
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/25.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MDDatabaseCenter.h"

typedef NS_ENUM(NSUInteger, MDDLoggerLevel) {
    MDDLoggerLevelDebug,
    MDDLoggerLevelInfo,
    MDDLoggerLevelWarning,
    MDDLoggerLevelError,
};

@interface MDDLogger : NSObject

@property (nonatomic, assign, getter=isEnabled) BOOL enable;

- (void)log:(NSString *)format, ...;
- (void)logLevel:(MDDLoggerLevel)level format:(NSString *)format, ...;

@end

#define MDDLog(LEVEL, FMTS, ...)  [[[MDDatabaseCenter defaultCenter] logger] logLevel:LEVEL format:FMTS, ##__VA_ARGS__]
