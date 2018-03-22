//
//  MDDatabaseDescriptor.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/29.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDatabaseObject.h"
#import "MDDatabaseAccessorConstants.h"

#import "MDDatabaseRange.h"

@class MDDatabaseTableInfo;

@interface MDDatabaseClassInfo : NSObject

@property (nonatomic, strong, readonly) Class class;
@property (nonatomic, strong, readonly) NSString *aliasSuffix;

@property (nonatomic, strong, readonly) NSString *tableName;

+ (instancetype)classInfoWithClass:(Class<MDDatabaseObject>)class;
+ (instancetype)classInfoWithClass:(Class<MDDatabaseObject>)class aliasSuffix:(NSString *)aliasSuffix;
- (instancetype)initWithClass:(Class<MDDatabaseObject>)class aliasSuffix:(NSString *)aliasSuffix;

@end

@interface MDDatabaseTokenDescription : NSObject 

@property (nonatomic, copy, readonly) NSString *tokenString; // Token with ?

@property (nonatomic, copy, readonly) NSArray *values;

@property (nonatomic, copy, readonly) NSString *normalizeDescription;  // Token with value

+ (instancetype)descriptionWithTokenString:(NSString *)tokenString values:(NSArray *)values;

@end

@interface MDDatabaseDescriptor : NSObject

@end

@interface MDDatabaseKeyValueDescriptor : MDDatabaseDescriptor

@property (nonatomic, copy, readonly) NSString *key;

@property (nonatomic, copy, readonly) id<NSObject, NSCopying> value;

+ (instancetype)descriptorWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value;

@end

@interface MDDatabaseConditionDescriptor : MDDatabaseKeyValueDescriptor

@property (nonatomic, assign, readonly) MDDatabaseOperation operation;

+ (instancetype)conditionWithPrimaryValue:(id<NSObject, NSCopying>)value;
+ (instancetype)conditionWithPrimaryValue:(id<NSObject, NSCopying>)value operation:(MDDatabaseOperation)operation;

+ (instancetype)conditionWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value;
+ (instancetype)conditionWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value operation:(MDDatabaseOperation)operation;

@end

@interface MDDatabaseConditionSet : MDDatabaseDescriptor

// Default is MDDatabaseOperationConditionAnd
@property (nonatomic, assign, readonly) MDDatabaseConditionOperation operation;

@property (nonatomic, strong, readonly) MDDatabaseConditionSet *conditionSet;

@property (nonatomic, strong, readonly) NSArray<MDDatabaseConditionDescriptor *> *conditions;

+ (instancetype)setWithConditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;
+ (instancetype)setWithConditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions operation:(MDDatabaseConditionOperation)operation;

- (MDDatabaseConditionSet *)and:(MDDatabaseConditionDescriptor *)condition;
- (MDDatabaseConditionSet *)or:(MDDatabaseConditionDescriptor *)condition;

@end

@interface MDDatabaseConditionDescriptor (MDDatabaseConditionSet)

- (MDDatabaseConditionSet *)and:(MDDatabaseConditionDescriptor *)condition;
- (MDDatabaseConditionSet *)or:(MDDatabaseConditionDescriptor *)condition;

+ (NSArray<MDDatabaseConditionDescriptor *> *)conditionsWithKey:(NSString *)key integerRange:(MDIntegerRange)integerRange;
+ (NSArray<MDDatabaseConditionDescriptor *> *)conditionsWithKey:(NSString *)key integerRange:(MDIntegerRange)integerRange positive:(BOOL)positive;

+ (NSArray<MDDatabaseConditionDescriptor *> *)conditionsWithKey:(NSString *)key floatRange:(MDFloatRange)floatRange;
+ (NSArray<MDDatabaseConditionDescriptor *> *)conditionsWithKey:(NSString *)key floatRange:(MDFloatRange)floatRange positive:(BOOL)positive;

@end

@interface MDDatabaseSetterDescriptor : MDDatabaseKeyValueDescriptor

@property (nonatomic, copy, readonly) NSString *transform;

@property (nonatomic, assign, readonly) MDDatabaseOperation operation;

+ (instancetype)setterWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value;
+ (instancetype)setterWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value operation:(MDDatabaseOperation)operation;
+ (instancetype)setterWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value transform:(NSString *)transform operation:(MDDatabaseOperation)operation;

+ (NSArray<MDDatabaseSetterDescriptor *> *)settersWithModel:(NSObject<MDDatabaseObject> *)model tableInfo:(MDDatabaseTableInfo *)tableInfo;
+ (NSArray<MDDatabaseSetterDescriptor *> *)settersWithModel:(NSObject<MDDatabaseObject> *)model properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties tableInfo:(MDDatabaseTableInfo *)tableInfo;

