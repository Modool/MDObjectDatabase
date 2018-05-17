//
//  MDDLogger.m
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/25.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDLogger.h"

#define dispatch_main_async_safe(block)     \
{   if ([NSThread isMainThread]) block();   \
    else dispatch_async(dispatch_get_main_queue(), block);  \
}

@implementation MDDLogger

- (void)log:(NSString *)format, ...{
    if (!self.enable) return;
    
    va_list list;
    va_start(list, format);
    va_end(list);
    
    format = [self format:format level:MDDLoggerLevelDebug];
    NSString *log = [[NSString alloc] initWithFormat:format arguments:list];
    
    dispatch_main_async_safe(^{
        NSLog(@"%@", log);
    });
}

- (void)logLevel:(MDDLoggerLevel)level format:(NSString *)format, ...{
    if (!self.enable) return;
    
    va_list list;
    va_start(list, format);
    va_end(list);
    
    format = [self format:format level:level];
    NSString *log = [[NSString alloc] initWithFormat:format arguments:list];
    
    dispatch_main_async_safe(^{
        NSLog(@"%@", log);
    });
}

- (NSString *)format:(NSString *)format level:(MDDLoggerLevel)level{
    static NSDictionary *levelDescriptions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        levelDescriptions = @{@(MDDLoggerLevelDebug): @"DEBUG",
                              @(MDDLoggerLevelInfo): @"INFO",
                              @(MDDLoggerLevelWarning): @"WARNING",
                              @(MDDLoggerLevelError): @"ERROR"};
    });
    
    return [NSString stringWithFormat:@"%@: %@", levelDescriptions[@(level)], format];
}

@end
