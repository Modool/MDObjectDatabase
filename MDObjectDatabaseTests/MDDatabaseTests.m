//
//  MDDatabaseTests.m
//  MDDatabaseTests
//
//  Created by Jave on 2017/12/27.
//  Copyright © 2017年 markejave. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MDObjectDatabase.h"

#import "MDDatabaseTestsGlobal.h"

@interface MDDatabaseTests : XCTestCase

@property (nonatomic, strong, readonly) MDDAccessor *accessor;
@property (nonatomic, strong, readonly) dispatch_queue_t queue;

@end

@implementation MDDatabaseTests

- (void)setUp{
    [super setUp];
    _queue = dispatch_queue_create("com.modool.database", NULL);
    _accessor = [[MDDAccessor alloc] initWithClass:[MDDTestClass class] database:[MDDatabaseTestsGlobal database] queue:_queue];
}

- (void)testInsertObjectAsynchronize {
    MDDTestClass *object = [[MDDTestClass alloc] init];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL state = NO;
    [[self accessor] async:^(id<MDDProcessor> processor) {
        state = [processor insertWithObject:object];
        XCTAssert(![NSThread isMainThread]);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_time_t timeout_nanos = dispatch_time(DISPATCH_TIME_NOW, (10 * NSEC_PER_SEC));
    long timeout = dispatch_semaphore_wait(semaphore, timeout_nanos);

    XCTAssert(timeout == 0);
    XCTAssert(state);
}

- (void)testInsertObject {
    MDDTestClass *object = [[MDDTestClass alloc] init];

    __block BOOL state = NO;
    [[self accessor] sync:^(id<MDDProcessor> processor) {
        state = [processor insertWithObject:object];
        XCTAssert([NSThread isMainThread]);
    }];
    
    XCTAssert(state);
}

- (void)testQuery {
    __block MDDTestClass *object = nil;
    [[self accessor] sync:^(id<MDDProcessor> processor) {
        object = [processor queryWithPrimaryValue:@"1"];
    }];
    XCTAssert(object);
}

- (void)testUpdateAllRow {
    
    NSUInteger value = arc4random() % 10;
    MDDSetter *setter = [MDDSetter setterWithKey:MDDKey(MDDTestClass, integerValue) value:@(value)];
    __block BOOL state = NO;
    [[self accessor] sync:^(id<MDDProcessor> processor) {
        state = [processor updateWithSetter:setter];
    }];
    XCTAssert(state);
    
    __block MDDTestClass *object = nil;
    [[self accessor] sync:^(id<MDDProcessor> processor) {
        object = [[processor queryWithKey:MDDKey(MDDTestClass, integerValue) value:@(value)] firstObject];
    }];
    XCTAssert(object);
    XCTAssert(object.integerValue == value);
}

- (void)testUpdate {
    __block BOOL state = NO;
    [[self accessor] sync:^(id<MDDProcessor> processor) {
        state = [processor updateWithPrimaryValue:@"1" key:MDDKey(MDDTestClass, text) value:@"hhhh"];
    }];
    XCTAssert(state);
    
    __block MDDTestClass *object = nil;
    [[self accessor] sync:^(id<MDDProcessor> processor) {
        object = [processor queryWithPrimaryValue:@"1"];
    }];
    XCTAssert(object);
    XCTAssert([object.text isEqualToString:@"hhhh"]);
}

- (void)testDelete {
    __block BOOL state = NO;
    [[self accessor] sync:^(id<MDDProcessor> processor) {
        state = [processor deleteWithPrimaryValue:@"2"];
    }];
    XCTAssert(state);
    
    __block MDDTestClass *object = nil;
    [[self accessor] sync:^(id<MDDProcessor> processor) {
        object = [processor queryWithPrimaryValue:@"2"];
    }];
    XCTAssert(!object);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
