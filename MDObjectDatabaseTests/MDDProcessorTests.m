//
//  MDDProcessorTests.m
//  MDObjectDatabaseTests
//
//  Created by xulinfeng on 2018/3/27.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MDDatabaseTestsGlobal.h"

@interface MDDProcessorTests : XCTestCase

@property (nonatomic, strong, readonly) MDDAccessor *accessor;
@property (nonatomic, strong, readonly) dispatch_queue_t queue;

@end

@implementation MDDProcessorTests

- (void)setUp{
    [super setUp];
    _queue = dispatch_queue_create("com.modool.database", NULL);
    _accessor = [[MDDatabaseTestsGlobal database] accessorForClass:[MDDTestClass class] queue:_queue];;
}

- (void)testInsertObject {
    __block BOOL state = NO;
    [[self accessor] sync:^(id<MDDProcessor, MDDCoreProcessor> processor) {
        state = [processor insertWithObjectsWithBlock:^id(NSUInteger index, BOOL *stop) {
            *stop = index == 1;
            return [[MDDTestClass alloc] init];
        } block:nil];
        XCTAssert([NSThread isMainThread]);
    }];
    XCTAssert(state);
}

- (void)testQuery {
    __block MDDTestClass *object = nil;
    [[self accessor] sync:^(id<MDDProcessor, MDDCoreProcessor> processor) {
        object = [processor queryWithPrimaryValue:@"1"];
    }];
    XCTAssert(object);
}

- (void)testQueryByCondition {
    __block NSArray<MDDTestClass *> *objects = nil;
    [[self accessor] sync:^(id<MDDProcessor, MDDCoreProcessor> processor) {
        objects = [processor queryWithConditionSet:[MDDConditionSet setWithCondition:[MDDCondition conditionWithTableInfo:processor.tableInfo property:@MDDKeyPath(MDDTestClass, objectID) value:@"10" operation:MDDOperationLessThan]]];
    }];
    XCTAssert(objects.count);
}

- (void)testQueryByConditionTransform {
    __block NSArray<MDDTestClass *> *objects = nil;
    [[self accessor] sync:^(id<MDDProcessor, MDDCoreProcessor> processor) {
        objects = [processor queryWithConditionSet:[MDDConditionSet setWithCondition:[MDDCondition conditionWithTableInfo:processor.tableInfo property:@MDDKeyPath(MDDTestClass, objectID) value:@"20" operation:MDDOperationLessThan transform:@"+ 10"]]];
    }];
    XCTAssert(objects.count);
}

- (void)testQueryByConditionMultipleTransforms {
    __block NSArray<MDDTestClass *> *objects = nil;
    [[self accessor] sync:^(id<MDDProcessor, MDDCoreProcessor> processor) {
        objects = [processor queryWithConditionSet:[MDDConditionSet setWithCondition:[MDDCondition conditionWithTableInfo:processor.tableInfo property:@MDDKeyPath(MDDTestClass, objectID) value:@"20" operation:MDDOperationLessThan transforms:@[@"+ 10", @"* 0.7"]]]];
    }];
    XCTAssert(objects.count);
}

- (void)testQueryFromQueryResultSet {
    NSMutableArray<MDDTestClass *> *objects = [NSMutableArray array];
    [[self accessor] sync:^(id<MDDProcessor, MDDCoreProcessor> processor) {
        MDDConditionSet *condition1 = [MDDConditionSet setWithCondition:[MDDCondition conditionWithTableInfo:[processor tableInfo] primaryValue:@"10" operation:MDDOperationGreaterThan]];
        MDDSort *sort1 = [MDDSort sortWithTableInfo:[processor tableInfo] property:@MDDKeyPath(MDDTestClass, objectID) ascending:YES];
        MDDQuery *subQuery = [MDDQuery queryWithPropertys:nil conditionSet:condition1 sorts:@[sort1]];
        
        MDDSet *set = [MDDSet setWithDescriptor:subQuery alias:@"sub_query"];
        
        MDDCondition *condition2 = MDDConditionPrimary2([processor tableInfo], @"20", MDDOperationLessThan);
        MDDConditionSet *conditionSet = MDDConditionSet1(condition2);
        
        MDDSort *sort2 = [MDDSort sortWithTableInfo:[processor tableInfo] property:@MDDKeyPath(MDDTestClass, objectID) ascending:NO];
        
        MDDQuery *query = [MDDQuery queryWithPropertys:nil set:set conditionSet:conditionSet sorts:@[sort2] range:NSRangeZore objectClass:[MDDTestClass class]];
        
        [processor executeQuery:query block:^(id result) {
            [objects addObject:result];
        }];
    }];
    XCTAssert([objects count]);
}

