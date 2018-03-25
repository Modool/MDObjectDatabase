//
//  MDDatabase+MDDAccessor.m
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/25.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDatabase+MDDAccessor.h"

@implementation MDDatabase (MDDAccessor)

- (MDDAccessor *)accessorForClass:(Class<MDDObject>)class;{
    return [self accessorForClass:class queue:nil];
}

- (MDDAccessor *)accessorForClass:(Class<MDDObject>)class queue:(dispatch_queue_t)queue;{
    return [[MDDAccessor alloc] initWithClass:class database:self queue:queue];
}

@end
