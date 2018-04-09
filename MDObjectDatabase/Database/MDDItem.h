//
//  MDDItem.h
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/26.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDDDescriptor.h"
#import "MDDConstants.h"

@protocol MDDObject;
@class MDDDescription;

@protocol MDDItem <NSObject>
@end

@interface MDDItem : MDDDescriptor <MDDItem>

@property (nonatomic, strong, readonly) MDDDescriptor *descriptor;
@property (nonatomic, copy, readonly) NSString *alias;

@property (nonatomic, copy, readonly) NSSet *names;

+ (instancetype)itemWithDescriptor:(MDDDescriptor *)descriptor;
+ (instancetype)itemWithDescriptor:(MDDDescriptor *)descriptor alias:(NSString *)alias;

+ (instancetype)itemWithTableInfo:(id<MDDTableInfo>)tableInfo names:(NSSet<NSString *> *)names;

@end

@interface MDDFuntionProperty : MDDItem

@property (nonatomic, copy, readonly) NSString *function;

+ (instancetype)propertyWithTableInfo:(id<MDDTableInfo>)tableInfo name:(NSString *)name function:(MDDFunction)function;
+ (instancetype)propertyWithTableInfo:(id<MDDTableInfo>)tableInfo name:(NSString *)name function:(MDDFunction)function alias:(NSString *)alias;

@end

@interface MDDSet : MDDDescriptor <MDDItem>

@property (nonatomic, strong, readonly) MDDDescriptor *descriptor;
@property (nonatomic, copy, readonly) NSString *alias;

@property (nonatomic, copy, readonly) NSString *name;

+ (instancetype)set;
+ (instancetype)setWithTableInfo:(id<MDDTableInfo>)tableInfo;
+ (instancetype)setWithDescriptor:(MDDDescriptor *)descriptor;
+ (instancetype)setWithDescriptor:(MDDDescriptor *)descriptor alias:(NSString *)alias;

@end

@interface MDDValue : MDDItem

@end

@interface MDDConditionValue : MDDValue

@end

@interface NSString (MDDItem)<MDDItem>

@end

@interface NSNull (MDDItem)<MDDItem>

@end

@interface NSObject (MDDValue) <MDDItem>

@end
