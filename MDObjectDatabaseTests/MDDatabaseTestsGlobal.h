//
//  MDDatabaseTestsGlobal.h
//  MDDatabaseTests
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MDObjectDatabase/MDObjectDatabase.h>

#import "FMDB+MDDReferenceDatabase.h"

@interface MDBaseClass : NSObject <MDDObject>

@end

@interface MDDTestClass : MDBaseClass

@property (nonatomic, copy) NSString *objectID;

@property (nonatomic, copy) NSString *text;

@property (nonatomic, assign) NSUInteger integerValue;

@property (nonatomic, assign) float floatValue;

@property (nonatomic, assign) BOOL boolValue;

+ (NSDictionary *)tableMapper;

@end

@interface MDDUser : MDBaseClass

@property (nonatomic, copy) NSString *objectID;

@property (nonatomic, copy) NSString *gradeID;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *favor;

@property (nonatomic, assign) NSUInteger age;

@end

@interface MDDGrade : MDBaseClass 

@property (nonatomic, copy) NSString *objectID;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) NSUInteger level;

@end

@interface MDDUserGradeInfo : MDBaseClass

@property (nonatomic, copy) NSString *UID;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *favor;

@property (nonatomic, assign) NSUInteger age;

@property (nonatomic, copy) NSString *gradeID;

@property (nonatomic, copy) NSString *gradeName;

@property (nonatomic, assign) NSUInteger gradeLevel;

+ (NSDictionary *)tableMapper;

@end

@interface MDDatabaseTestsGlobal : NSObject

+ (MDDatabase *)database;

@end
