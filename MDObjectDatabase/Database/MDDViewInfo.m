//
//  MDDViewInfo.m
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/30.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDViewInfo.h"
#import "MDDViewInfo+Private.h"
#import "MDDViewConfiguration.h"
#import "MDPropertyAttributes.h"

@implementation MDDViewInfo
@synthesize objectClass = _objectClass, name = _name, primaryProperties = _primaryProperties, propertyColumnMapper = _propertyColumnMapper, columnPropertyMapper = _columnPropertyMapper, columnMapper = _columnMapper;

+ (instancetype)infoWithConfiguration:(MDDViewConfiguration *)configuration error:(NSError **)error;{
    Class<MDDObject> objectClass = [configuration objectClass];
    NSString *name = [configuration name];
    
    MDDViewInfo *info = [[self alloc] init];
    info->_objectClass = objectClass;
    info->_name = [name copy];

    NSDictionary *propertyMapper = [configuration propertyMapper];
    NSSet<MDPropertyAttributes *> *attributes = nil;
    if ([propertyMapper count]) {
        attributes = [NSSet setWithArray:MDPropertyAttributesNamed(objectClass, [propertyMapper allKeys])];
    } else {
        attributes = [NSSet setWithArray:MDPropertyAttributesForClass(objectClass, NO)];
    }
    NSArray<MDPropertyAttributes *> *attributesArray = [attributes allObjects];
    NSArray<NSString *> *names = [attributesArray valueForKey:@MDDKeyPath(MDPropertyAttributes, name)];
    
    if (![propertyMapper count]) propertyMapper = [NSDictionary dictionaryWithObjects:names forKeys:names];
    
    NSDictionary<NSString *, MDDColumn *> *propertyColumns = [configuration propertyColumns];
    NSMutableDictionary<NSString *, MDDColumn *> *columnMapper = [NSMutableDictionary new];
    for (NSString *propertyName in [propertyColumns allKeys]) {
        MDDColumn *column = propertyColumns[propertyName];
        NSString *columnName = propertyMapper[propertyName];
        
        columnMapper[columnName] = column;
    }
    info->_columnMapper = [columnMapper copy];
    info->_propertyColumns = propertyColumns;
    info->_propertyColumnMapper = [propertyMapper copy];
    
    info->_conditionSet = [configuration conditionSet];
    info->_attributeMapper = [NSDictionary dictionaryWithObjects:attributesArray forKeys:names];
    info->_columnPropertyMapper = [NSDictionary dictionaryWithObjects:[propertyMapper allKeys] forKeys:[propertyMapper allValues]];
    
    return info;
}

- (NSUInteger)hash{
    return [[self objectClass] hash] ^ [[self name] hash];
}

- (BOOL)isEqual:(MDDViewInfo *)object{
    if ([super isEqual:object]) return YES;
    if (![object isKindOfClass:[MDDViewInfo class]]) return NO;
    
    return [self objectClass] == [object objectClass] && [[self name] isEqualToString:[object name]];
}

- (NSString *)description{
    return [[self dictionaryWithValuesForKeys:@[@"objectClass", @"name", @"columnMapper", @"propertyColumns", @"propertyColumnMapper", @"attributeMapper", @"columnPropertyMapper"]] description];
}

#pragma mark - accessor

- (NSArray<NSString *> *)columnNames{
    return [[self columnMapper] allKeys];
}

- (NSArray<MDDColumn *> *)columns{
    return [[self columnMapper] allValues];
}

#pragma mark - protected

- (MDDColumn *)columnForProperty:(NSString *)property;{
    NSParameterAssert(property);
    
    MDDColumn *column = self.propertyColumns[property];
    NSParameterAssert(column);
    
    return column;
}

@end
