//
//  MDDAccessor.m
//  MDDatabase
//
//  Created by xulinfeng on 2017/8/8.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDAccessor.h"
#import "MDDProcessor+Private.h"

#import "MDDatabase.h"

@interface MDDAccessor ()

@property (nonatomic, assign, readonly) void *queueTag;

@end

@implementation MDDAccessor

- (instancetype)initWithClass:(Class<MDDObject>)class database:(MDDatabase *)database;{
    return [self initWithClass:class database:database queue:dispatch_get_main_queue()];
}

- (instancetype)initWithClass:(Class<MDDObject>)class database:(MDDatabase *)database queue:(dispatch_queue_t)queue;{
    if (self = [super init]) {
        _modelClass = class;
        _database = database;
        _queue = queue;
        _queueTag = &_queueTag;
        dispatch_queue_set_specific(queue, _queueTag, _queueTag, NULL);
        
        [database attachTableIfNeedsWithClass:class];
    }
    return self;
}

- (void)_sync:(dispatch_block_t)block;{
    if (dispatch_get_specific(_queueTag)) {
        block();
    } else {
        dispatch_sync(_queue, block);
    }
}

- (void)_async:(dispatch_block_t)block;{
    if (dispatch_get_specific(_queueTag)) {
        block();
    } else {
        dispatch_async(_queue, block);
    }
}

- (void)sync:(void (^)(id<MDDProcessor> processor))block;{
    MDDProcessor *operator = [[MDDProcessor alloc] initWithClass:_modelClass database:_database];
    
    [self _sync:^{
        block(operator);
    }];
}

- (void)async:(void (^)(id<MDDProcessor> processor))block;{
    MDDProcessor *operator = [[MDDProcessor alloc] initWithClass:_modelClass database:_database];
    
    [self _async:^{
        block(operator);
    }];
}

@end
