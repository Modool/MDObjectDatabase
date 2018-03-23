//
//  MDDObject.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/30.
//  Copyright © 2017年 modool. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString * const MDDatabaseErrorDomain;

@class MDDColumnConfiguration, MDDColumn, MDDIndex;
@protocol MDDSerializedObject <NSObject>

@optional
@property (nonatomic, copy, readonly) NSString *JSONString;

@property (nonatomic, copy, readonly) id JSONObject;

@end

@protocol MDDObject <MDDSerializedObject>

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, copy) NSString *objectID;

// It's invalid if multiple primary properties.
@property (nonatomic, assign, class, readonly) BOOL autoincrement;

@property (nonatomic, strong, class, readonly) NSString *tableName;

@property (nonatomic, strong, class, readonly) NSString *primaryProperty;

@property (nonatomic, strong, class, readonly) NSDictionary *tableMapping;

@optional

@property (nonatomic, strong, class, readonly) NSSet *primaryProperties;

// indexes
@property (nonatomic, copy, class, readonly) NSArray<MDDIndex *> *indexes;

+ (void)configuration:(MDDColumnConfiguration *)configruation forColumn:(MDDColumn *)column;

@end
