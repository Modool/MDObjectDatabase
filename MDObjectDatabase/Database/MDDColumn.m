
//
//  MDDColumn.m
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/30.
//  Copyright © 2017年 modool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDDColumn.h"
#import "MDDColumn+Private.h"

#import "MDDTableInfo.h"
#import "MDPropertyAttributes.h"
#import "MDDColumnConfiguration.h"

#import "MDDObject.h"

@implementation MDDColumn

+ (instancetype)columnWithName:(NSString *)name propertyName:(NSString *)propertyName primary:(BOOL)primary autoincrement:(BOOL)autoincrement attribute:(MDPropertyAttributes *)attribute tableInfo:(id<MDDTableInfo>)tableInfo; {
    MDDColumn *column = [[self alloc] init];
    
    column->_name = [name copy];
    column->_propertyName = [propertyName copy];
    column->_attribute = attribute;
    column->_primary = primary;
    column->_autoincrement = autoincrement;
    column->_type = autoincrement ? MDDColumnTypeInteger : MDDColumnTypeFromAttribute(attribute);
    column->_tableInfo = tableInfo;
    
    return column;
}

- (NSUInteger)hash{
    return [[self name] hash] ^ [[self propertyName] hash];
}

- (BOOL)isEqual:(MDDColumn *)object{
    if ([super isEqual:object]) return YES;
    if (![object isKindOfClass:[MDDColumn class]]) return NO;
    return [[self name] isEqualToString:[object name]] && [[self propertyName] isEqualToString:[object propertyName]];
}

- (BOOL)isEqualLocalColumn:(MDDLocalColumn *)localColumn;{
    return [[self name] isEqualToString:[localColumn name]] && self.primary == localColumn.primary && self.autoincrement == localColumn.autoincrement && self.type == localColumn.type;
}

// Objective-C class to database value
- (id)transformValue:(id)value;{
    if (![self attribute] || ![[self attribute] objectClass]) return value;
    
    return [self _transformValue:value toClass:[[self attribute] objectClass]];
}

// Database class to Objective-C value
- (id)reverseValue:(id)value;{
    if (![self attribute] || ![[self attribute] objectClass]) return value;
    
    return [self _reverseValue:value toClass:[[self attribute] objectClass]];
}

- (NSString *)description{
    return [[self dictionaryWithValuesForKeys:@[@"name", @"propertyName", @"primary", @"autoincrement", @"type", @"configuration"]] description];
}

#pragma mark - private

- (id)_transformValue:(id)value toClass:(Class)class;{
    if (!value) return value;
    
    if (class == [NSString class]) {
        return [value isKindOfClass:[NSString class]] ? value : [value description];
    }
    if (class == [NSNumber class]) {
        if ([value isKindOfClass:[NSNumber class]]) return value;
        if ([value isKindOfClass:[NSString class]]) return [[[NSNumberFormatter alloc] init] numberFromString:value];
        return nil;
    }
    if (class == [NSDate class]) {
        return [self _transformDateWithValue:value];
    }
    if (class == [NSURL class]) {
        return [self _transformURLWithValue:value];
    }
    if (class == [NSDictionary class]) {
        return [self _transformDictionaryWithValue:value];
    }
    if (class == [NSArray class]) {
        return [self _transformArrayWithValue:value];
    }
    if ([class conformsToProtocol:@protocol(MDDSerializedObject)]) {
        return [self _transformSerializedObjectWithValue:value];
    }
    
    return value;
}

- (id)_reverseValue:(id)value toClass:(Class)class;{
    if ([class isKindOfClass:[NSDate class]]) {
        return [self _reverseDateWithValue:value];
    }
    if ([class isKindOfClass:[NSURL class]]) {
        return [self _reverseURLWithValue:value];
    }
    if ([class isKindOfClass:[NSDictionary class]]) {
        return [self _reverseDictionaryWithValue:value];
    }
    if ([class isKindOfClass:[NSArray class]]) {
        return [self _reverseArrayWithValue:value];
    }
    return value;
}

- (NSNumber *)_transformDateWithValue:(id)value;{
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSDate class]]) return @([(NSDate *)value timeIntervalSince1970]);
    if ([value isKindOfClass:[NSString class]]) return [[[NSNumberFormatter alloc] init] numberFromString:value];
    
    return nil;
}

