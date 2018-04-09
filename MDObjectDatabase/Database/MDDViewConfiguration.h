//
//  MDDViewConfiguration.h
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/30.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDTableConfiguration.h"

@protocol MDDObject;
@class MDDColumn, MDDTableInfo, MDDatabase, MDDConditionSet;
@interface MDDViewConfiguration : NSObject<MDDTableConfiguration>

@property (nonatomic, strong, readonly) Class<MDDObject> objectClass;

@property (nonatomic, copy, readonly) NSString *name;

@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *propertyMapper;

@property (nonatomic, copy, readonly) NSDictionary<NSString *, MDDColumn *> *propertyColumns;

@property (nonatomic, copy, readonly) MDDConditionSet *conditionSet;

+ (instancetype)configurationWithClass:(Class<MDDObject>)class;
+ (instancetype)configurationWithClass:(Class<MDDObject>)class name:(NSString *)name;
+ (instancetype)configurationWithClass:(Class<MDDObject>)class name:(NSString *)name propertyMapper:(NSDictionary<NSString *, NSString *> *)propertyMapper;
+ (instancetype)configurationWithClass:(Class<MDDObject>)class name:(NSString *)name propertyMapper:(NSDictionary<NSString *, NSString *> *)propertyMapper propertyColumns:(NSDictionary<NSString *, MDDColumn *> *)propertyColumns;
+ (instancetype)configurationWithClass:(Class<MDDObject>)class name:(NSString *)name propertyMapper:(NSDictionary<NSString *, NSString *> *)propertyMapper propertyColumns:(NSDictionary<NSString *, MDDColumn *> *)propertyColumns conditionSet:(MDDConditionSet *)conditionSet;

- (BOOL)addColumn:(MDDColumn *)column asPropertyNamed:(NSString *)toPropertyName error:(NSError **)error;

@end
