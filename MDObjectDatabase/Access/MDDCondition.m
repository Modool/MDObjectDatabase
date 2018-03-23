
//
//  MDDCondition.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDCondition.h"
#import "MDDColumn.h"
#import "MDDTableInfo.h"


@implementation NSArray (MDDatabaseSetValue)

- (NSArray *)MDDConditionMap:(id (^)(id object))map{
    NSParameterAssert(map);
    NSMutableArray *array = [NSMutableArray new];
    for (id object in self) {
        id result = map(object) ?: [NSNull null];
        
        [array addObject:result];
    }
    return array;
}
@end

@implementation MDDCondition

+ (instancetype)conditionWithPrimaryValue:(id<NSObject, NSCopying>)value;{
    return [self conditionWithPrimaryValue:value operation:MDDOperationEqual];
}

+ (instancetype)conditionWithPrimaryValue:(id<NSObject, NSCopying>)value operation:(MDDOperation)operation;{
    return [self conditionWithKey:nil value:value operation:operation];
}

+ (instancetype)conditionWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value;{
    return [self conditionWithKey:key value:value operation:MDDOperationEqual];
}

+ (instancetype)conditionWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value operation:(MDDOperation)operation;{
    return [[self alloc] initWithKey:key value:value operation:operation];
}

- (instancetype)initWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value operation:(MDDOperation)operation;{
    value = [value isKindOfClass:[NSSet class]] ? [(NSSet *)value allObjects] : value;
    
    if ([value isKindOfClass:[NSArray class]]) {
        BOOL isSetOperation = (operation == MDDOperationIn || operation == MDDOperationNotIn);
        NSArray *values = (id)value;
        
        operation = [values count] > 1 ? (isSetOperation ? operation : MDDOperationIn) : (isSetOperation ? MDDOperationEqual : operation);
        value = [values count] > 1 ? value : [values firstObject];
    }
    
    if (self = [super initWithKey:key value:value = value ?: [NSNull null]]) {
        _operation = operation;
    }
    return self;
}

#pragma mark - compare

- (BOOL)isEqual:(MDDCondition *)object{
    if (object == self) return self;
    if ([super isEqual:object]) return YES;
    if (![object isKindOfClass:[MDDCondition class]]) return NO;
    if ([object operation] != [self operation]) return NO;
    
    return ([object key] == [self key] || [[object key] isEqual:[self key]]) && ([object value] == [self value] || [[object value] isEqual:[self value]]);
}

- (NSUInteger)hash{
    return [self operation] ^ [[self key] hash] ^ [[self value] hash];
}

#pragma mark - public

- (NSString *)descriptionWithTableInfo:(MDDTableInfo *)tableInfo value:(id *)value{
    NSParameterAssert(tableInfo);
    
    MDDColumn *column = [tableInfo columnForKey:[self key]];
    NSParameterAssert(column);
    
    id resultValue = [self value];
    BOOL set = ([resultValue isKindOfClass:[NSArray class]] || [resultValue isKindOfClass:[NSSet class]]);
    
    resultValue = set ? resultValue : [column transformValue:resultValue];
    *value = resultValue;
    
    return [self descriptionWithColumnName:[column name] value:resultValue operation:[self operation]];
}

- (NSString *)descriptionWithColumnName:(NSString *)columnName value:(id)value operation:(MDDOperation)operation{
    Class requireValueClass = MDOperationValueRequireClass(operation);
    NSParameterAssert(!requireValueClass || [value isKindOfClass:requireValueClass]);
    
    NSString *operationDescription = MDOperationDescription(operation);
    BOOL isSetOperation = (operation == MDDOperationIn || operation == MDDOperationNotIn);
    if (isSetOperation) {
        NSArray *tokens = [(NSArray *)value MDDConditionMap:^id(id object) {
            return MDDatabaseToken;
        }];
        return [NSString stringWithFormat:@" %@ %@ ( %@ ) ", columnName, operationDescription, [tokens componentsJoinedByString:@","]];
    } else {
        return [self descriptionWithColumnName:columnName operationDescription:operationDescription];
    }
}

- (NSString *)descriptionWithColumnName:(NSString *)columnName operationDescription:(NSString *)operationDescription{
    return [NSString stringWithFormat:@" %@ %@ ? ", columnName, operationDescription];
}

@end

