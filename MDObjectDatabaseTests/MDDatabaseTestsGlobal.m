//
//  MDDatabaseTestsGlobal.m
//  MDDatabaseTests
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "FMDB+MDDReferenceDatabase.h"
#import "MDDatabaseTestsGlobal.h"

@implementation MDBaseClass

+ (NSDictionary *)tableMapper{
    return @{};
}

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary;{
    NSDictionary *mapper = [self tableMapper];
    
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

@end

@implementation MDDTestClass

+ (NSDictionary *)tableMapper{
    return @{@"objectID": @"id",
             @"text": @"text",
             @"integerValue": @"integer_value",
             @"floatValue": @"float_value",
             @"boolValue": @"bool_value"};
}

@end

@implementation MDDUser

@end

@implementation MDDGrade

@end

@implementation MDDatabaseTestsGlobal

+ (MDDatabase *)database;{
    static MDDatabase *database = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *folder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *filepath = [folder stringByAppendingPathComponent:@"test.db"];
        NSLog(@"\nDatabase file: %@", filepath);
        MDDatabaseCenter *center = [MDDatabaseCenter defaultCenter];
        center.debugEnable = YES;
        
        FMDatabaseQueue *databaseQueue = [[FMDatabaseQueue alloc] initWithPath:filepath];
        database = [center requrieDatabaseWithDatabaseQueue:databaseQueue];
        
        MDDConfiguration *configuration = [MDDConfiguration configurationWithClass:[MDDTestClass class] propertyMapper:[MDDTestClass tableMapper] primaryProperty:@"objectID"];
        NSError *error = nil;
        MDDCompat *compat = [database addConfiguration:configuration error:&error];
        
        configuration = [MDDConfiguration configurationWithClass:[MDDUser class] primaryProperty:@"objectID"];
        compat = [database addConfiguration:configuration error:&error];
        
        configuration = [MDDConfiguration configurationWithClass:[MDDGrade class] primaryProperty:@"objectID"];
        compat = [database addConfiguration:configuration error:&error];
        
        [database prepare];
    });
    return database;
}

@end
