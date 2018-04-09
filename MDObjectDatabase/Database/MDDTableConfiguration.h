//
//  MDDTableConfiguration.h
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/25.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MDDObject;
@class MDDIndex, MDDColumnConfiguration;

@protocol MDDTableConfiguration <NSObject>

@property (nonatomic, strong, readonly) Class<MDDObject> objectClass;

@property (nonatomic, copy, readonly) NSString *name;

@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *propertyMapper;

@end

@interface MDDTableConfiguration : NSObject<MDDTableConfiguration>

@property (nonatomic, strong, readonly) Class<MDDObject> objectClass;

@property (nonatomic, copy, readonly) NSString *name;

// It's invalid if multiple primary properties.
@property (nonatomic, assign, readonly) BOOL autoincrement;

@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *propertyMapper;

@property (nonatomic, copy, readonly) NSSet<NSString *> *primaryProperties;

// indexes
@property (nonatomic, copy, readonly) NSArray<MDDIndex *> *indexes;

+ (instancetype)configurationWithClass:(Class<MDDObject>)class primaryProperty:(NSString *)primaryProperty;
+ (instancetype)configurationWithClass:(Class<MDDObject>)class propertyMapper:(NSDictionary *)propertyMapper primaryProperty:(NSString *)primaryProperty;
+ (instancetype)configurationWithClass:(Class<MDDObject>)class name:(NSString *)name propertyMapper:(NSDictionary *)propertyMapper primaryProperty:(NSString *)primaryProperty;
+ (instancetype)configurationWithClass:(Class<MDDObject>)class name:(NSString *)name propertyMapper:(NSDictionary *)propertyMapper autoincrement:(BOOL)autoincrement primaryProperty:(NSString *)primaryProperty;
+ (instancetype)configurationWithClass:(Class<MDDObject>)class name:(NSString *)name propertyMapper:(NSDictionary *)propertyMapper autoincrement:(BOOL)autoincrement primaryProperty:(NSString *)primaryProperty indexes:(NSArray<MDDIndex *> *)indexes;

+ (instancetype)configurationWithClass:(Class<MDDObject>)class primaryProperties:(NSSet<NSString *> *)primaryProperties;
+ (instancetype)configurationWithClass:(Class<MDDObject>)class propertyMapper:(NSDictionary *)propertyMapper primaryProperties:(NSSet<NSString *> *)primaryProperties;
+ (instancetype)configurationWithClass:(Class<MDDObject>)class name:(NSString *)name propertyMapper:(NSDictionary *)propertyMapper primaryProperties:(NSSet<NSString *> *)primaryProperties;
+ (instancetype)configurationWithClass:(Class<MDDObject>)class name:(NSString *)name propertyMapper:(NSDictionary *)propertyMapper primaryProperties:(NSSet<NSString *> *)primaryProperties indexes:(NSArray<MDDIndex *> *)indexes;

- (BOOL)addColumnConfiguration:(MDDColumnConfiguration *)columnConfiguration forProperty:(NSString *)property error:(NSError **)error;

@end
