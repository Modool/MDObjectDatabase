//
//  MDDIndex.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/5.
//  Copyright © 2018年 modool. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDDIndex : NSObject

@property (nonatomic, assign, readonly, getter=isUnique) BOOL unique;

@property (nonatomic, copy, readonly) NSString *name;

// The maximum number of property is 6.
@property (nonatomic, copy, readonly) NSSet<NSString *> *propertyNames;

+ (instancetype)indexWithPropertyName:(NSString *)propertyName;
+ (instancetype)indexWithPropertyName:(NSString *)propertyName unique:(BOOL)unique;

+ (instancetype)indexWithName:(NSString *)name propertyName:(NSString *)propertyName;
+ (instancetype)indexWithName:(NSString *)name propertyName:(NSString *)propertyName unique:(BOOL)unique;

+ (instancetype)indexWithPropertyNames:(NSSet<NSString *> *)propertyNames;
+ (instancetype)indexWithName:(NSString *)name propertyNames:(NSSet<NSString *> *)propertyNames;

@end

@interface MDDLocalIndex : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *tableName;
@property (nonatomic, copy, readonly) NSString *SQL;

+ (instancetype)indexWithName:(NSString *)name tableName:(NSString *)tableName SQL:(NSString *)SQL;

@end
