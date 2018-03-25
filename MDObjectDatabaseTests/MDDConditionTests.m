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
#import "MDDCondition+Private.h"
#import "MDDConditionSet+Private.h"

@interface MDDConditionTests : XCTestCase

@end

@implementation MDDConditionTests

- (void)testPrimaryValue {
    MDDCondition *condition = [MDDCondition conditionWithPrimaryValue:@"123"];
    MDDTableInfo *tableInfo = [[MDDatabaseTestsGlobal database] requireTableInfoWithClass:[MDDTestClass class] error:nil];
    
    MDDTokenDescription *description = [MDDCondition descriptionWithConditions:@[condition] operation:MDDConditionOperationAnd tableInfo:tableInfo];
    XCTAssertNotNil(description);
    XCTAssert([description.tokenString containsString:@"id = ?"]);
    XCTAssertEqual(description.values.firstObject, @"123");
}

- (void)testKeyValue {
    MDDCondition *condition = [MDDCondition conditionWithKey:MDDKey(MDDTestClass, integerValue) value:@123];
    MDDTableInfo *tableInfo = [[MDDatabaseTestsGlobal database] requireTableInfoWithClass:[MDDTestClass class] error:nil];
    
    MDDTokenDescription *description = [MDDCondition descriptionWithConditions:@[condition] operation:MDDConditionOperationAnd tableInfo:tableInfo];
    XCTAssertNotNil(description);
    XCTAssert([description.tokenString containsString:@"integer_value = ?"]);
    XCTAssertEqual(description.values.firstObject, @123);
}

- (void)testConditionSet_AND_OR {
    MDDCondition *condition1 = [MDDCondition conditionWithKey:MDDKey(MDDTestClass, integerValue) value:@123];
    MDDCondition *condition2 = [MDDCondition conditionWithKey:MDDKey(MDDTestClass, boolValue) value:@YES];
    MDDCondition *condition3 = [MDDCondition conditionWithPrimaryValue:@"3333"];
    MDDCondition *condition4 = [MDDCondition conditionWithKey:MDDKey(MDDTestClass, text) value:@"text"];
    
    MDDConditionSet *set1 = [MDDConditionSet setWithConditions:@[condition1, condition4]];
    MDDConditionSet *set2 = [MDDConditionSet setWithConditions:@[condition2, condition4]];
    
    MDDConditionSet *set3 = [[set1 orSet:set2] or:condition3];
    
    MDDTableInfo *tableInfo = [[MDDatabaseTestsGlobal database] requireTableInfoWithClass:[MDDTestClass class] error:nil];
    
    MDDTokenDescription *description = [MDDConditionSet descriptionWithConditionSet:set3 tableInfo:tableInfo];
    XCTAssertNotNil(description);
    NSLog(@"%@", description);
}

- (void)testConditionSet_OR_AND {
    MDDCondition *condition1 = [MDDCondition conditionWithKey:MDDKey(MDDTestClass, integerValue) value:@123];
    MDDCondition *condition2 = [MDDCondition conditionWithKey:MDDKey(MDDTestClass, boolValue) value:@YES];
    MDDCondition *condition3 = [MDDCondition conditionWithPrimaryValue:@"3333"];
    MDDCondition *condition4 = [MDDCondition conditionWithKey:MDDKey(MDDTestClass, text) value:@"text"];
    
    MDDConditionSet *set1 = [MDDConditionSet setWithConditions:@[condition1, condition4] operation:MDDConditionOperationOr];
    MDDConditionSet *set2 = [MDDConditionSet setWithConditions:@[condition2, condition4] operation:MDDConditionOperationOr];
    
    MDDConditionSet *set3 = [[set1 andSet:set2] and:condition3];
    
    MDDTableInfo *tableInfo = [[MDDatabaseTestsGlobal database] requireTableInfoWithClass:[MDDTestClass class] error:nil];
    
    MDDTokenDescription *description = [MDDConditionSet descriptionWithConditionSet:set3 tableInfo:tableInfo];
    XCTAssertNotNil(description);
    NSLog(@"%@", description);
}

- (void)testConditionSet_AND_AND {
    MDDCondition *condition1 = [MDDCondition conditionWithKey:MDDKey(MDDTestClass, integerValue) value:@123];
    MDDCondition *condition2 = [MDDCondition conditionWithKey:MDDKey(MDDTestClass, boolValue) value:@YES];
    MDDCondition *condition3 = [MDDCondition conditionWithPrimaryValue:@"3333"];
    MDDCondition *condition4 = [MDDCondition conditionWithKey:MDDKey(MDDTestClass, text) value:@"text"];
    
    MDDConditionSet *set1 = [MDDConditionSet setWithConditions:@[condition1, condition4]];
    MDDConditionSet *set2 = [MDDConditionSet setWithConditions:@[condition2, condition4]];
    
    MDDConditionSet *set3 = [[set1 andSet:set2] and:condition3];
    XCTAssertEqual(set3.conditions.count, 4);
    
    MDDTableInfo *tableInfo = [[MDDatabaseTestsGlobal database] requireTableInfoWithClass:[MDDTestClass class] error:nil];
    
    MDDTokenDescription *description = [MDDConditionSet descriptionWithConditionSet:set3 tableInfo:tableInfo];
    XCTAssertNotNil(description);
    
    NSLog(@"%@", description);
}

- (void)testConditionSet_OR_OR {
    MDDCondition *condition1 = [MDDCondition conditionWithKey:MDDKey(MDDTestClass, integerValue) value:@123];
    MDDCondition *condition2 = [MDDCondition conditionWithKey:MDDKey(MDDTestClass, boolValue) value:@YES];
    MDDCondition *condition3 = [MDDCondition conditionWithPrimaryValue:@"3333"];
    MDDCondition *condition4 = [MDDCondition conditionWithKey:MDDKey(MDDTestClass, text) value:@"text"];
    
    MDDConditionSet *set1 = [MDDConditionSet setWithConditions:@[condition1, condition4] operation:MDDConditionOperationOr];
    MDDConditionSet *set2 = [MDDConditionSet setWithConditions:@[condition2, condition4] operation:MDDConditionOperationOr];
    
    MDDConditionSet *set3 = [[set1 orSet:set2] or:condition3];
    XCTAssertEqual(set3.conditions.count, 4);
    
    MDDTableInfo *tableInfo = [[MDDatabaseTestsGlobal database] requireTableInfoWithClass:[MDDTestClass class] error:nil];
    
    MDDTokenDescription *description = [MDDConditionSet descriptionWithConditionSet:set3 tableInfo:tableInfo];
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
