//
//  MDDErrorCode.h
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/25.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDDMacros.h"

MDD_EXTERN NSString * const MDDatabaseErrorDomain;

typedef NS_ENUM(NSUInteger, MDDErrorCode){
    MDDErrorCodeNone,
    MDDErrorCodeConfigurationExisted,
    MDDErrorCodeColumnConfigurationExisted,
    MDDErrorCodeNonePrimaryProperty,
    MDDErrorCodeNonconformProtocol,
    MDDErrorCodeTableNonexistent,
    MDDErrorCodeTableCreateFailed,
    MDDErrorCodeTableCompatFailed,
    MDDErrorCodeViewColumnExist,
};

