//
//  MDQueueObject.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/9/25.
//  Copyright © 2017年 Modool. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString * const MDQueueObjectDomainPrefix;

@interface MDQueueObject : NSObject{
    dispatch_queue_t _queue;
}

@property (nonatomic, strong, readonly) dispatch_queue_t queue;

- (void)async:(dispatch_block_t)block;

- (void)sync:(dispatch_block_t)block;

@end
