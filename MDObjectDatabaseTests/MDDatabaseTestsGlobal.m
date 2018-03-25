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
    NSDictionary *mapper = [self tableMapping];
    
    NSMutableDictionary *result = [dictionary ?: @{} mutableCopy];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id resultKey = [[mapper allKeysForObject:key] firstObject] ?: key;
        
        [result removeObjectForKey:key];
        result[resultKey] = obj;
    }];
    return [[self alloc] initWithDictionary:result];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
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
        NSString *filepath = [folder stringByAppendingPathComponent:@"test.db"];
        database = [[MDDatabaseCenter defaultCenter] requrieDatabaseWithFilepath:filepath];
        
        NSDictionary *tableMapper = @{@"objectID": @"id",
                                      @"text": @"text",
                                      @"integerValue": @"integer_value",
                                      @"floatValue": @"float_value",
                                      @"boolValue": @"bool_value"};
        
        MDDConfiguration *configuration = [MDDConfiguration configurationWithClass:[MDDTestClass class] propertyMapper:tableMapper primaryProperty:@"objectID"];
        NSError *error = nil;
        MDDCompat *compat = [database addConfiguration:configuration error:&error];
        [compat bindColumnIncrement:^MDDCompatResult(MDDCompatOperation operation, MDDLocalColumn *localColumn, MDDColumn *column) {
            return MDDCompatResultContinue;
        }];
        [compat bindIndexIncrement:^MDDCompatResult(MDDCompatOperation operation, MDDLocalIndex *localIndex, MDDIndex *index) {
            return MDDCompatResultContinue;
        }];
    });
    return database;
}

@end
