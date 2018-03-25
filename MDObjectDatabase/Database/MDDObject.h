//
//  MDDObject.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/30.
//  Copyright © 2017年 modool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDDMacros.h"

MDD_EXTERN NSString * const MDDatabaseErrorDomain;

@class MDDColumnConfiguration, MDDColumn, MDDIndex;
@protocol MDDSerializedObject <NSObject>

@optional
@property (nonatomic, copy, readonly) NSString *JSONString;

@property (nonatomic, copy, readonly) id JSONObject;

@end

@protocol MDDObject <MDDSerializedObject>

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary;

@end
