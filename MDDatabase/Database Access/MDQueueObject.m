//
//  MDQueueObject.m
//  MDDatabase
//
//  Created by xulinfeng on 2017/9/25.
//  Copyright © 2017年 Modool. All rights reserved.
//

#import "MDQueueObject.h"

NSString * const MDQueueObjectDomainPrefix = @"com.bilibili.queue.object#";

@interface MDQueueObject ()

@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, assign) void *queueTag;

@end

@implementation MDQueueObject

- (instancetype)init{
    if (self = [super init]) {
        NSString *queueName = [MDQueueObjectDomainPrefix stringByAppendingString:NSStringFromClass([self class])];
        self.queue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_SERIAL);
        
        self.queueTag = &_queueTag;
        dispatch_queue_set_specific([self queue], _queueTag, _queueTag, NULL);
    }
    return self;
}

- (void)async:(dispatch_block_t)block;{
    if (dispatch_get_specific(_queueTag)) {
        block();
    } else {
        dispatch_async([self queue], block);
    }
}

- (void)sync:(dispatch_block_t)block;{
    if (dispatch_get_specific(_queueTag)) {
        block();
    } else {
        dispatch_sync([self queue], block);
    }
}

@end