- (NSDate *)_reverseDateWithValue:(id)value{
    if ([value isKindOfClass:[NSDate class]]) return value;
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) return [NSDate dateWithTimeIntervalSince1970:[value doubleValue]];
    return nil;
}

- (NSString *)_transformURLWithValue:(id)value{
    if ([value isKindOfClass:[NSString class]]) return value;
    if ([value isKindOfClass:[NSURL class]]) return [(NSURL *)value absoluteString];
    return nil;
}

- (NSURL *)_reverseURLWithValue:(id)value;{
    if ([value isKindOfClass:[NSURL class]]) return value;
    if ([value isKindOfClass:[NSString class]]) return [NSURL URLWithString:value];
    return nil;
}

- (NSString *)_transformDictionaryWithValue:(id)value{
    if ([value respondsToSelector:@selector(JSONString)]) {
        return [value JSONString];
    }
    return nil;
}

- (NSDictionary *)_reverseDictionaryWithValue:(id)value{
    if ([value isKindOfClass:[NSDictionary class]]) return value;
    if ([value respondsToSelector:@selector(JSONObject)]) {
        id JSON = [value JSONObject];
        if ([JSON isKindOfClass:[NSDictionary class]]) return JSON;
    }
    return nil;
}

- (NSString *)_transformArrayWithValue:(id)value{
    if ([value respondsToSelector:@selector(JSONString)]) {
        return [value JSONString];
    }
    return nil;
}

- (NSArray *)_reverseArrayWithValue:(id)value{
    if ([value isKindOfClass:[NSArray class]]) return value;
    if ([value respondsToSelector:@selector(JSONObject)]) {
        id JSON = [value JSONObject];
        if ([JSON isKindOfClass:[NSArray class]]) return JSON;
    }
    return nil;
}

- (NSString *)_transformSerializedObjectWithValue:(id<MDDSerializedObject>)value{
    if ([value respondsToSelector:@selector(JSONString)]) {
        return [value JSONString];
    }
    return nil;
}

@end

@implementation NSString (MDDLocalColumn)

- (NSString *)stringOfPattern:(NSString *)pattern{
    return [self stringOfPattern:pattern error:nil];
}

- (NSString *)stringOfPattern:(NSString *)pattern error:(NSError **)error;{
    return [self stringOfPattern:pattern options:0 error:error];
}

- (NSString *)stringOfPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options error:(NSError **)error;{
    NSRange range = [self rangeOfPattern:pattern options:options error:error];
    if (range.location == NSNotFound) return nil;
    
    return [self substringWithRange:range];
}

- (NSRange)rangeOfPattern:(NSString *)pattern{
    return [self rangeOfPattern:pattern error:nil];
}


- (NSRange)rangeOfPattern:(NSString *)pattern error:(NSError **)error;{
    return [self rangeOfPattern:pattern options:0 error:error];
}

- (NSRange)rangeOfPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options error:(NSError **)error;{
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:error];
    if (!expression) return NSMakeRange(NSNotFound, 0);
    
    return [expression rangeOfFirstMatchInString:self options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, self.length)];
}

@end

@implementation MDDLocalColumn
@dynamic propertyName;

+ (instancetype)columnWithName:(NSString *)name primary:(BOOL)primary autoincrement:(BOOL)autoincrement type:(MDDColumnType)type tableInfo:(id<MDDTableInfo>)tableInfo;{
    MDDLocalColumn *column = [super columnWithName:name propertyName:nil primary:primary autoincrement:autoincrement attribute:nil tableInfo:tableInfo];
    column.type = type;
    
    return column;
}

