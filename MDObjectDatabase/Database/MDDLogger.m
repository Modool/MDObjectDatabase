//
//  MDDLogger.m
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/25.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDLogger.h"

@implementation MDDLogger

- (void)log:(NSString *)format, ...{
    if (!self.enable) return;
    
    va_list list;
    va_list copiedList;
    va_start(list, format);
    va_copy(copiedList, list);
    va_end(list);
    
    [self logLevel:MDDLoggerLevelDebug format:format args:copiedList];
}

- (void)logLevel:(MDDLoggerLevel)level format:(NSString *)format, ...{
    if (!self.enable) return;
    
    va_list list;
    va_list copiedList;
    va_start(list, format);
    va_copy(copiedList, list);
    va_end(list);
    
    [self logLevel:level format:format args:copiedList];
}

- (void)logLevel:(MDDLoggerLevel)level format:(NSString *)format args:(va_list)args{
    if (!self.enable) return;
    static NSDictionary *levelDescriptions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        levelDescriptions = @{@(MDDLoggerLevelDebug): @"DEBUG",
                              @(MDDLoggerLevelInfo): @"INFO",
                              @(MDDLoggerLevelWarning): @"WARNING",
                              @(MDDLoggerLevelError): @"ERROR"};
    });
    
    format = [NSString stringWithFormat:@"%@: %@", levelDescriptions[@(level)], format];

    if ([NSThread isMainThread]) {
        NSLogv(format, args);
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLogv(format, args);
        });
    }
}

@end
