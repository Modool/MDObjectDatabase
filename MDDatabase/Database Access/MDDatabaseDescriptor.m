//
//  MDDatabaseDescriptor.m
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/29.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDatabaseDescriptor.h"
#import "MDDatabaseDescriptor+Private.h"

#import "MDDatabaseTableInfo.h"
#import "MDPropertyAttributes.h"
#import "MDDatabaseColumn.h"

NSString *MDOperationDescription(MDDatabaseOperation operation){
    switch (operation) {
        case MDDatabaseOperationEqual: return @"=";
        case MDDatabaseOperationNotEqual: return @"!=";
        case MDDatabaseOperationGreaterThan: return @">";
        case MDDatabaseOperationGreaterThanOrEqual: return @">=";
        case MDDatabaseOperationLessThan: return @"<";
        case MDDatabaseOperationLessThanOrEqual: return @"<=";
        case MDDatabaseOperationLike: return @"LIKE";
        case MDDatabaseOperationNotLike: return @"NOT LIKE";
        case MDDatabaseOperationIn: return @"IN";
        case MDDatabaseOperationNotIn: return @"NOT IN";
            
        case MDDatabaseOperationByteOr: return @"|";
        case MDDatabaseOperationByteAnd: return @"&";
        case MDDatabaseOperationByteNot: return @"~";
        case MDDatabaseOperationByteLeft: return @"<<";
        case MDDatabaseOperationByteRight: return @">>";
        case MDDatabaseOperationAdd: return @"+";
        case MDDatabaseOperationMinus: return @"-";
        case MDDatabaseOperationMultiply: return @"*";
        case MDDatabaseOperationDivide: return @"/";
        default: return nil;
    }
}

NSString *MDConditionOperationDescription(MDDatabaseConditionOperation operation){
    switch (operation) {
        case MDDatabaseConditionOperationAnd: return @"AND";
        case MDDatabaseConditionOperationOr: return @"OR";
        default: return nil;
    }
}

Class MDOperationValueRequireClass(MDDatabaseOperation operation){
    switch (operation) {
        case MDDatabaseOperationGreaterThan:
        case MDDatabaseOperationGreaterThanOrEqual:
        case MDDatabaseOperationLessThan:
        case MDDatabaseOperationLessThanOrEqual:
        case MDDatabaseOperationByteOr:
        case MDDatabaseOperationByteAnd:
        case MDDatabaseOperationByteNot:
        case MDDatabaseOperationByteLeft:
        case MDDatabaseOperationByteRight: return [NSNumber class];
        case MDDatabaseOperationLike:
        case MDDatabaseOperationNotLike: return [NSString class];
        case MDDatabaseOperationIn:
        case MDDatabaseOperationNotIn: return [NSArray class];
        default: return nil;
    }
}

@implementation NSArray (MDDatabaseSetValue)

- (NSArray *)databaseConditionMap:(id (^)(id object))map{
    NSParameterAssert(map);
    NSMutableArray *array = [NSMutableArray new];
    for (id object in self) {
        id result = map(object) ?: [NSNull null];
        
        [array addObject:result];
    }
    return array;
}
@end

@implementation MDDatabaseClassInfo{
    NSString *_tableName;
}

+ (instancetype)classInfoWithClass:(Class<MDDatabaseObject>)class;{
    return [self classInfoWithClass:class aliasSuffix:nil];
}

+ (instancetype)classInfoWithClass:(Class<MDDatabaseObject>)class aliasSuffix:(NSString *)aliasSuffix;{
    return [[self alloc] initWithClass:class aliasSuffix:aliasSuffix];
}

- (instancetype)initWithClass:(Class<MDDatabaseObject>)class aliasSuffix:(NSString *)aliasSuffix;{
    if (self = [super init]) {
        _class = class;
        _aliasSuffix = aliasSuffix;
        _tableName = [class tableName];
    }
    return self;
}

- (NSString *)tableName{
    if ([self aliasSuffix]) {
        return [_tableName stringByAppendingString:[self aliasSuffix]];
    }
    return [_tableName copy];
}

@end

@implementation MDDatabaseTokenDescription{
    NSString *_normalizeDescription;
}

+ (instancetype)descriptionWithTokenString:(NSString *)tokenString values:(NSArray *)values{
    NSParameterAssert(tokenString);
    
    MDDatabaseTokenDescription *description = [self new];
    description->_tokenString = [tokenString copy];
    description->_values = [values ?: @[] copy];
    
    return description;
}

