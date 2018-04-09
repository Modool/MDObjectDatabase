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
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id property, id obj, BOOL *stop) {
        id resultProperty = [[mapper allKeysForObject:property] firstObject] ?: property;
        
        [result removeObjectForKey:property];
        result[resultProperty] = obj;
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

@implementation MDDUserGradeInfo

+ (NSDictionary *)tableMapper{
    return @{@"UID": @"uid",
             @"name": @"name",
             @"favor": @"favor",
             @"age": @"age",
             @"gradeID": @"grade_id",
             @"gradeName": @"grade_name",
             @"gradeLevel": @"grade_level"};
}

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
        
        MDDTableConfiguration *configuration = [MDDTableConfiguration configurationWithClass:[MDDTestClass class] propertyMapper:[MDDTestClass tableMapper] primaryProperty:@"objectID"];
        NSError *error = nil;
        MDDCompat *compat = [database addTableConfiguration:configuration error:&error];
        
        configuration = [MDDTableConfiguration configurationWithClass:[MDDUser class] primaryProperty:@"objectID"];
        compat = [database addTableConfiguration:configuration error:&error];
        
        configuration = [MDDTableConfiguration configurationWithClass:[MDDGrade class] primaryProperty:@"objectID"];
        compat = [database addTableConfiguration:configuration error:&error];
        
        id<MDDTableInfo> userInfo = [database requireInfoWithClass:[MDDUser class] error:nil];
        id<MDDTableInfo> gradeInfo = [database requireInfoWithClass:[MDDGrade class] error:nil];
        
        MDDValue *value = [MDDValue itemWithTableInfo:gradeInfo names:NSSetObject(@MDDKeyPath(MDDGrade, objectID))];
        MDDConditionSet *condition = [MDDConditionSet setWithCondition:[MDDCondition conditionWithTableInfo:gradeInfo primaryValue:value]];
        MDDViewConfiguration *viewConfiguration = [MDDViewConfiguration configurationWithClass:[MDDUserGradeInfo class] name:NSStringFromClass([MDDUserGradeInfo class]) propertyMapper:[MDDUserGradeInfo tableMapper] propertyColumns:nil conditionSet:condition];
        
        [viewConfiguration addColumn:[userInfo columnForProperty:@MDDKeyPath(MDDUser, objectID)] asPropertyNamed:@MDDKeyPath(MDDUserGradeInfo, UID) error:nil];
        [viewConfiguration addColumn:[userInfo columnForProperty:@MDDKeyPath(MDDUser, name)] asPropertyNamed:@MDDKeyPath(MDDUserGradeInfo, name) error:nil];
        [viewConfiguration addColumn:[userInfo columnForProperty:@MDDKeyPath(MDDUser, favor)] asPropertyNamed:@MDDKeyPath(MDDUserGradeInfo, favor) error:nil];
        
        [viewConfiguration addColumn:[gradeInfo columnForProperty:@MDDKeyPath(MDDGrade, objectID)] asPropertyNamed:@MDDKeyPath(MDDUserGradeInfo, gradeID) error:nil];
        [viewConfiguration addColumn:[gradeInfo columnForProperty:@MDDKeyPath(MDDGrade, name)] asPropertyNamed:@MDDKeyPath(MDDUserGradeInfo, gradeName) error:nil];
        [viewConfiguration addColumn:[gradeInfo columnForProperty:@MDDKeyPath(MDDGrade, level)] asPropertyNamed:@MDDKeyPath(MDDUserGradeInfo, gradeLevel) error:nil];
        
        compat = [database addTableConfiguration:configuration error:&error];
        
        [database prepare];
    });
    return database;
}

@end
