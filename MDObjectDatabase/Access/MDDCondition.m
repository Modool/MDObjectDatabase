
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
#import "MDDItem.h"
#import "MDDDescription.h"
#import "MDDObject+Private.h"

@implementation MDDCondition

+ (instancetype)conditionWithTableInfo:(MDDTableInfo *)tableInfo primaryValue:(id<NSObject, NSCopying>)value;{
    return [self conditionWithTableInfo:tableInfo primaryValue:value operation:MDDOperationEqual];
}

+ (instancetype)conditionWithTableInfo:(MDDTableInfo *)tableInfo primaryValue:(id<NSObject, NSCopying>)value operation:(MDDOperation)operation;{
    return [self conditionWithTableInfo:tableInfo key:nil value:value operation:operation];
}

+ (instancetype)conditionWithTableInfo:(MDDTableInfo *)tableInfo key:(id<MDDItem>)key value:(id<NSObject, NSCopying>)value;{
    return [self conditionWithTableInfo:tableInfo key:key value:value operation:MDDOperationEqual];
}

+ (instancetype)conditionWithTableInfo:(MDDTableInfo *)tableInfo key:(id<MDDItem>)key value:(id<NSObject, NSCopying>)value operation:(MDDOperation)operation;{
    return [self conditionWithTableInfo:tableInfo key:key value:value operation:operation transform:nil];
}

+ (instancetype)conditionWithTableInfo:(MDDTableInfo *)tableInfo key:(id<MDDItem>)key value:(id<NSObject, NSCopying>)value operation:(MDDOperation)operation transform:(NSString *)transform;{
    return [self conditionWithTableInfo:tableInfo key:key value:value operation:operation transforms:transform ? @[transform] : nil];
}

+ (instancetype)conditionWithTableInfo:(MDDTableInfo *)tableInfo key:(id<MDDItem>)key value:(id<NSObject, NSCopying>)value operation:(MDDOperation)operation transforms:(NSArray<NSString *> *)transforms;{
    value = [value isKindOfClass:[NSSet class]] ? [(NSSet *)value allObjects] : value;
    
    if ([value isKindOfClass:[NSArray class]]) {
        BOOL isSetOperation = (operation == MDDOperationIn || operation == MDDOperationNotIn);
        NSArray *values = (id)value;
        
        operation = [values count] > 1 ? (isSetOperation ? operation : MDDOperationIn) : (isSetOperation ? MDDOperationEqual : operation);
        value = [values count] > 1 ? value : [values firstObject];
    }
    MDDCondition *condition = [super descriptorWithTableInfo:tableInfo key:key value:value = value ?: [NSNull null]];
    condition->_operation = operation;
    condition->_transforms = [transforms copy];
        
    return condition;
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

- (NSString *)description{
    return [[self dictionaryWithValuesForKeys:@[@"key", @"value", @"operation"]] description];
}

#pragma mark - public

- (MDDDescription *)SQLDescription{
    id key = [self key];
    id value = [self value];
    
    MDDColumn *column = nil;
    NSString *columnName = nil;
    NSString *replacement = nil;
    NSMutableArray *values = [NSMutableArray array];
    
    if ([[self key] isKindOfClass:[MDDKey class]]) {
        MDDKey *_key = key;
        MDDDescription *descrition = [_key SQLDescription];
        
        columnName = [NSString stringWithFormat:@" ( %@ ) ", [descrition SQL]];
        [values addObjectsFromArray:[descrition values]];
    } else {
        column = [self.tableInfo columnForKey:self.key];
        NSParameterAssert(column);
        
        columnName = column.name;
    }
    if ([[self value] isKindOfClass:[MDDValue class]]) {
        MDDValue *_value = value;
        MDDDescription *descrition = [_value SQLDescription];
        
        replacement = [NSString stringWithFormat:@" ( %@ ) ", [descrition SQL]];
        [values addObjectsFromArray:[descrition values]];
    } else if (column){
        BOOL set = ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSSet class]]);
        
        value = set ? value : [column transformValue:value];
        value = value ?: [NSNull null];
        
        if (![_transforms count]) [values addObject:value];
    }
    
    for (NSString *tranform in _transforms) {
        columnName = [NSString stringWithFormat:@"(%@ %@)", columnName, tranform];
    }
    
    NSString *token = MDDatabaseToken;
    BOOL isSetOperation = (_operation == MDDOperationIn || _operation == MDDOperationNotIn);
    if (isSetOperation) {
        NSArray *tokens = [(NSArray *)value MDDItemMap:^id(id object) {
            return MDDatabaseToken;
        }];
        token = [NSString stringWithFormat:@"( %@ )", [tokens componentsJoinedByString:@","]];
    } else if ([_transforms count]){
        token = [value description];
    }
    
    NSString *SQL = [self SQLWithColumnName:columnName value:value replacement:replacement token:token];
    return [MDDDescription descriptionWithSQL:SQL values:values];
}

- (NSString *)SQLWithColumnName:(NSString *)columnName value:(id)value replacement:(NSString *)replacement token:(NSString *)token{
    Class requireValueClass = MDOperationValueRequireClass(_operation);
    NSParameterAssert(!requireValueClass || [value isKindOfClass:requireValueClass] || [replacement length]);
    
    NSString *operationText = MDOperationDescription(_operation);
    BOOL exchangePosition = MDOperationShoulExchangePosition(_operation);
    if (exchangePosition) {
        NSString *temp = columnName; columnName = operationText; operationText = temp;
        replacement = @"";
        token = @"";
    }
    if (![replacement length]) {
        return [NSString stringWithFormat:@" %@ %@ %@ ", columnName, operationText, token];
    } else {
        return [NSString stringWithFormat:@" %@ %@ %@ ", columnName, operationText, replacement];
    }
}

+ (MDDDescription *)descriptionWithConditions:(NSArray<MDDCondition *> *)conditions operation:(MDDConditionOperation)operation;{
    NSString *operationDescription = MDConditionOperationDescription(operation);
    return [super descriptionWithDescriptors:conditions separator:[NSString stringWithFormat:@" %@ ", operationDescription]];
}

@end

