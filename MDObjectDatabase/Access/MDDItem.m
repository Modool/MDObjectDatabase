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

@interface MDDItem ()

@property (nonatomic, copy) NSString *alias;

@end

@implementation MDDItem

+ (instancetype)itemWithDescriptor:(MDDDescriptor *)descriptor;{
    NSParameterAssert(descriptor);
    return [self itemWithDescriptor:descriptor alias:nil];
}

+ (instancetype)itemWithDescriptor:(MDDDescriptor *)descriptor alias:(NSString *)alias;{
    NSParameterAssert(descriptor);
    MDDItem *property = [super descriptorWithTableInfo:[descriptor tableInfo]];
    property->_descriptor = descriptor;
    property->_alias = [alias copy];
    
    return property;
}

+ (instancetype)itemWithTableInfo:(MDDTableInfo *)tableInfo names:(NSSet<NSString *> *)names;{
    NSParameterAssert(tableInfo && [names count]);
    MDDItem *property = [super descriptorWithTableInfo:tableInfo];
    property->_names = [names copy];
    
    return property;
}

- (MDDDescription *)SQLDescription{
    if (_descriptor) {
        MDDDescription *description = [_descriptor SQLDescription];
        NSString *SQL = [description SQL];
        if (_alias) SQL = [NSString stringWithFormat:@" ( %@ ) AS %@ ", SQL, self.alias];
        return [MDDDescription descriptionWithSQL:SQL values:[description values]];
    }
    if ([_names count] && [self tableInfo]) {
        NSSet *primaryProperties = [[self tableInfo] respondsToSelector:@selector(primaryProperties)] ? [[self tableInfo] primaryProperties] : [NSSet set];
        NSDictionary *mapper = [[self tableInfo] propertyColumnMapper];
        NSArray<NSString *> *properties = [[_names allObjects] MDDItemMap:^id(id property) {
            if (property != [NSNull null]) return property;
            else {
                NSParameterAssert([primaryProperties count]);
                return [primaryProperties anyObject];
            }
        }];
        NSArray<NSString *> *columnNames = [mapper objectsForKeys:properties notFoundMarker:@""];
        return [MDDDescription descriptionWithSQL:[columnNames componentsJoinedByString:@", "]];
    }
    return nil;
}

- (NSString *)description{
    return [[self dictionaryWithValuesForKeys:@[@"descriptor", @"alias", @"property"]] description];
}

@end

@implementation MDDFuntionProperty

+ (instancetype)itemWithTableInfo:(MDDTableInfo *)tableInfo name:(NSString *)name function:(MDDFunction)function;{
    return [self itemWithTableInfo:tableInfo name:name function:function  alias:nil];
}

+ (instancetype)itemWithTableInfo:(MDDTableInfo *)tableInfo name:(NSString *)name function:(MDDFunction)function alias:(NSString *)alias;{
    MDDFuntionProperty *property = [super itemWithTableInfo:tableInfo names:[NSSet setWithObject:name]];
    property.alias = [alias copy];
    property->_function = function;
    
    return property;
}

- (MDDDescription *)SQLDescription{
    if ([[self names] count] && _function) {
        NSSet *primaryProperties = [[self tableInfo] respondsToSelector:@selector(primaryProperties)] ? [[self tableInfo] primaryProperties] : [NSSet set];
        NSDictionary *mapper = [[self tableInfo] propertyColumnMapper];
        NSString *property = [[self names] anyObject] ?: [primaryProperties anyObject];
        
        NSString *SQL = [NSString stringWithFormat:@" %@(%@) ", _function, mapper[property]];
        if ([self alias]) SQL = [NSString stringWithFormat:@" %@ AS %@", SQL, self.alias];
        return [MDDDescription descriptionWithSQL:SQL];
    }
    return nil;
}

- (NSString *)description{
    return [[self dictionaryWithValuesForKeys:@[@"descriptor", @"alias", @"property", @"function"]] description];
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
        return [MDDDescription descriptionWithSQL:[[self tableInfo] name]];
    }
    return nil;
}

@end

@implementation MDDValue

@end

@implementation NSString (MDDItem)

@end

@implementation NSNull (MDDItem)

@end

@implementation NSObject (MDDValue)

@end
