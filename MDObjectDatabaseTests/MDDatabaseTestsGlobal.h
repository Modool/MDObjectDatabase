//
//  MDDatabaseTestsGlobal.h
//  MDDatabaseTests
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MDDObject.h"
#import "MDDatabase.h"

@interface MDDTestClass : NSObject <MDDObject>

@property (nonatomic, copy) NSString *objectID;

@property (nonatomic, copy) NSString *text;

@property (nonatomic, assign) NSUInteger integerValue;

@property (nonatomic, assign) float floatValue;

@property (nonatomic, assign) BOOL boolValue;

@end

@interface MDDatabaseTestsGlobal : NSObject

+ (MDDatabase *)database;

@end
