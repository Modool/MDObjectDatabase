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

@protocol MDDKey <MDDItem>
@end

@interface MDDKey : MDDDescriptor <MDDKey>

@property (nonatomic, strong, readonly) MDDDescriptor *descriptor;
@property (nonatomic, copy, readonly) NSString *alias;

@property (nonatomic, copy, readonly) NSSet *keys;

+ (instancetype)keyWithDescriptor:(MDDDescriptor *)descriptor;
+ (instancetype)keyWithDescriptor:(MDDDescriptor *)descriptor alias:(NSString *)alias;

+ (instancetype)keyWithTableInfo:(MDDTableInfo *)tableInfo keys:(NSSet<NSString *> *)keys;

@end

@interface MDDFuntionKey : MDDKey

@property (nonatomic, copy, readonly) NSString *function;

+ (instancetype)keyWithTableInfo:(MDDTableInfo *)tableInfo key:(NSString *)key function:(MDDFunction)function;
+ (instancetype)keyWithTableInfo:(MDDTableInfo *)tableInfo key:(NSString *)key function:(MDDFunction)function alias:(NSString *)alias;

@end

@interface MDDSet : MDDDescriptor <MDDItem>

@property (nonatomic, strong, readonly) MDDDescriptor *descriptor;
@property (nonatomic, copy, readonly) NSString *alias;

+ (instancetype)set;
+ (instancetype)setWithTableInfo:(MDDTableInfo *)tableInfo;
+ (instancetype)setWithDescriptor:(MDDDescriptor *)descriptor;
+ (instancetype)setWithDescriptor:(MDDDescriptor *)descriptor alias:(NSString *)alias;

@end

@interface MDDValue : MDDKey

@end

@interface NSString (MDDKey)<MDDKey>

@end

@interface NSNull (MDDKey)<MDDItem>

@end

@interface NSObject (MDDValue) <MDDItem>

@end
