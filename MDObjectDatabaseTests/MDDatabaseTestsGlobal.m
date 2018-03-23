//
//  MDDatabaseTestsGlobal.m
//  MDDatabaseTests
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDatabaseTestsGlobal.h"

@implementation MDDTestClass

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary;{
    return nil;
}

+ (BOOL)autoincrement{
    return YES;
}

+ (NSString *)tableName{
    return NSStringFromClass(self.class);
}

+ (NSString *)primaryProperty{
    return NSStringFromSelector(@selector(objectID));
}

+ (NSDictionary *)tableMapping{
    return @{@"objectID": @"id",
             @"text": @"text",
             @"integerValue": @"integer_value",
             @"floatValue": @"float_value",
             @"boolValue": @"bool_value"};
}

@end

@implementation MDDatabaseTestsGlobal

+ (MDDatabase *)database;{
    static MDDatabase *database = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *folder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        database = [MDDatabase databaseWithFilepath:[folder stringByAppendingPathComponent:@"test.db"]];
        
        [database attachTableIfNeedsWithClass:[MDDTestClass class]];
    });
    return database;
}

@end
