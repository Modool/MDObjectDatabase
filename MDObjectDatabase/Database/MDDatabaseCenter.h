//
//  MDDatabaseCenter.h
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/25.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MDDReferenceDatabaseQueue;
@class MDDLogger, MDDatabase;
@interface MDDatabaseCenter : NSObject

@property (nonatomic, strong, readonly) MDDLogger *logger;

@property (nonatomic, assign, getter=isDebugEnabled) BOOL debugEnable;

+ (MDDatabaseCenter *)defaultCenter;

- (MDDatabase *)requrieDatabaseWithDatabaseQueue:(id<MDDReferenceDatabaseQueue>)queue;

@end
