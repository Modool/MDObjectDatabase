
//
//  MDDSetter.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDSetter.h"
#import "MDDKeyValueDescriptor.h"
#import "MDDColumn.h"
#import "MDDObject.h"
#import "MDDTableInfo.h"
#import "MDDDescription.h"
#import "MDDItem.h"

@implementation MDDSetter

+ (instancetype)setterWithTableInfo:(MDDTableInfo *)tableInfo key:(NSString *)key value:(id<NSObject, NSCopying>)value;{
    return [self setterWithTableInfo:tableInfo key:key value:value transform:nil operation:MDDOperationEqual];
}

+ (instancetype)setterWithTableInfo:(MDDTableInfo *)tableInfo key:(NSString *)key value:(id<NSObject, NSCopying>)value operation:(MDDOperation)operation;{
    return [self setterWithTableInfo:tableInfo key:key value:value transform:nil operation:operation];
}

+ (instancetype)setterWithTableInfo:(MDDTableInfo *)tableInfo key:(NSString *)key value:(id<NSObject, NSCopying>)value transform:(NSString *)transform operation:(MDDOperation)operation;{
    NSParameterAssert(operation != MDDOperationGreaterThan);
    NSParameterAssert(operation != MDDOperationGreaterThanOrEqual);
    NSParameterAssert(operation != MDDOperationLessThan);
    NSParameterAssert(operation != MDDOperationLessThanOrEqual);
    
    NSParameterAssert(operation != MDDOperationLike);
    NSParameterAssert(operation != MDDOperationIn);
    MDDSetter *setter = [super descriptorWithTableInfo:tableInfo key:key value:value];
    setter->_transform = transform;
    setter->_operation = operation;
    
    return setter;
}

- (MDDDescription *)SQLDescription{
    id key = [self key];
    id value = [self value];
    
    MDDColumn *column = [[self tableInfo] columnForKey:key];
    NSParameterAssert(column);
    
    NSString *replacement = nil;
    NSMutableArray *values = [NSMutableArray array];
    if ([value isKindOfClass:[MDDValue class]]) {
        MDDValue *_value = value;
        MDDDescription *description = [_value SQLDescription];
        
        replacement = [NSString stringWithFormat:@" ( %@ ) ", [description SQL]];
        [values addObject:[description values]];
    } else {
        value = [column transformValue:value];
        value = value ?: [NSNull null];
        
        [values addObject:value];
    }
    
    NSString *SQL = [self SQLWithColumn:column value:value replacement:replacement];
    
    return [MDDDescription descriptionWithSQL:SQL values:values];
}

- (NSString *)SQLWithColumn:(MDDColumn *)column value:(id)value replacement:(NSString *)replacement{
    Class requireValueClass = MDOperationValueRequireClass([self operation]);
    NSParameterAssert(!requireValueClass || [value isKindOfClass:requireValueClass] || [value isKindOfClass:[MDDValue class]]);
    
    NSString *equalDescription = MDOperationDescription(MDDOperationEqual);
    NSString *operationDescription = MDOperationDescription([self operation]);
    
    NSString *transform = [self transform];
    replacement = replacement ?: MDDatabaseToken;
    
    if ([self operation] == MDDOperationEqual) {
        return [NSString stringWithFormat:@" %@ %@ %@ ", column.name, equalDescription, replacement];
    } else {
        if (transform) {
            replacement = [NSString stringWithFormat:@" (%@ %@) ", transform, replacement];
        }
        // (column = (column + ?))
        // (column = (column + (transform ?)))
        return [NSString stringWithFormat:@" %@ %@ (%@ %@ %@) ", column.name, equalDescription, column.name, operationDescription, replacement];
    }
}

+ (NSArray<MDDSetter *> *)settersWithObject:(id)object tableInfo:(MDDTableInfo *)tableInfo;{
    return [self settersWithObject:object properties:nil ignoredProperties:nil tableInfo:tableInfo];
}

+ (NSArray<MDDSetter *> *)settersWithObject:(id)object properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties tableInfo:(MDDTableInfo *)tableInfo;{
    NSParameterAssert(object && tableInfo);
    
    NSMutableArray<MDDSetter *> *setters = [NSMutableArray<MDDSetter *> array];
    for (MDDColumn *column in [tableInfo columns]) {
        if (ignoredProperties && [ignoredProperties count] && [ignoredProperties containsObject:[column propertyName]]) continue;
        else if (properties && [properties count] && ![properties containsObject:[column propertyName]])  continue;
        
        MDDSetter *setter = [self setterWithTableInfo:tableInfo key:[column propertyName] value:[object valueForKey:[column  propertyName]]];
        if (!setter) continue;
        
        [setters addObject:setter];
    }
    
    return [setters copy];
}

+ (MDDDescription *)descriptionWithSetters:(NSArray<MDDSetter *> *)setters{
    return [self descriptionWithDescriptors:setters separator:@" , "];
}

- (NSString *)description{
    return [[self dictionaryWithValuesForKeys:@[@"key", @"value", @"operation", @"transform"]] description];
}

@end
