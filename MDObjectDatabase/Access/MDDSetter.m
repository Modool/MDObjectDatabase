
//
//  MDDSetter.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDSetter.h"
#import "MDDKeyValueDescriptor+Private.h"

#import "MDDColumn.h"
#import "MDDObject.h"
#import "MDDTableInfo.h"
#import "MDDTokenDescription.h"

@implementation MDDSetter

+ (instancetype)setterWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value;{
    return [self setterWithKey:key value:value transform:nil operation:MDDOperationEqual];
}

+ (instancetype)setterWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value operation:(MDDOperation)operation;{
    return [self setterWithKey:key value:value transform:nil operation:operation];
}

+ (instancetype)setterWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value transform:(NSString *)transform operation:(MDDOperation)operation;{
    return [[self alloc] initWithKey:key value:value transform:transform operation:operation];
}

- (instancetype)initWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value transform:(NSString *)transform operation:(MDDOperation)operation;{
    NSParameterAssert(operation != MDDOperationGreaterThan);
    NSParameterAssert(operation != MDDOperationGreaterThanOrEqual);
    NSParameterAssert(operation != MDDOperationLessThan);
    NSParameterAssert(operation != MDDOperationLessThanOrEqual);
    
    NSParameterAssert(operation != MDDOperationLike);
    NSParameterAssert(operation != MDDOperationIn);
    if (self = [super initWithKey:key value:value]) {
        _transform = transform;
        _operation = operation;
    }
    return self;
}

- (NSString *)descriptionWithTableInfo:(MDDTableInfo *)tableInfo value:(id *)value{
    NSParameterAssert(tableInfo);
    
    MDDColumn *column = [tableInfo columnForKey:[self key]];
    NSParameterAssert(column);
    
    id resultValue = [column transformValue:[self value]];
    *value = resultValue;
    
    return [self descriptionWithColumnName:[column name] value:resultValue transform:[self transform] operation:[self operation]];
}

- (NSString *)descriptionWithColumnName:(NSString *)columnName value:(id)value transform:(NSString *)transform operation:(MDDOperation)operation{
    Class requireValueClass = MDOperationValueRequireClass(operation);
    NSParameterAssert(!requireValueClass || [value isKindOfClass:requireValueClass]);
    
    NSString *equalDescription = MDOperationDescription(MDDOperationEqual);
    NSString *operationDescription = MDOperationDescription(operation);
    
    if (operation == MDDOperationEqual) {
        return [NSString stringWithFormat:@" %@ %@ %@ ", columnName, equalDescription, MDDatabaseToken];
    } else {
        NSString *valueToken = MDDatabaseToken;
        if (transform) {
            valueToken = [NSString stringWithFormat:@" (%@ %@) ", transform, MDDatabaseToken];
        }
        // (column = (column + ?))
        // (column = (column + (transform ?)))
        return [NSString stringWithFormat:@" %@ %@ (%@ %@ %@) ", columnName, equalDescription, columnName, operationDescription, valueToken];
    }
}

+ (NSArray<MDDSetter *> *)settersWithModel:(NSObject<MDDObject> *)model tableInfo:(MDDTableInfo *)tableInfo;{
    return [self settersWithModel:model properties:nil ignoredProperties:nil tableInfo:tableInfo];
}

+ (NSArray<MDDSetter *> *)settersWithModel:(NSObject<MDDObject> *)model properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties tableInfo:(MDDTableInfo *)tableInfo;{
    NSParameterAssert(model && tableInfo);
    
    NSMutableArray<MDDSetter *> *setters = [NSMutableArray<MDDSetter *> new];
    for (MDDColumn *column in [tableInfo columns]) {
        if (ignoredProperties && [ignoredProperties count] && [ignoredProperties containsObject:[column propertyName]]) continue;
        else if (properties && [properties count] && ![properties containsObject:[column propertyName]])  continue;
        
        MDDSetter *setter = [self setterWithKey:[column propertyName] value:[model valueForKey:[column  propertyName]]];
        if (!setter) continue;
        
        [setters addObject:setter];
    }
    
    return [setters copy];
}

@end
