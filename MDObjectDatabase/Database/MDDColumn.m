
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
#import "MDPropertyAttributes.h"
#import "MDDObject.h"

@implementation MDDColumn

+ (instancetype)columnWithName:(NSString *)name propertyName:(NSString *)propertyName primary:(BOOL)primary autoincrement:(BOOL)autoincrement attribute:(MDPropertyAttributes *)attribute; {
    MDDColumn *property = [[self alloc] init];
    
    property.name = name;
    property.propertyName = propertyName;
    property.attribute = attribute;
    property.primary = primary;
    property.autoincrement = autoincrement;
    property.type = autoincrement ? MDDColumnTypeInteger : MDDColumnTypeDescription(attribute);
    
    return property;
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

#pragma mark - private

- (id)_transformValue:(id)value toClass:(Class)class;{
    if (!value) return value;
    
    if (class == [NSString class]) {
        return [value isKindOfClass:[NSString class]] ? value : [value description];
    }
    if (class == [NSNumber class]) {
        if ([value isKindOfClass:[NSNumber class]]) return value;
        if ([value isKindOfClass:[NSString class]]) return [[NSNumberFormatter new] numberFromString:value];
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
    if ([value isKindOfClass:[NSString class]]) return [[NSNumberFormatter new] numberFromString:value];
    
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

MDDColumnType MDDColumnTypeDescription(MDPropertyAttributes *attribute) {
    if ([attribute objectClass] || ![[attribute type] length]) return MDDColumnTypeText;
    
    const char *type = [[attribute type] UTF8String];
    if (strcmp(type, @encode(CGPoint)) == 0 || strcmp(type, @encode(CGSize)) == 0 ||
        strcmp(type, @encode(UIEdgeInsets)) == 0 || strcmp(type, @encode(NSString *)) == 0) {
        return MDDColumnTypeText;
    } else if (strcmp(type, @encode(double)) == 0) {
        return MDDColumnTypeDouble;
    } else if (strcmp(type, @encode(float)) == 0) {
        return MDDColumnTypeFloat;
    } else if (strcmp(type, @encode(int)) == 0 || strcmp(type, @encode(long)) == 0 ||
               strcmp(type, @encode(long long)) == 0 || strcmp(type, @encode(short)) == 0 ||
               strcmp(type, @encode(char)) == 0 || strcmp(type, @encode(unsigned char)) == 0 ||
               strcmp(type, @encode(unsigned int)) == 0 || strcmp(type, @encode(unsigned long)) == 0 ||
               strcmp(type, @encode(unsigned long long)) == 0 || strcmp(type, @encode(unsigned short)) == 0 ||
               strcmp(type, @encode(NSDate *)) == 0 || strcmp(type, @encode(NSNumber *)) == 0) {
        return MDDColumnTypeInteger;
    } else if (strcmp(type, @encode(bool)) == 0) {
        return MDDColumnTypeBoolean;
    }
    return MDDColumnTypeText;
}