- (NSString *)normalizeDescription{
    if (!_normalizeDescription) {
        NSUInteger index = 0;
        NSMutableString *tokenString = [[self tokenString] mutableCopy];
        NSScanner *scanner = [[NSScanner alloc] initWithString:tokenString];
        while ([scanner scanUpToString:MDDatabaseToken intoString:nil]) {
            NSString *value = [self values][index];
            
            BOOL isStringValue = [value isKindOfClass:[NSString class]] && ![[[NSNumberFormatter alloc] init] numberFromString:value];
            value = isStringValue ? [NSString stringWithFormat:@"'%@'", value] : [value description];
            
            [tokenString replaceCharactersInRange:NSMakeRange([scanner scanLocation], [MDDatabaseToken length]) withString:value];
            index++;
        }
        _normalizeDescription = tokenString;
    }
    return _normalizeDescription;
}

@end

@implementation MDDatabaseDescriptor

- (NSString *)descriptionWithClass:(Class<MDDatabaseObject>)class tableInfo:(MDDatabaseTableInfo *)tableInfo value:(id *)value;{
    return nil;
}

@end

@implementation MDDatabaseKeyValueDescriptor

+ (instancetype)descriptorWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value;{
    return [[self alloc] initWithKey:key value:value];
}

- (instancetype)initWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value;{
    if (self = [super init]) {
        _key = key;
        _value = [value isKindOfClass:[NSSet class]] ? [(NSSet *)value allObjects] : value;
    }
    return self;
}

- (NSString *)descriptionWithClass:(Class<MDDatabaseObject>)class tableInfo:(MDDatabaseTableInfo *)tableInfo value:(id *)value{
    return nil;
}

+ (MDDatabaseTokenDescription *)descriptionWithClass:(Class<MDDatabaseObject>)class descriptors:(NSArray<MDDatabaseKeyValueDescriptor *> *)descriptors separator:(NSString *)separator tableInfo:(MDDatabaseTableInfo *)tableInfo{
    if (!descriptors && ![descriptors count]) return nil;
    
    NSMutableArray *descriptions = [NSMutableArray new];
    NSMutableArray *values = [NSMutableArray new];
    for (MDDatabaseKeyValueDescriptor *descriptor in descriptors) {
        id value = [descriptor value];
        NSString *description = [descriptor descriptionWithClass:class tableInfo:tableInfo value:&value];
        
        if ([description length]) {
            [descriptions addObject:description];
            if ([value isKindOfClass:[NSArray class]]) {
                [values addObjectsFromArray:(NSArray *)value];
            } else {
                [values addObject:value ?: [NSNull null]];
            }
        }
    }
    if (![descriptions count]) return nil;
    
    return [MDDatabaseTokenDescription descriptionWithTokenString:[descriptions componentsJoinedByString:separator] values:values];
}

@end

@implementation MDDatabaseConditionDescriptor

+ (instancetype)conditionWithPrimaryValue:(id<NSObject, NSCopying>)value;{
    return [self conditionWithPrimaryValue:value operation:MDDatabaseOperationEqual];
}

+ (instancetype)conditionWithPrimaryValue:(id<NSObject, NSCopying>)value operation:(MDDatabaseOperation)operation;{
    return [self conditionWithKey:nil value:value operation:operation];
}

+ (instancetype)conditionWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value;{
    return [self conditionWithKey:key value:value operation:MDDatabaseOperationEqual];
}

+ (instancetype)conditionWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value operation:(MDDatabaseOperation)operation;{
    return [[self alloc] initWithKey:key value:value operation:operation];
}

- (instancetype)initWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value operation:(MDDatabaseOperation)operation;{
    value = [value isKindOfClass:[NSSet class]] ? [(NSSet *)value allObjects] : value;
    
    if ([value isKindOfClass:[NSArray class]]) {
        BOOL isSetOperation = (operation == MDDatabaseOperationIn || operation == MDDatabaseOperationNotIn);
        NSArray *values = (id)value;
        
        operation = [values count] > 1 ? (isSetOperation ? operation : MDDatabaseOperationIn) : (isSetOperation ? MDDatabaseOperationEqual : operation);
        value = [values count] > 1 ? value : [values firstObject];
    }
    
    if (self = [super initWithKey:key value:value = value ?: [NSNull null]]) {
        _operation = operation;
    }
    return self;
}

- (NSString *)descriptionWithClass:(Class<MDDatabaseObject>)class tableInfo:(MDDatabaseTableInfo *)tableInfo value:(id *)value{
    NSParameterAssert(class && tableInfo);
    
    MDDatabaseColumn *column = [tableInfo columnForKey:[self key]];
    NSParameterAssert(column);
    
    id resultValue = [self value];
    BOOL set = ([resultValue isKindOfClass:[NSArray class]] || [resultValue isKindOfClass:[NSSet class]]);
    
    resultValue = set ? resultValue : [column transformValue:resultValue];
    *value = resultValue;
    
    return [self descriptionWithColumnName:[column name] value:resultValue operation:[self operation]];
}

