//
//  MDDColumn.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/30.
//  Copyright © 2017年 modool. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MDDColumnType) {
    MDDColumnTypeText,
    MDDColumnTypeInteger,
    MDDColumnTypeFloat,
    MDDColumnTypeDouble,
    MDDColumnTypeBoolean,
};

@class MDPropertyAttributes;
@interface MDDColumn : NSObject

@property (nonatomic, copy, readonly) NSString *name;

@property (nonatomic, copy, readonly) NSString *propertyName;

@property (nonatomic, assign, readonly, getter=isPrimary) BOOL primary;

@property (nonatomic, assign, readonly, getter=isAutoincrement) BOOL autoincrement;

@property (nonatomic, assign, readonly) MDDColumnType type;

+ (instancetype)columnWithName:(NSString *)name propertyName:(NSString *)propertyName primary:(BOOL)primary autoincrement:(BOOL)autoincrement attribute:(MDPropertyAttributes *)attribute;

// Objective-C class to database value
- (id)transformValue:(id)value;

// Database class to Objective-C value
- (id)reverseValue:(id)value;

@end

FOUNDATION_EXTERN MDDColumnType MDDColumnTypeDescription(MDPropertyAttributes *attribute);
