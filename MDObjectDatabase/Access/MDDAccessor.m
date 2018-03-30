//
//  MDDAccessor.m
//  MDDatabase
//
//  Created by xulinfeng on 2017/8/8.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDAccessor.h"
#import "MDDProcessor+Private.h"
#import "MDDProcessor+MDDatabase.h"

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
        _objectClass = class;
        _database = database;
        _queue = queue;
        _queueTag = &_queueTag;
        dispatch_queue_set_specific(queue, _queueTag, _queueTag, NULL);
        
        NSError *error = nil;
        _tableInfo = [database requireTableInfoWithClass:class error:&error];
        NSAssert(_tableInfo && !error, [error description]);
    }
    return self;
}

- (NSString *)description{
    return [[self dictionaryWithValuesForKeys:@[@"objectClass", @"database", @"tableInfo", @"queue"]] description];
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

- (void)sync:(void (^)(id<MDDProcessor, MDDCoreProcessor> processor))block;{
    MDDProcessor *operator = [[MDDProcessor alloc] initWithClass:_objectClass database:_database tableInfo:_tableInfo];
    
    [self _sync:^{
        block(operator);
    }];
}

- (void)async:(void (^)(id<MDDProcessor, MDDCoreProcessor> processor))block;{
    MDDProcessor *operator = [[MDDProcessor alloc] initWithClass:_objectClass database:_database tableInfo:_tableInfo];
    
    [self _async:^{
        block(operator);
    }];
}

@end
