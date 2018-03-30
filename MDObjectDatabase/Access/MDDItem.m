//
//  MDDItem.m
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/26.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDItem.h"
#import "MDDDescription.h"
#import "MDDTableInfo+Private.h"

#import "MDDObject+Private.h"

@interface MDDKey ()

@property (nonatomic, copy) NSString *alias;

@end

@implementation MDDKey

+ (instancetype)keyWithDescriptor:(MDDDescriptor *)descriptor;{
    NSParameterAssert(descriptor);
    return [self keyWithDescriptor:descriptor alias:nil];
}

+ (instancetype)keyWithDescriptor:(MDDDescriptor *)descriptor alias:(NSString *)alias;{
    NSParameterAssert(descriptor);
    MDDKey *key = [super descriptorWithTableInfo:[descriptor tableInfo]];
    key->_descriptor = descriptor;
    key->_alias = [alias copy];
    
    return key;
}

+ (instancetype)keyWithTableInfo:(MDDTableInfo *)tableInfo keys:(NSSet<NSString *> *)keys;{
    NSParameterAssert(tableInfo && [keys count]);
    MDDKey *key = [super descriptorWithTableInfo:tableInfo];
    key->_keys = [keys copy];
    
    return key;
}

- (MDDDescription *)SQLDescription{
    if (_descriptor) {
        MDDDescription *description = [_descriptor SQLDescription];
        NSString *SQL = [description SQL];
        if (_alias) SQL = [NSString stringWithFormat:@" ( %@ ) AS %@ ", SQL, self.alias];
        return [MDDDescription descriptionWithSQL:SQL values:[description values]];
    }
    if ([_keys count] && [self tableInfo]) {
        NSSet *primaryProperties = [[self tableInfo] primaryProperties];
        NSDictionary *mapper = [[self tableInfo] propertyColumnMapper];
        NSArray<NSString *> *keys = [[_keys allObjects] MDDItemMap:^id(id key) {
            if (key != [NSNull null]) return key;
            else return [primaryProperties anyObject];
        }];
        NSArray<NSString *> *columnNames = [mapper objectsForKeys:keys notFoundMarker:@""];
        return [MDDDescription descriptionWithSQL:[columnNames componentsJoinedByString:@", "]];
    }
    return nil;
}

- (NSString *)description{
    return [[self dictionaryWithValuesForKeys:@[@"descriptor", @"alias", @"keys"]] description];
}

@end

@implementation MDDFuntionKey

+ (instancetype)keyWithTableInfo:(MDDTableInfo *)tableInfo key:(NSString *)aKey function:(MDDFunction)function;{
    return [self keyWithTableInfo:tableInfo key:aKey function:function  alias:nil];
}

+ (instancetype)keyWithTableInfo:(MDDTableInfo *)tableInfo key:(NSString *)aKey function:(MDDFunction)function alias:(NSString *)alias;{
    MDDFuntionKey *key = [super keyWithTableInfo:tableInfo keys:[NSSet setWithObject:aKey]];
    key.alias = [alias copy];
    key->_function = function;
    
    return key;
}

- (MDDDescription *)SQLDescription{
    if ([[self keys] count] && _function) {
        NSSet *primaryProperties = [[self tableInfo] primaryProperties];
        NSDictionary *mapper = [[self tableInfo] propertyColumnMapper];
        NSString *key = [[self keys] anyObject] ?: [primaryProperties anyObject];
        
        NSString *SQL = [NSString stringWithFormat:@" %@(%@) ", _function, mapper[key]];
        if ([self alias]) SQL = [NSString stringWithFormat:@" %@ AS %@", SQL, self.alias];
        return [MDDDescription descriptionWithSQL:SQL];
    }
    return nil;
}

- (NSString *)description{
    return [[self dictionaryWithValuesForKeys:@[@"descriptor", @"alias", @"keys", @"function"]] description];
}

@end


@implementation MDDSet

+ (instancetype)set;{
    return [self setWithTableInfo:nil];
}

+ (instancetype)setWithTableInfo:(MDDTableInfo *)tableInfo;{
    return [super descriptorWithTableInfo:tableInfo];
}

+ (instancetype)setWithDescriptor:(MDDDescriptor *)descriptor;{
    NSParameterAssert(descriptor);
    return [self setWithDescriptor:descriptor alias:nil];
}

+ (instancetype)setWithDescriptor:(MDDDescriptor *)descriptor alias:(NSString *)alias;{
    NSParameterAssert(descriptor);
    MDDSet *set = [super descriptorWithTableInfo:nil];
    set->_descriptor = descriptor;
    set->_alias = [alias copy];
    
    return set;
}

- (NSString *)description{
    return [[self dictionaryWithValuesForKeys:@[@"descriptor", @"alias"]] description];
}

- (MDDDescription *)SQLDescription{
    if (_descriptor) {
        MDDDescription *description = [_descriptor SQLDescription];
        NSString *SQL = [description SQL];
        if (_alias) SQL = [NSString stringWithFormat:@" ( %@ ) AS %@ ", SQL, self.alias];
        return [MDDDescription descriptionWithSQL:SQL values:[description values]];
    }
    if ([self tableInfo]) {
        return [MDDDescription descriptionWithSQL:[[self tableInfo] tableName]];
    }
    return nil;
}

@end

@implementation MDDValue

@end

@implementation NSString (MDDKey)

@end

@implementation NSNull (MDDKey)

@end

@implementation NSObject (MDDValue)

@end