- (void)testQueryByConditionUnionTable {
    NSMutableArray<MDDTestClass *> *objects = [NSMutableArray array];
    [[self accessor] sync:^(id<MDDProcessor, MDDCoreProcessor> processor) {
        MDDConditionSet *condition1 = [MDDConditionSet setWithCondition:[MDDCondition conditionWithTableInfo:[processor tableInfo] primaryValue:@"10" operation:MDDOperationGreaterThan]];
        MDDQuery *subQuery = [MDDQuery queryWithConditionSet:condition1];
        MDDItem *property = [MDDItem itemWithDescriptor:subQuery];
        
        MDDConditionSet *condition2 = [MDDConditionSet setWithCondition:[MDDCondition conditionWithTableInfo:[processor tableInfo] property:property value:nil operation:MDDOperationExists]];
        MDDSort *sort2 = [MDDSort sortWithTableInfo:[processor tableInfo] property:@MDDKeyPath(MDDTestClass, objectID) ascending:NO];
        MDDQuery *query = [MDDQuery queryWithPropertys:nil conditionSet:condition2 sorts:@[sort2] range:NSRangeZore objectClass:[MDDTestClass class]];
        
        [processor executeQuery:query block:^(id result) {
            [objects addObject:result];
        }];
    }];
    XCTAssert([objects count]);
}

- (void)testQueryByUnionTableAsProperty {
    NSMutableArray<MDDTestClass *> *objects = [NSMutableArray array];
    [[self accessor] sync:^(id<MDDProcessor, MDDCoreProcessor> processor) {
        MDDFunctionQuery *keyQuery = [MDDFunctionQuery fuctionQueryWithProperty:[MDDFuntionProperty propertyWithTableInfo:[processor tableInfo] name:@MDDKeyPath(MDDTestClass, objectID) function:MDDFunctionSUM] alias:@"integer_value"];
        MDDItem *property = [MDDItem itemWithDescriptor:keyQuery];
    
        MDDConditionSet *condition1 = [MDDConditionSet setWithCondition:[MDDCondition conditionWithTableInfo:[processor tableInfo] primaryValue:@"10" operation:MDDOperationGreaterThan]];
        MDDItem *key2 = [MDDItem itemWithTableInfo:[processor tableInfo] names:NSSetObjects([NSNull null], @MDDKeyPath(MDDTestClass, text), @MDDKeyPath(MDDTestClass, floatValue))];
        MDDQuery *query = [MDDQuery queryWithPropertys:NSSetObjects(property, key2) conditionSet:condition1 sorts:nil range:NSRangeZore objectClass:[MDDTestClass class]];
        
        [processor executeQuery:query block:^(id result) {
            [objects addObject:result];
        }];
    }];
    XCTAssert([objects count]);
}

- (void)testUpdateAllRow {
    NSUInteger value = arc4random() % 10;
    
    MDDSetter *setter = [MDDSetter setterWithTableInfo:[[self accessor] tableInfo] property:@MDDKeyPath(MDDTestClass, integerValue) value:@(value)];
    __block BOOL state = NO;
    [[self accessor] sync:^(id<MDDProcessor, MDDCoreProcessor> processor) {
        state = [processor updateWithSetter:setter];
    }];
    XCTAssert(state);
    
    __block MDDTestClass *object = nil;
    [[self accessor] sync:^(id<MDDProcessor, MDDCoreProcessor> processor) {
        object = [[processor queryWithProperty:@MDDKeyPath(MDDTestClass, integerValue) value:@(value)] firstObject];
    }];
    XCTAssert(object);
    XCTAssert(object.integerValue == value);
}

- (void)testUpdate {
    __block BOOL state = NO;
    [[self accessor] sync:^(id<MDDProcessor, MDDCoreProcessor> processor) {
        state = [processor updateWithPrimaryValue:@"1" property:@MDDKeyPath(MDDTestClass, text) value:@"hhhh"];
    }];
    XCTAssert(state);
    
    __block MDDTestClass *object = nil;
    [[self accessor] sync:^(id<MDDProcessor, MDDCoreProcessor> processor) {
        object = [processor queryWithPrimaryValue:@"1"];
    }];
    XCTAssert(object);
    XCTAssert([object.text isEqualToString:@"hhhh"]);
}

- (void)testUpdateValueWithQuery {
    __block BOOL state = NO;
    [[self accessor] sync:^(id<MDDProcessor, MDDCoreProcessor> processor) {
        MDDFuntionProperty *property = [MDDFuntionProperty propertyWithTableInfo:processor.tableInfo name:@MDDKeyPath(MDDTestClass, integerValue) function:MDDFunctionSUM];
        MDDFunctionQuery *query = [MDDFunctionQuery fuctionQueryWithProperty:property];
        MDDValue *value = [MDDValue itemWithDescriptor:query];
        
        state = [processor updateWithPrimaryValue:@"1" property:@MDDKeyPath(MDDTestClass, floatValue) value:value];
    }];
    XCTAssert(state);
}

- (void)testDelete {
    __block BOOL state = NO;
    [[self accessor] sync:^(id<MDDProcessor, MDDCoreProcessor> processor) {
        state = [processor deleteWithPrimaryValue:@"2"];
    }];
    XCTAssert(state);
    
    __block MDDTestClass *object = nil;
    [[self accessor] sync:^(id<MDDProcessor, MDDCoreProcessor> processor) {
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
