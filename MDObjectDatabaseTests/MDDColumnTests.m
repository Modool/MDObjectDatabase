
//
//  MDDColumnTests.m
//  MDObjectDatabaseTests
//
//  Created by xulinfeng on 2018/3/27.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MDDatabaseTestsGlobal.h"
#import "MDDColumn+Private.h"

@interface MDDColumnTests : XCTestCase

@end

@implementation MDDColumnTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSinglePropertyFromSQL {
    NSString *SQL = @"CREATE TABLE MDDUser (   objectID INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  ,  age INTEGER(200) NOT NULL  DEFAULT 10  CHECK(100),  name TEXT(200) ,  gradeID TEXT  , favor TEXT";
    id<MDDTableInfo> tableInfo = [[MDDatabaseTestsGlobal database] requireInfoWithClass:[MDDUser class] error:nil];
    NSDictionary<NSString *, MDDLocalColumn *> *columns = [MDDLocalColumn columnsWithSQL:SQL tableInfo:tableInfo];
    XCTAssertEqual(columns.count, 5);
    
    MDDLocalColumn *column = columns[@"age"];
    XCTAssertEqual(column.type, MDDColumnTypeInteger);
    XCTAssertEqual(column.configuration.length, 200);
    XCTAssertEqualObjects(column.configuration.defaultValue, @"10");
    XCTAssertEqualObjects(column.configuration.checkValue, @"100");
    
    column = columns[@"objectID"];
    XCTAssert(column.primary);
    XCTAssertEqual(column.type, MDDColumnTypeInteger);
}

- (void)testUnionPropertyFromSQL {
    NSString *SQL = @"CREATE TABLE MDDUser ( PRIMARY KEY ( objectID , name ), objectID INTEGER NOT NULL  ,  name TEXT(200) ,  age INTEGER(200) NOT NULL  DEFAULT 10  CHECK(100),  gradeID TEXT  , favor TEXT";
    id<MDDTableInfo> tableInfo = [[MDDatabaseTestsGlobal database] requireInfoWithClass:[MDDUser class] error:nil];
    NSDictionary<NSString *, MDDLocalColumn *> *columns = [MDDLocalColumn columnsWithSQL:SQL tableInfo:tableInfo];
    XCTAssertEqual(columns.count, 5);
    
    MDDLocalColumn *column = columns[@"objectID"];
    XCTAssert(column.primary);
    XCTAssertEqual(column.type, MDDColumnTypeInteger);
    XCTAssertEqual(column.configuration.nullabled, NO);
    
    column = columns[@"name"];
    XCTAssert(column.primary);
    XCTAssertEqual(column.type, MDDColumnTypeText);
    XCTAssertEqual(column.configuration.length, 200);
}

- (void)testCompositePropertyFromSQL {
    NSString *SQL = @"CREATE TABLE MDDUser ( CONSTRAINT private_key PRIMARY KEY ( objectID , name ), objectID INTEGER NOT NULL  ,  name TEXT(200) ,  age INTEGER(200) NOT NULL  DEFAULT 10  CHECK(100),  gradeID TEXT  , favor TEXT";
    id<MDDTableInfo> tableInfo = [[MDDatabaseTestsGlobal database] requireInfoWithClass:[MDDUser class] error:nil];
    NSDictionary<NSString *, MDDLocalColumn *> *columns = [MDDLocalColumn columnsWithSQL:SQL tableInfo:tableInfo];
    XCTAssertEqual(columns.count, 5);
    
    MDDLocalColumn *column = columns[@"objectID"];
    XCTAssert(column.primary);
    XCTAssertEqual(column.type, MDDColumnTypeInteger);
    XCTAssertEqual(column.configuration.nullabled, NO);
    XCTAssertEqualObjects(column.configuration.compositePropertyName, @"private_key");
    
    column = columns[@"name"];
    XCTAssert(column.primary);
    XCTAssertEqual(column.type, MDDColumnTypeText);
    XCTAssertEqual(column.configuration.length, 200);
    XCTAssertEqualObjects(column.configuration.compositePropertyName, @"private_key");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
