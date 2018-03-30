//
//  MDDAccessorTests.m
//  MDObjectDatabaseTests
//
//  Created by xulinfeng on 2018/3/27.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MDDatabaseTestsGlobal.h"

@interface MDDAccessorTests : XCTestCase

@property (nonatomic, strong, readonly) MDDAccessor *accessor;
@property (nonatomic, strong, readonly) dispatch_queue_t queue;

@end

@implementation MDDAccessorTests

- (void)setUp{
    [super setUp];
    _queue = dispatch_queue_create("com.modool.database", NULL);
    _accessor = [[MDDatabaseTestsGlobal database] accessorForClass:[MDDTestClass class] queue:_queue];
}

- (void)testAsynchronize {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL state = NO;
    [[self accessor] async:^(id<MDDProcessor, MDDCoreProcessor> processor) {
        state = YES;
        XCTAssert(![NSThread isMainThread]);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_time_t timeout_nanos = dispatch_time(DISPATCH_TIME_NOW, (10 * NSEC_PER_SEC));
    long timeout = dispatch_semaphore_wait(semaphore, timeout_nanos);
    
    XCTAssert(timeout == 0);
    XCTAssert(state);
}

- (void)testSynchronize {
    __block BOOL state = NO;
    [[self accessor] sync:^(id<MDDProcessor, MDDCoreProcessor> processor) {
        state = YES;
        XCTAssert([NSThread isMainThread]);
    }];
    XCTAssert(state);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
