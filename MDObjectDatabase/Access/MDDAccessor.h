//
//  MDDAccessor.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/8/8.
//  Copyright © 2017年 modool. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MDDatabase, MDDTableInfo;
@protocol MDDProcessor, MDDObject;
@interface MDDAccessor : NSObject

@property (nonatomic, strong, readonly) MDDatabase *database;
@property (nonatomic, strong, readonly) dispatch_queue_t queue;
@property (nonatomic, strong, readonly) Class<MDDObject> modelClass;
@property (nonatomic, strong, readonly) MDDTableInfo *tableInfo;

- (instancetype)initWithClass:(Class<MDDObject>)class database:(MDDatabase *)database;
- (instancetype)initWithClass:(Class<MDDObject>)class database:(MDDatabase *)database queue:(dispatch_queue_t)queue;

- (void)sync:(void (^)(id<MDDProcessor> processor))block;
- (void)async:(void (^)(id<MDDProcessor> processor))block;

@end
