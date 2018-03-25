//
//  MDDatabase+MDDAccessor.h
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/25.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDatabase.h"
#import "MDDAccessor.h"
#import "MDDObject.h"

@interface MDDatabase (MDDAccessor)

- (MDDAccessor *)accessorForClass:(Class<MDDObject>)class;

- (MDDAccessor *)accessorForClass:(Class<MDDObject>)class queue:(dispatch_queue_t)queue;

@end