@end

@interface MDDatabaseSortDescriptor : MDDatabaseKeyValueDescriptor

@property (nonatomic, assign, readonly) BOOL ascending;

+ (instancetype)sortWithKey:(NSString *)key ascending:(BOOL)ascending;

@end

@interface MDDatabaseQueryDescriptor : MDDatabaseDescriptor

@property (nonatomic, copy, readonly) NSSet<NSString *> *keys;

@property (nonatomic, copy, readonly) NSSet<NSString *> *indexKeys;

@property (nonatomic, copy, readonly) NSArray<MDDatabaseSortDescriptor *> *sorts;

@property (nonatomic, copy, readonly) NSArray<MDDatabaseConditionDescriptor *> *conditions;

+ (instancetype)query;
+ (instancetype)queryWithSorts:(NSArray<MDDatabaseSortDescriptor *> *)sorts;
+ (instancetype)queryWithConditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;

+ (instancetype)queryWithKeys:(NSSet<NSString *> *)keys;
+ (instancetype)queryWithKeys:(NSSet<NSString *> *)keys sorts:(NSArray<MDDatabaseSortDescriptor *> *)sorts;

+ (instancetype)queryWithKeys:(NSSet<NSString *> *)keys conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;
+ (instancetype)queryWithKeys:(NSSet<NSString *> *)keys sorts:(NSArray<MDDatabaseSortDescriptor *> *)sorts conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;

@end

//@interface MDDatabaseFunctionQueryDescriptor : MDDatabaseDescriptor
//
//@end

@interface MDDatabaseUpdaterDescriptor : MDDatabaseDescriptor

@property (nonatomic, copy, readonly) NSArray<MDDatabaseSetterDescriptor *> *setters;

@property (nonatomic, copy, readonly) NSArray<MDDatabaseConditionDescriptor *> *conditions;

+ (instancetype)updaterWithSetter:(NSArray<MDDatabaseSetterDescriptor *> *)setters;
+ (instancetype)updaterWithSetter:(NSArray<MDDatabaseSetterDescriptor *> *)setters conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;

+ (instancetype)updaterWithObject:(id<MDDatabaseObject>)object tableInfo:(MDDatabaseTableInfo *)tableInfo;
+ (instancetype)updaterWithObject:(id<MDDatabaseObject>)object properties:(NSSet *)properties tableInfo:(MDDatabaseTableInfo *)tableInfo;
+ (instancetype)updaterWithObject:(id<MDDatabaseObject>)object properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions tableInfo:(MDDatabaseTableInfo *)tableInfo;

@end

@interface MDDatabaseInsertSetterDescriptor : MDDatabaseKeyValueDescriptor

+ (instancetype)setterWithModel:(NSObject<MDDatabaseObject> *)model forPropertyWithName:(NSString *)propertyName tableInfo:(MDDatabaseTableInfo *)tableInfo;

+ (NSArray<MDDatabaseInsertSetterDescriptor *> *)settersWithModel:(NSObject<MDDatabaseObject> *)model tableInfo:(MDDatabaseTableInfo *)tableInfo;

@end

@interface MDDatabaseInserterDescriptor : MDDatabaseDescriptor

@property (nonatomic, copy, readonly) NSArray<MDDatabaseInsertSetterDescriptor *> *setters;

@property (nonatomic, copy, readonly) NSArray<MDDatabaseConditionDescriptor *> *conditions;

+ (instancetype)inserterWithSetter:(NSArray<MDDatabaseInsertSetterDescriptor *> *)setters;
+ (instancetype)inserterWithSetter:(NSArray<MDDatabaseInsertSetterDescriptor *> *)setters conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;

@end

@interface MDDatabaseDeleterDescriptor : MDDatabaseDescriptor

@property (nonatomic, copy, readonly) NSArray<MDDatabaseConditionDescriptor *> *conditions;

+ (instancetype)deleter;
+ (instancetype)deleterWithConditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;

@end

@interface MDDatabaseFunctionQuery : NSObject

@property (nonatomic, copy, readonly) NSString *key;
@property (nonatomic, copy, readonly) NSString *function;
@property (nonatomic, copy, readonly) NSArray<MDDatabaseConditionDescriptor *> *conditions;

+ (instancetype)functionQueryWithFunction:(NSString *)function conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;
+ (instancetype)functionQueryWithKey:(NSString *)key function:(NSString *)function conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;

+ (instancetype)sumFunctionQueryWithConditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;
+ (instancetype)sumFunctionQueryWithKey:(NSString *)key conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;

@end
