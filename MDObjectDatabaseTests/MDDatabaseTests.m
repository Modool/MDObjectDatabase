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

- (void)testAddTableConfiguration{
    MDDTableConfiguration *tableConfiguration = [MDDTableConfiguration configurationWithClass:[MDDTestClass class] propertyMapper:[MDDTestClass tableMapper] primaryProperty:@"objectID"];
    NSError *error = nil;
    MDDCompat *compat = [_database addTableConfiguration:tableConfiguration error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(compat);
    
    tableConfiguration = [MDDTableConfiguration configurationWithClass:[MDDUser class] primaryProperty:@"objectID"];
    compat = [_database addTableConfiguration:tableConfiguration error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(compat);
    
    tableConfiguration = [MDDTableConfiguration configurationWithClass:[MDDGrade class] primaryProperty:@"objectID"];
    compat = [_database addTableConfiguration:tableConfiguration error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(compat);
}

- (void)testAddViewConfiguration{
    id<MDDTableInfo> userInfo = [_database requireInfoWithClass:[MDDUser class] error:nil];
    XCTAssertNotNil(userInfo);
    
    id<MDDTableInfo> gradeInfo = [_database requireInfoWithClass:[MDDGrade class] error:nil];
    XCTAssertNotNil(gradeInfo);
    
    MDDValue *value = [MDDConditionValue itemWithTableInfo:userInfo names:NSSetObject(@MDDKeyPath(MDDUser, gradeID))];
    MDDConditionSet *condition = [MDDConditionSet setWithCondition:[MDDCondition conditionWithTableInfo:gradeInfo primaryValue:value]];
    MDDViewConfiguration *viewConfiguration = [MDDViewConfiguration configurationWithClass:[MDDUserGradeInfo class] name:NSStringFromClass([MDDUserGradeInfo class]) propertyMapper:[MDDUserGradeInfo tableMapper] propertyColumns:nil conditionSet:condition];
    
    NSError *error = nil;
    [viewConfiguration addColumn:[userInfo columnForProperty:@MDDKeyPath(MDDUser, objectID)] asPropertyNamed:@MDDKeyPath(MDDUserGradeInfo, UID) error:&error];
    [viewConfiguration addColumn:[userInfo columnForProperty:@MDDKeyPath(MDDUser, name)] asPropertyNamed:@MDDKeyPath(MDDUserGradeInfo, name) error:&error];
    [viewConfiguration addColumn:[userInfo columnForProperty:@MDDKeyPath(MDDUser, favor)] asPropertyNamed:@MDDKeyPath(MDDUserGradeInfo, favor) error:&error];
    
    [viewConfiguration addColumn:[gradeInfo columnForProperty:@MDDKeyPath(MDDGrade, objectID)] asPropertyNamed:@MDDKeyPath(MDDUserGradeInfo, gradeID) error:&error];
    [viewConfiguration addColumn:[gradeInfo columnForProperty:@MDDKeyPath(MDDGrade, name)] asPropertyNamed:@MDDKeyPath(MDDUserGradeInfo, gradeName) error:&error];
    [viewConfiguration addColumn:[gradeInfo columnForProperty:@MDDKeyPath(MDDGrade, level)] asPropertyNamed:@MDDKeyPath(MDDUserGradeInfo, gradeLevel) error:&error];
    
    MDDCompat *compat = [_database addViewConfiguration:viewConfiguration error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(compat);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
