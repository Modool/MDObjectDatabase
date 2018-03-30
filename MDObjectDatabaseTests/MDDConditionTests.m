//
//  MDDConditionTests.m
//  MDDatabaseTests
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MDObjectDatabase.h"

#import "MDDatabaseTestsGlobal.h"
#import "MDDCondition.h"
#import "MDDConditionSet+Private.h"

@interface MDDConditionTests : XCTestCase

@end

@implementation MDDConditionTests

- (void)testPrimaryValue {
    MDDTableInfo *tableInfo = [[MDDatabaseTestsGlobal database] requireTableInfoWithClass:[MDDTestClass class] error:nil];
    
    MDDCondition *condition = [MDDCondition conditionWithTableInfo:tableInfo primaryValue:@"123"];
    MDDDescription *description = [condition SQLDescription];
    
    XCTAssertNotNil(description);
    XCTAssert([description.SQL containsString:@"id = ?"]);
    XCTAssertEqual(description.values.firstObject, @"123");
}

- (void)testKeyValue {
    MDDTableInfo *tableInfo = [[MDDatabaseTestsGlobal database] requireTableInfoWithClass:[MDDTestClass class] error:nil];
    MDDCondition *condition = [MDDCondition conditionWithTableInfo:tableInfo key:@MDDKeyPath(MDDTestClass, integerValue) value:@123];
    MDDDescription *description = [condition SQLDescription];
    
    XCTAssertNotNil(description);
    XCTAssert([description.SQL containsString:@"integer_value = ?"]);
    XCTAssertEqual(description.values.firstObject, @123);
}

- (void)testConditionSet_AND_OR {
    MDDTableInfo *tableInfo = [[MDDatabaseTestsGlobal database] requireTableInfoWithClass:[MDDTestClass class] error:nil];
    
    MDDCondition *condition1 = [MDDCondition conditionWithTableInfo:tableInfo key:@MDDKeyPath(MDDTestClass, integerValue) value:@123];
    MDDCondition *condition2 = [MDDCondition conditionWithTableInfo:tableInfo key:@MDDKeyPath(MDDTestClass, boolValue) value:@YES];
    MDDCondition *condition3 = [MDDCondition conditionWithTableInfo:tableInfo primaryValue:@"3333"];
    MDDCondition *condition4 = [MDDCondition conditionWithTableInfo:tableInfo key:@MDDKeyPath(MDDTestClass, text) value:@"text"];
    
    MDDConditionSet *set1 = [MDDConditionSet setWithConditions:@[condition1, condition4]];
    MDDConditionSet *set2 = [MDDConditionSet setWithConditions:@[condition2, condition4]];
    
    MDDConditionSet *set3 = [[set1 orSet:set2] or:condition3];
    
    MDDDescription *description = [set3 SQLDescription];
    XCTAssertNotNil(description);
    NSLog(@"%@", description);
}

- (void)testConditionSet_OR_AND {
    MDDTableInfo *tableInfo = [[MDDatabaseTestsGlobal database] requireTableInfoWithClass:[MDDTestClass class] error:nil];
    
    MDDCondition *condition1 = [MDDCondition conditionWithTableInfo:tableInfo key:@MDDKeyPath(MDDTestClass, integerValue) value:@123];
    MDDCondition *condition2 = [MDDCondition conditionWithTableInfo:tableInfo key:@MDDKeyPath(MDDTestClass, boolValue) value:@YES];
    MDDCondition *condition3 = [MDDCondition conditionWithTableInfo:tableInfo primaryValue:@"3333"];
    MDDCondition *condition4 = [MDDCondition conditionWithTableInfo:tableInfo key:@MDDKeyPath(MDDTestClass, text) value:@"text"];
    
    MDDConditionSet *set1 = [MDDConditionSet setWithConditions:@[condition1, condition4] operation:MDDConditionOperationOr];
    MDDConditionSet *set2 = [MDDConditionSet setWithConditions:@[condition2, condition4] operation:MDDConditionOperationOr];
    
    MDDConditionSet *set3 = [[set1 andSet:set2] and:condition3];
    
    MDDDescription *description = [set3 SQLDescription];
    XCTAssertNotNil(description);
    NSLog(@"%@", description);
}

- (void)testConditionSet_AND_AND {
    MDDTableInfo *tableInfo = [[MDDatabaseTestsGlobal database] requireTableInfoWithClass:[MDDTestClass class] error:nil];
    
    MDDCondition *condition1 = [MDDCondition conditionWithTableInfo:tableInfo key:@MDDKeyPath(MDDTestClass, integerValue) value:@123];
    MDDCondition *condition2 = [MDDCondition conditionWithTableInfo:tableInfo key:@MDDKeyPath(MDDTestClass, boolValue) value:@YES];
    MDDCondition *condition3 = [MDDCondition conditionWithTableInfo:tableInfo primaryValue:@"3333"];
    MDDCondition *condition4 = [MDDCondition conditionWithTableInfo:tableInfo key:@MDDKeyPath(MDDTestClass, text) value:@"text"];
    
    MDDConditionSet *set1 = [MDDConditionSet setWithConditions:@[condition1, condition4]];
    MDDConditionSet *set2 = [MDDConditionSet setWithConditions:@[condition2, condition4]];
    
    MDDConditionSet *set3 = [[set1 andSet:set2] and:condition3];
    XCTAssertEqual(set3.conditions.count, 4);
    
    MDDDescription *description = [set3 SQLDescription];
    XCTAssertNotNil(description);
    
    NSLog(@"%@", description);
}

- (void)testConditionSet_OR_OR {
    MDDTableInfo *tableInfo = [[MDDatabaseTestsGlobal database] requireTableInfoWithClass:[MDDTestClass class] error:nil];
    
    MDDCondition *condition1 = [MDDCondition conditionWithTableInfo:tableInfo key:@MDDKeyPath(MDDTestClass, integerValue) value:@123];
    MDDCondition *condition2 = [MDDCondition conditionWithTableInfo:tableInfo key:@MDDKeyPath(MDDTestClass, boolValue) value:@YES];
    MDDCondition *condition3 = [MDDCondition conditionWithTableInfo:tableInfo primaryValue:@"3333"];
    MDDCondition *condition4 = [MDDCondition conditionWithTableInfo:tableInfo key:@MDDKeyPath(MDDTestClass, text) value:@"text"];
    
    MDDConditionSet *set1 = [MDDConditionSet setWithConditions:@[condition1, condition4] operation:MDDConditionOperationOr];
    MDDConditionSet *set2 = [MDDConditionSet setWithConditions:@[condition2, condition4] operation:MDDConditionOperationOr];
    
    MDDConditionSet *set3 = [[set1 orSet:set2] or:condition3];
    XCTAssertEqual(set3.conditions.count, 4);
    
    MDDDescription *description = [set3 SQLDescription];
    XCTAssertNotNil(description);
    
    NSLog(@"%@", description);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