- (NSString *)descriptionWithColumnName:(NSString *)columnName value:(id)value operation:(MDDatabaseOperation)operation{
    Class requireValueClass = MDOperationValueRequireClass(operation);
    NSParameterAssert(!requireValueClass || [value isKindOfClass:requireValueClass]);
    
    NSString *operationDescription = MDOperationDescription(operation);
    BOOL isSetOperation = (operation == MDDatabaseOperationIn || operation == MDDatabaseOperationNotIn);
    if (isSetOperation) {
        NSArray *tokens = [(NSArray *)value databaseConditionMap:^id(id object) {
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

+ (MDDatabaseTokenDescription *)descriptionWithClass:(Class<MDDatabaseObject>)class conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions tableInfo:(MDDatabaseTableInfo *)tableInfo{
    return [super descriptionWithClass:class descriptors:conditions separator:@" AND " tableInfo:tableInfo];
}

@end

@interface MDDatabaseConditionSet ()

// Default is MDDatabaseConditionOperationAnd
@property (nonatomic, assign) MDDatabaseConditionOperation operation;

@property (nonatomic, strong) MDDatabaseConditionSet *conditionSet;

@property (nonatomic, strong) NSMutableArray<MDDatabaseConditionDescriptor *> *mutableConditions;

@end

@implementation MDDatabaseConditionSet

+ (instancetype)setWithConditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;{
    return [self setWithConditions:conditions operation:MDDatabaseConditionOperationAnd];
}

+ (instancetype)setWithConditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions operation:(MDDatabaseConditionOperation)operation;{
    return [self setWithConditions:conditions operation:operation conditionSet:nil];
}

+ (instancetype)setWithConditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions operation:(MDDatabaseConditionOperation)operation conditionSet:(MDDatabaseConditionSet *)conditionSet;{
    MDDatabaseConditionSet *set = [self new];
    set.operation = operation;
    set.conditionSet = conditionSet;
    
    if (conditions && [conditions count]) {
        [[set mutableConditions] addObjectsFromArray:conditions];
    }
    
    return set;
}

- (instancetype)init{
    if (self = [super init]) {
        self.operation = MDDatabaseConditionOperationAnd;
        self.mutableConditions = [NSMutableArray new];
    }
    return self;
}

- (MDDatabaseConditionSet *)and:(MDDatabaseConditionDescriptor *)condition;{
    NSParameterAssert(condition);
    
    if ([self operation] != MDDatabaseConditionOperationAnd) {
        return [[self class] setWithConditions:@[condition] operation:MDDatabaseConditionOperationAnd conditionSet:self];
    }
    
    [[self mutableConditions] addObject:condition];
    
    return self;
}

- (MDDatabaseConditionSet *)or:(MDDatabaseConditionDescriptor *)condition;{
    NSParameterAssert(condition);
    
    if ([self operation] != MDDatabaseConditionOperationOr) {
        return [[self class] setWithConditions:@[condition] operation:MDDatabaseConditionOperationOr conditionSet:self];
    }
    
    [[self mutableConditions] addObject:condition];
    
    return self;
}

- (MDDatabaseTokenDescription *)descriptionWithClass:(Class<MDDatabaseObject>)class tableInfo:(MDDatabaseTableInfo *)tableInfo;{
//    NSString *operationDescription = MDConditionOperationDescription([self operation]);
    
    return nil;
}

+ (MDDatabaseTokenDescription *)descriptionWithClass:(Class<MDDatabaseObject>)class conditionSet:(MDDatabaseConditionSet *)conditionSet tableInfo:(MDDatabaseTableInfo *)tableInfo;{
    return [conditionSet descriptionWithClass:class tableInfo:tableInfo];
}

@end

@implementation MDDatabaseConditionDescriptor (MDDatabaseConditionSet)

- (MDDatabaseConditionSet *)and:(MDDatabaseConditionDescriptor *)condition;{
    return [MDDatabaseConditionSet setWithConditions:@[condition, self] operation:MDDatabaseConditionOperationAnd];
}

- (MDDatabaseConditionSet *)or:(MDDatabaseConditionDescriptor *)condition;{
    return [MDDatabaseConditionSet setWithConditions:@[condition, self] operation:MDDatabaseConditionOperationOr];
}

+ (NSArray<MDDatabaseConditionDescriptor *> *)conditionsWithKey:(NSString *)key integerRange:(MDIntegerRange)integerRange;{
    return [self conditionsWithKey:key integerRange:integerRange positive:YES];
}

+ (NSArray<MDDatabaseConditionDescriptor *> *)conditionsWithKey:(NSString *)key integerRange:(MDIntegerRange)integerRange positive:(BOOL)positive;{
    MDDatabaseConditionDescriptor *condition1 = [self conditionWithKey:key value:@(integerRange.minimum) operation:positive ? MDDatabaseOperationGreaterThanOrEqual : MDDatabaseOperationLessThanOrEqual];
    MDDatabaseConditionDescriptor *condition2 = [self conditionWithKey:key value:@(integerRange.maximum) operation:positive ? MDDatabaseOperationLessThanOrEqual : MDDatabaseOperationGreaterThanOrEqual];
    
    return @[condition1, condition2];
}

+ (NSArray<MDDatabaseConditionDescriptor *> *)conditionsWithKey:(NSString *)key floatRange:(MDFloatRange)floatRange;{
    return [self conditionsWithKey:key floatRange:floatRange positive:YES];
}

+ (NSArray<MDDatabaseConditionDescriptor *> *)conditionsWithKey:(NSString *)key floatRange:(MDFloatRange)floatRange positive:(BOOL)positive;{
    MDDatabaseConditionDescriptor *condition1 = [self conditionWithKey:key value:@(floatRange.minimum) operation:positive ? MDDatabaseOperationGreaterThanOrEqual : MDDatabaseOperationLessThanOrEqual];
    MDDatabaseConditionDescriptor *condition2 = [self conditionWithKey:key value:@(floatRange.maximum) operation:positive ? MDDatabaseOperationLessThanOrEqual : MDDatabaseOperationGreaterThanOrEqual];
    
    return @[condition1, condition2];
}

@end

@implementation MDDatabaseSetterDescriptor

+ (instancetype)setterWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value;{
    return [self setterWithKey:key value:value transform:nil operation:MDDatabaseOperationEqual];
}

+ (instancetype)setterWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value operation:(MDDatabaseOperation)operation;{
    return [self setterWithKey:key value:value transform:nil operation:operation];
}

+ (instancetype)setterWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value transform:(NSString *)transform operation:(MDDatabaseOperation)operation;{
    return [[self alloc] initWithKey:key value:value transform:transform operation:operation];
}

- (instancetype)initWithKey:(NSString *)key value:(id<NSObject, NSCopying>)value transform:(NSString *)transform operation:(MDDatabaseOperation)operation;{
    NSParameterAssert(operation != MDDatabaseOperationGreaterThan);
    NSParameterAssert(operation != MDDatabaseOperationGreaterThanOrEqual);
    NSParameterAssert(operation != MDDatabaseOperationLessThan);
    NSParameterAssert(operation != MDDatabaseOperationLessThanOrEqual);
    
    NSParameterAssert(operation != MDDatabaseOperationLike);
    NSParameterAssert(operation != MDDatabaseOperationIn);
    if (self = [super initWithKey:key value:value]) {
        _transform = transform;
        _operation = operation;
    }
    return self;
}

- (NSString *)descriptionWithClass:(Class<MDDatabaseObject>)class tableInfo:(MDDatabaseTableInfo *)tableInfo value:(id *)value{
    NSParameterAssert(class && tableInfo);
    
    MDDatabaseColumn *column = [tableInfo columnForKey:[self key]];
    NSParameterAssert(column);
    
    id resultValue = [column transformValue:[self value]];
    *value = resultValue;
    
    return [self descriptionWithColumnName:[column name] value:resultValue transform:[self transform] operation:[self operation]];
}

- (NSString *)descriptionWithColumnName:(NSString *)columnName value:(id)value transform:(NSString *)transform operation:(MDDatabaseOperation)operation{
    Class requireValueClass = MDOperationValueRequireClass(operation);
    NSParameterAssert(!requireValueClass || [value isKindOfClass:requireValueClass]);
    
    NSString *equalDescription = MDOperationDescription(MDDatabaseOperationEqual);
    NSString *operationDescription = MDOperationDescription(operation);
    
    if (operation == MDDatabaseOperationEqual) {
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

+ (MDDatabaseTokenDescription *)descriptionWithClass:(Class<MDDatabaseObject>)class setters:(NSArray<MDDatabaseSetterDescriptor *> *)setters tableInfo:(MDDatabaseTableInfo *)tableInfo{
    return [self descriptionWithClass:class descriptors:setters separator:@" , " tableInfo:tableInfo];
}

+ (NSArray<MDDatabaseSetterDescriptor *> *)settersWithModel:(NSObject<MDDatabaseObject> *)model tableInfo:(MDDatabaseTableInfo *)tableInfo;{
    return [self settersWithModel:model properties:nil ignoredProperties:nil tableInfo:tableInfo];
}

+ (NSArray<MDDatabaseSetterDescriptor *> *)settersWithModel:(NSObject<MDDatabaseObject> *)model properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties tableInfo:(MDDatabaseTableInfo *)tableInfo;{
    NSParameterAssert(model && tableInfo);
    
    NSMutableArray<MDDatabaseSetterDescriptor *> *setters = [NSMutableArray<MDDatabaseSetterDescriptor *> new];
    for (MDDatabaseColumn *column in [tableInfo columns]) {
        if (ignoredProperties && [ignoredProperties count] && [ignoredProperties containsObject:[column propertyName]]) continue;
        else if (properties && [properties count] && ![properties containsObject:[column propertyName]])  continue;
        
        MDDatabaseSetterDescriptor *setter = [self setterWithKey:[column propertyName] value:[model valueForKey:[column  propertyName]]];
        if (!setter) continue;
        
        [setters addObject:setter];
    }
    
    return [setters copy];
}

@end

@implementation MDDatabaseSortDescriptor

+ (instancetype)sortWithKey:(NSString *)key ascending:(BOOL)ascending;{
    return [[self alloc] initWithKey:key ascending:ascending];
}

- (instancetype)initWithKey:(NSString *)key ascending:(BOOL)ascending;{
    if (self = [super initWithKey:key value:nil]) {
        _ascending = ascending;
    }
    return self;
}

- (NSString *)descriptionWithClass:(Class<MDDatabaseObject>)class tableInfo:(MDDatabaseTableInfo *)tableInfo value:(id *)value{
    NSParameterAssert(class && tableInfo);
    
    MDDatabaseColumn *column = [tableInfo columnForKey:[self key]];
    NSParameterAssert(column);
    
    return [NSString stringWithFormat:@"%@ %@", [column name], [self ascending] ? @"ASC" : @"DESC"];
}

+ (MDDatabaseTokenDescription *)descriptionWithClass:(Class<MDDatabaseObject>)class sorts:(NSArray<MDDatabaseSortDescriptor *> *)sorts tableInfo:(MDDatabaseTableInfo *)tableInfo{
    return [super descriptionWithClass:class descriptors:sorts separator:@" , "  tableInfo:tableInfo];
}

@end

@implementation MDDatabaseQueryDescriptor

+ (instancetype)query;{
    return [self queryWithKeys:nil sorts:nil conditions:nil];
}

+ (instancetype)queryWithSorts:(NSArray<MDDatabaseSortDescriptor *> *)sorts;{
    return [self queryWithKeys:nil sorts:sorts conditions:nil];
}

+ (instancetype)queryWithConditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;{
    return [self queryWithKeys:nil sorts:nil conditions:conditions];
}

+ (instancetype)queryWithKeys:(NSSet<NSString *> *)keys;{
    return [self queryWithKeys:keys sorts:nil conditions:nil];
}

+ (instancetype)queryWithKeys:(NSSet<NSString *> *)keys sorts:(NSArray<MDDatabaseSortDescriptor *> *)sorts;{
    return [self queryWithKeys:keys sorts:sorts conditions:nil];
}

+ (instancetype)queryWithKeys:(NSSet<NSString *> *)keys conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;{
    return [self queryWithKeys:keys sorts:nil conditions:conditions];
}

+ (instancetype)queryWithKeys:(NSSet<NSString *> *)keys sorts:(NSArray<MDDatabaseSortDescriptor *> *)sorts conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;{
    MDDatabaseQueryDescriptor *descriptor = [self new];
    descriptor->_keys = [keys copy];
    descriptor->_sorts = [sorts copy];
    descriptor->_conditions = [conditions copy];
    
    return descriptor;
}

- (NSString *)descriptionWithClass:(Class<MDDatabaseObject>)class tableInfo:(MDDatabaseTableInfo *)tableInfo{
    NSParameterAssert(class && tableInfo);
    
    NSMutableArray<NSString *> *columns = [NSMutableArray<NSString *> new];
    for (id key in [self keys]) {
        MDDatabaseColumn *column = [tableInfo columnForKey:key];
        NSParameterAssert(column);
        
        [columns addObject:[column name]];
    }
    
    NSString *keyString = [columns componentsJoinedByString:@", "];
    keyString = [keyString length] ? keyString : @" * ";
    
    MDDatabaseIndex *index = ([self conditions] && [[self conditions] count]) ? [tableInfo indexForConditions:[self conditions]] : nil;
    NSString *indexString = index ? [NSString stringWithFormat:@" INDEXED BY %@ ", [index name]] : @"";
    
    return [NSString stringWithFormat:@" SELECT %@ FROM %@ %@ ", keyString, [tableInfo tableName], indexString];
}

+ (MDDatabaseTokenDescription *)descriptionWithClass:(Class<MDDatabaseObject>)class query:(MDDatabaseQueryDescriptor *)query range:(NSRange)range tableInfo:(MDDatabaseTableInfo *)tableInfo;{
    NSParameterAssert(class && query && tableInfo);
    
    NSString *tokenString = [query descriptionWithClass:class tableInfo:tableInfo];
    
    MDDatabaseTokenDescription *conditionDescription = [MDDatabaseConditionDescriptor descriptionWithClass:class conditions:[query conditions] tableInfo:tableInfo];
    NSArray *values = [conditionDescription values];
    
    if (conditionDescription && [conditionDescription tokenString]) {
        tokenString = [tokenString stringByAppendingFormat:@" WHERE %@ ", [conditionDescription tokenString]];
    }
    
    MDDatabaseTokenDescription *sortDescription = [MDDatabaseSortDescriptor descriptionWithClass:class sorts:[query sorts] tableInfo:tableInfo];
    if (sortDescription) {
        tokenString = [tokenString stringByAppendingFormat:@"ORDER BY %@ ", [sortDescription tokenString] ?: @""];
    }
    
    if (range.location || range.length) {
        range.length = range.length ?: INT_MAX;
        tokenString = [tokenString stringByAppendingFormat:@"LIMIT %lu OFFSET %ld ", (unsigned long)range.length, (unsigned long)range.location];
    }
    
    return [MDDatabaseTokenDescription descriptionWithTokenString:tokenString values:values];
}

@end

//@implementation MDDatabaseFunctionQueryDescriptor
//
//@end

@implementation MDDatabaseUpdaterDescriptor

+ (instancetype)updaterWithSetter:(NSArray<MDDatabaseSetterDescriptor *> *)setters;{
    return [self updaterWithSetter:setters conditions:nil];
}

+ (instancetype)updaterWithSetter:(NSArray<MDDatabaseSetterDescriptor *> *)setters conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;{
    MDDatabaseUpdaterDescriptor *descriptor = [self new];
    descriptor->_setters = [setters copy];
    descriptor->_conditions = [conditions copy];
    
    return descriptor;
}

+ (instancetype)updaterWithObject:(id<MDDatabaseObject>)object tableInfo:(MDDatabaseTableInfo *)tableInfo;{
    return [self updaterWithObject:object properties:nil ignoredProperties:nil conditions:nil tableInfo:tableInfo];
}

+ (instancetype)updaterWithObject:(id<MDDatabaseObject>)object properties:(NSSet *)properties tableInfo:(MDDatabaseTableInfo *)tableInfo;{
    return [self updaterWithObject:object properties:properties ignoredProperties:nil conditions:nil tableInfo:tableInfo];
}

+ (instancetype)updaterWithObject:(id<MDDatabaseObject>)object properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions tableInfo:(MDDatabaseTableInfo *)tableInfo;{
    
    NSArray<MDDatabaseSetterDescriptor *> *setters = [MDDatabaseSetterDescriptor settersWithModel:object properties:properties ignoredProperties:ignoredProperties tableInfo:tableInfo];
    NSParameterAssert(setters && [setters count]);
    
    return [MDDatabaseUpdaterDescriptor updaterWithSetter:setters conditions:conditions];
}

- (NSString *)descriptionWithClass:(Class<MDDatabaseObject>)class tableInfo:(MDDatabaseTableInfo *)tableInfo{
    NSParameterAssert(class && tableInfo);
    
    return [NSString stringWithFormat:@" UPDATE %@ ", [tableInfo tableName]];
}

+ (MDDatabaseTokenDescription *)descriptionWithClass:(Class<MDDatabaseObject>)class updater:(MDDatabaseUpdaterDescriptor *)updater tableInfo:(MDDatabaseTableInfo *)tableInfo;{
    NSParameterAssert(class && updater && tableInfo);
    
    NSString *tokenString = [updater descriptionWithClass:class tableInfo:tableInfo];
    
    NSArray *values = @[];
    MDDatabaseTokenDescription *setterDescription = [MDDatabaseSetterDescriptor descriptionWithClass:class setters:[updater setters] tableInfo:tableInfo];
    NSParameterAssert(setterDescription);
    
    values = [values arrayByAddingObjectsFromArray:[setterDescription values]];
    tokenString = [tokenString stringByAppendingFormat:@" SET %@ ", [setterDescription tokenString]];
    
    MDDatabaseTokenDescription *conditionDescription = [MDDatabaseConditionDescriptor descriptionWithClass:class conditions:[updater conditions] tableInfo:tableInfo];
    if (conditionDescription && [conditionDescription tokenString]) {
        values = [values arrayByAddingObjectsFromArray:[conditionDescription values]];
        tokenString = [tokenString stringByAppendingFormat:@" WHERE %@ ", [conditionDescription tokenString]];
    }
    
    return [MDDatabaseTokenDescription descriptionWithTokenString:tokenString values:values];
}

+ (MDDatabaseTokenDescription *)descriptionWithObject:(id<MDDatabaseObject>)object tableInfo:(MDDatabaseTableInfo *)tableInfo;{
    return [self descriptionWithObject:object properties:nil ignoredProperties:nil conditions:nil tableInfo:tableInfo];
}

+ (MDDatabaseTokenDescription *)descriptionWithObject:(id<MDDatabaseObject>)object properties:(NSSet *)properties ignoredProperties:(NSSet *)ignoredProperties conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions tableInfo:(MDDatabaseTableInfo *)tableInfo;{
    NSParameterAssert(tableInfo);
    
    MDDatabaseUpdaterDescriptor *updater = [self updaterWithObject:object properties:properties ignoredProperties:ignoredProperties conditions:conditions tableInfo:tableInfo];
    NSParameterAssert(updater);
    
    return [self descriptionWithClass:[object class] updater:updater tableInfo:tableInfo];
}

@end

@implementation MDDatabaseInsertSetterDescriptor

+ (instancetype)setterWithModel:(NSObject<MDDatabaseObject> *)model forPropertyWithName:(NSString *)propertyName tableInfo:(MDDatabaseTableInfo *)tableInfo;{
    NSParameterAssert(model && [propertyName length] && tableInfo);
    
    return [self descriptorWithKey:propertyName value:[model valueForKey:propertyName]];
}

+ (NSArray<MDDatabaseInsertSetterDescriptor *> *)settersWithModel:(NSObject<MDDatabaseObject> *)model tableInfo:(MDDatabaseTableInfo *)tableInfo;{
    NSParameterAssert(model && tableInfo);
    
    NSMutableArray<MDDatabaseInsertSetterDescriptor *> *setters = [NSMutableArray<MDDatabaseInsertSetterDescriptor *> new];
    for (MDDatabaseColumn *column in [tableInfo columns]) {
        id value = [model valueForKey:[column propertyName]];
        
        if ([column isPrimary] && !value) continue;
        
        MDDatabaseInsertSetterDescriptor *setter = [self descriptorWithKey:[column propertyName] value:value];
        if (!setter) continue;
        
        [setters addObject:setter];
    }
    
    return [setters copy];
}

- (NSString *)descriptionWithClass:(Class<MDDatabaseObject>)class tableInfo:(MDDatabaseTableInfo *)tableInfo value:(id *)value{
    return @"";
}

+ (MDDatabaseTokenDescription *)descriptionWithClass:(Class<MDDatabaseObject>)class setters:(NSArray<MDDatabaseInsertSetterDescriptor *> *)setters tableInfo:(MDDatabaseTableInfo *)tableInfo;{
    NSParameterAssert(class && tableInfo);
    
    NSMutableArray<NSString *> *columns = [NSMutableArray<NSString *> new];
    NSMutableArray<NSString *> *tokens = [NSMutableArray<NSString *> new];
    NSMutableArray *values = [NSMutableArray new];
    
    for (MDDatabaseInsertSetterDescriptor *setter in setters) {
        id key = [setter key];
        id value = [setter value];
        
        MDDatabaseColumn *column = [tableInfo columnForKey:key];
        NSParameterAssert(column);
        value = [column transformValue:value];
        
        [columns addObject:[column name]];
        [values addObject:value ?: [NSNull null]];
        [tokens addObject:MDDatabaseToken];
    }
    
    NSString *tokenString = [NSString stringWithFormat:@" ( %@ ) VALUES ( %@ )", [columns componentsJoinedByString:@","], [tokens componentsJoinedByString:@","]];
    
    return [MDDatabaseTokenDescription descriptionWithTokenString:tokenString values:values];
}

@end

@implementation MDDatabaseInserterDescriptor

+ (instancetype)inserterWithSetter:(NSArray<MDDatabaseInsertSetterDescriptor *> *)setters;{
    return [self inserterWithSetter:setters conditions:nil];
}

+ (instancetype)inserterWithSetter:(NSArray<MDDatabaseInsertSetterDescriptor *> *)setters conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;{
    MDDatabaseInserterDescriptor *descriptor = [self new];
    descriptor->_setters = [setters copy];
    descriptor->_conditions = [conditions copy];
    
    return descriptor;
}

- (NSString *)descriptionWithClass:(Class<MDDatabaseObject>)class tableInfo:(MDDatabaseTableInfo *)tableInfo{
    NSParameterAssert(class && tableInfo);
    
    return [NSString stringWithFormat:@" INSERT INTO %@ ", [tableInfo tableName]];
}

+ (MDDatabaseTokenDescription *)descriptionWithClass:(Class<MDDatabaseObject>)class inserter:(MDDatabaseInserterDescriptor *)inserter tableInfo:(MDDatabaseTableInfo *)tableInfo;{
    NSParameterAssert(class && inserter && tableInfo);
    NSString *tokenString = [inserter descriptionWithClass:class tableInfo:tableInfo];
    
    NSArray *values = @[];
    MDDatabaseTokenDescription *setterDescription = [MDDatabaseInsertSetterDescriptor descriptionWithClass:class setters:[inserter setters] tableInfo:tableInfo];
    NSParameterAssert(setterDescription);
    
    values = [values arrayByAddingObjectsFromArray:[setterDescription values]];
    tokenString = [tokenString stringByAppendingString:[setterDescription tokenString]];
    
    if ([inserter conditions] && [[inserter conditions] count]) {
        MDDatabaseTokenDescription *conditionDescription = [MDDatabaseConditionDescriptor descriptionWithClass:class conditions:[inserter conditions] tableInfo:tableInfo];
        if (conditionDescription && [conditionDescription tokenString]) {
            values = [values arrayByAddingObjectsFromArray:[conditionDescription values]];
            tokenString = [tokenString stringByAppendingFormat:@" WHERE %@ ", [conditionDescription tokenString]];
        }
    }
    
    return [MDDatabaseTokenDescription descriptionWithTokenString:tokenString values:values];
}

+ (MDDatabaseInserterDescriptor *)inserterWithObject:(id<MDDatabaseObject>)object tableInfo:(MDDatabaseTableInfo *)tableInfo;{
    NSParameterAssert(object && tableInfo);
    
    NSArray<MDDatabaseInsertSetterDescriptor *> *setters = [MDDatabaseInsertSetterDescriptor settersWithModel:object tableInfo:tableInfo];
    NSParameterAssert(setters && [setters count]);
    
    return [MDDatabaseInserterDescriptor inserterWithSetter:setters];
}

+ (MDDatabaseTokenDescription *)descriptionWithObject:(id<MDDatabaseObject>)object tableInfo:(MDDatabaseTableInfo *)tableInfo;{
    MDDatabaseInserterDescriptor *inserter = [self inserterWithObject:object tableInfo:tableInfo];
    NSParameterAssert(inserter);
    
    return [self descriptionWithClass:[object class] inserter:inserter tableInfo:tableInfo];
}

@end

@implementation MDDatabaseDeleterDescriptor

+ (instancetype)deleter;{
    return [self deleterWithConditions:nil];
}

+ (instancetype)deleterWithConditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;{
    MDDatabaseDeleterDescriptor *descriptor = [self new];
    descriptor->_conditions = [conditions copy];
    
    return descriptor;
}

- (NSString *)descriptionWithClass:(Class<MDDatabaseObject>)class tableInfo:(MDDatabaseTableInfo *)tableInfo{
    NSParameterAssert(class && tableInfo);
    
    return [NSString stringWithFormat:@" DELETE FROM %@ ", [tableInfo tableName]];
}

+ (MDDatabaseTokenDescription *)descriptionWithClass:(Class<MDDatabaseObject>)class deleter:(MDDatabaseDeleterDescriptor *)deleter tableInfo:(MDDatabaseTableInfo *)tableInfo;{
    NSString *tokenString = [deleter descriptionWithClass:class tableInfo:tableInfo];
    
    NSArray *values = @[];
    MDDatabaseTokenDescription *conditionDescription = [MDDatabaseConditionDescriptor descriptionWithClass:class conditions:[deleter conditions] tableInfo:tableInfo];
    if (conditionDescription && [conditionDescription tokenString]) {
        values = [values arrayByAddingObjectsFromArray:[conditionDescription values]];
        tokenString = [tokenString stringByAppendingFormat:@" WHERE %@ ", [conditionDescription tokenString]];
    }
    
    return [MDDatabaseTokenDescription descriptionWithTokenString:tokenString values:values];
}

@end

@implementation MDDatabaseFunctionQuery

+ (instancetype)functionQueryWithFunction:(NSString *)function conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;{
    return [self functionQueryWithKey:nil function:function conditions:conditions];
}

+ (instancetype)functionQueryWithKey:(NSString *)key function:(NSString *)function conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;{
    MDDatabaseFunctionQuery *query = [[self alloc] init];
    query->_key = [key copy];
    query->_function = [function copy];
    query->_conditions = [conditions copy];
    
    return query;
}

+ (instancetype)sumFunctionQueryWithConditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;{
    return [self sumFunctionQueryWithKey:nil conditions:conditions];
}

+ (instancetype)sumFunctionQueryWithKey:(NSString *)key conditions:(NSArray<MDDatabaseConditionDescriptor *> *)conditions;{
    return [self functionQueryWithKey:key function:MDDatabaseFunctionSUM conditions:conditions];
}

@end
