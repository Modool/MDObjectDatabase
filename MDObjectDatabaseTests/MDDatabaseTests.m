//
//  MDDatabaseTests.m
//  MDDatabaseTests
//
//  Created by Jave on 2017/12/27.
//  Copyright © 2017年 markejave. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MDDatabaseTestsGlobal.h"

@interface MDDatabaseTests : XCTestCase

@property (nonatomic, strong, readonly) MDDatabase *database;
@property (nonatomic, strong, readonly) MDDAccessor *accessor;
@property (nonatomic, strong, readonly) dispatch_queue_t queue;

@end

@implementation MDDatabaseTests

- (void)setUp{
    [super setUp];
    NSString *folder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filepath = [folder stringByAppendingPathComponent:@"test_1.db"];
    FMDatabaseQueue *queue = [[FMDatabaseQueue alloc] initWithPath:filepath];
    
    _database = [[MDDatabaseCenter defaultCenter] requrieDatabaseWithDatabaseQueue:queue];
}

- (void)testAddConfiguration{
    
//    _database addConfiguration:(MDDConfiguration *) error:(NSError *__autoreleasing *)
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