+ (NSDictionary<NSString *, MDDLocalColumn *> *)columnsWithSQL:(NSString *)SQL tableInfo:(id<MDDTableInfo>)tableInfo;{
    SQL = [SQL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSRange range = [SQL rangeOfString:@"("];
    SQL = [SQL substringWithRange:NSMakeRange(range.location + 1, [SQL length] - range.location - 1 - 1)];
    
    while ([SQL rangeOfString:@"  "].location != NSNotFound) {
        SQL = [SQL stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    }
    
    NSString *unionPattern = @"primary\\s+key\\s+\\((\\s*([a-z]|_){1,}\\s*\\,)*\\s*([a-z]|_){1,}\\s*\\)";
    NSString *compositePattern = @"constraint\\s+([a-z]|_)+\\s+primary\\s+key\\s+\\((\\s*([a-z]|_){1,}\\s*\\,)*\\s*([a-z]|_){1,}\\s*\\)";
    
    NSString *compositePropertyName = nil;
    NSArray<NSString *> *unionColumnNames = nil;
    range = [SQL rangeOfPattern:compositePattern options:NSRegularExpressionCaseInsensitive error:nil];
    // constraint pk_t2 primary property ( a, b, c )
    if (range.location != NSNotFound) {
        NSString *compositeString = [SQL substringWithRange:range];
        unionColumnNames = [self propertyFromString:compositeString];
        compositePropertyName = [compositeString componentsSeparatedByString:@" "][1];
        
        SQL = [SQL stringByReplacingCharactersInRange:range withString:@""];
    } else {
        //  primary property ( a, b, c )
        range = [SQL rangeOfPattern:unionPattern options:NSRegularExpressionCaseInsensitive error:nil];
        if (range.location != NSNotFound) {
            unionColumnNames = [self propertyFromString:[SQL substringWithRange:range]];
            
            SQL = [SQL stringByReplacingCharactersInRange:range withString:@""];
        }
    }
    
    NSArray<NSString *> *SQLs = [SQL componentsSeparatedByString:@","];
    NSMutableDictionary<NSString *, MDDLocalColumn *> *columns = [NSMutableDictionary dictionary];
    for (NSString *SQL in SQLs) {
        MDDLocalColumn *column = [self localColumnWithSQL:SQL unionColumnNames:unionColumnNames compositePropertyName:compositePropertyName tableInfo:tableInfo];
        if (!column) continue;
        
        columns[column.name] = column;
    }
    
    return [columns copy];
}

+ (NSArray<NSString *> *)propertyFromString:(NSString *)string {
    NSString *keyString = [string stringOfPattern:@"\\(.*\\)"];
    keyString = [keyString stringByReplacingOccurrencesOfString:@" " withString:@""];
    keyString = [keyString substringWithRange:NSMakeRange(1, keyString.length - 2)];
    return [keyString componentsSeparatedByString:@","];
}

+ (MDDLocalColumn *)localColumnWithSQL:(NSString *)SQL unionColumnNames:(NSArray<NSString *> *)unionColumnNames compositePropertyName:(NSString *)compositePropertyName tableInfo:(id<MDDTableInfo>)tableInfo;{
    SQL = [SQL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (![SQL length]) return nil;
    
    NSArray<NSString *> *keywords = [SQL componentsSeparatedByString:@" "];
    if ([keywords count] < 2) return nil;
    
    NSString *name = [keywords firstObject];
    NSUInteger length = 0;
    MDDColumnType type = MDDColumnTypeText;
    
    NSString *typeString = keywords[1];
    NSRange range = [typeString rangeOfString:@"("];
    if (range.location != NSNotFound) {
        type = MDDColumnTypeFromDescription([typeString substringToIndex:range.location]);
        length = [[typeString substringWithRange:NSMakeRange(range.location + 1, typeString.length - range.location - 2)] integerValue];
    } else {
        type = MDDColumnTypeFromDescription(typeString);
    }
    
    __block BOOL nullabled = YES;
    __block BOOL unique = NO;
    __block BOOL primary = NO;
    __block BOOL autoincrement = NO;
    __block NSString *defaultValue = nil;
    __block NSString *checkValue = nil;
    
    keywords = [keywords subarrayWithRange:NSMakeRange(2, [keywords count] - 2)];
    [keywords enumerateObjectsUsingBlock:^(NSString *keyword, NSUInteger index, BOOL *stop) {
        unique = [keyword caseInsensitiveCompare:@"unique"] == NSOrderedSame ?: unique;
        primary = [keyword caseInsensitiveCompare:@"primary"] == NSOrderedSame ?: primary;
        autoincrement = [keyword caseInsensitiveCompare:@"autoincrement"] == NSOrderedSame ?: autoincrement;
        
        BOOL not = [keyword caseInsensitiveCompare:@"not"] == NSOrderedSame;
        if (not && [keywords count] > (index + 1)) {
            nullabled = [keywords[index + 1] caseInsensitiveCompare:@"null"] != NSOrderedSame;
        }
        BOOL defaultEnabled = [keyword caseInsensitiveCompare:@"default"] == NSOrderedSame;
        if (defaultEnabled && [keywords count] > (index + 1)) {
            defaultValue = keywords[index + 1];
        }
        BOOL checkEnabled = [keyword localizedCaseInsensitiveContainsString:@"check"];
        if (checkEnabled) {
            NSRange range = [keyword rangeOfString:@"("];
            if (range.location == NSNotFound) return;
            
            checkValue = [keyword substringWithRange:NSMakeRange(range.location + 1, keyword.length - range.location - 2)];
        }
    }];
    primary = [unionColumnNames containsObject:name] ?: primary;
 
    MDDLocalColumn *column = [MDDLocalColumn columnWithName:name primary:primary autoincrement:autoincrement type:type tableInfo:tableInfo];
    MDDColumnConfiguration *configuration = [MDDColumnConfiguration defaultConfigurationWithColumn:column];
    configuration.unique = unique;
    configuration.length = length;
    configuration.nullabled = nullabled;
    configuration.defaultValue = defaultValue;
    configuration.checkValue = checkValue;
    configuration.compositePropertyName = ([unionColumnNames containsObject:name] && [compositePropertyName length]) ? compositePropertyName : nil;
    
    column.configuration = configuration;
    
    return column;
}

@end

NSDictionary *MDDColumnTypeDescriptions(){
    static NSDictionary *descriptions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        descriptions = @{@(MDDColumnTypeText): @"TEXT",
                         @(MDDColumnTypeInteger): @"INTEGER",
                         @(MDDColumnTypeFloat): @"FLOAT",
                         @(MDDColumnTypeData): @"BLOB",
                         };
    });
    return descriptions;
}

MDDColumnType MDDColumnTypeFromDescription(NSString *description) {
    return [[[MDDColumnTypeDescriptions() allKeysForObject:[description uppercaseString]] firstObject] integerValue];
}

NSString *MDDColumnTypeDescription(MDDColumnType type){
    return MDDColumnTypeDescriptions()[@(type)];
}

MDDColumnType MDDColumnTypeFromAttribute(MDPropertyAttributes *attribute) {
    if ([attribute objectClass] || ![[attribute type] length]) return MDDColumnTypeText;
    
    const char *type = [[attribute type] UTF8String];
    if (strcmp(type, @encode(CGPoint)) == 0 || strcmp(type, @encode(CGSize)) == 0 ||
        strcmp(type, @encode(UIEdgeInsets)) == 0 || strcmp(type, @encode(NSString *)) == 0) {
        return MDDColumnTypeText;
    } else if (strcmp(type, @encode(float)) == 0 || strcmp(type, @encode(double)) == 0) {
        return MDDColumnTypeFloat;
    } else if (strcmp(type, @encode(int)) == 0 || strcmp(type, @encode(long)) == 0 ||
               strcmp(type, @encode(long long)) == 0 || strcmp(type, @encode(short)) == 0 ||
               strcmp(type, @encode(char)) == 0 || strcmp(type, @encode(unsigned char)) == 0 ||
               strcmp(type, @encode(unsigned int)) == 0 || strcmp(type, @encode(unsigned long)) == 0 ||
               strcmp(type, @encode(unsigned long long)) == 0 || strcmp(type, @encode(unsigned short)) == 0 ||
               strcmp(type, @encode(NSDate *)) == 0 || strcmp(type, @encode(NSNumber *)) == 0) {
        return MDDColumnTypeInteger;
    } else if (strcmp(type, @encode(bool)) == 0) {
        return MDDColumnTypeInteger;
    } else if (strcmp(type, @encode(NSData *)) == 0 || strcmp(type, @encode(char *)) == 0) {
        return MDDColumnTypeData;
    }
    return MDDColumnTypeText;
}
