//
//  MDDatabaseAccessorConstants.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/12/22.
//  Copyright © 2017年 modool. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MDDatabaseOperation) {
    MDDatabaseOperationEqual,
    MDDatabaseOperationNotEqual,
    MDDatabaseOperationGreaterThan,
    MDDatabaseOperationGreaterThanOrEqual,
    MDDatabaseOperationLessThan,
    MDDatabaseOperationLessThanOrEqual,
    
    MDDatabaseOperationLike,
    MDDatabaseOperationNotLike,
    MDDatabaseOperationIn,
    MDDatabaseOperationNotIn,
    
    // Calculation
    MDDatabaseOperationByteOr,
    MDDatabaseOperationByteAnd,
    MDDatabaseOperationByteNot,
    
    MDDatabaseOperationByteLeft,
    MDDatabaseOperationByteRight,
    
    MDDatabaseOperationAdd,
    MDDatabaseOperationMinus,
    
    MDDatabaseOperationMultiply,
    MDDatabaseOperationDivide,
};

typedef NS_ENUM(NSUInteger, MDDatabaseConditionOperation) {
    MDDatabaseConditionOperationAnd,
    MDDatabaseConditionOperationOr,
};

#if UIKIT_STRING_ENUMS
typedef NSString * MDDatabaseFunction NS_EXTENSIBLE_STRING_ENUM;
#else
typedef NSString * MDDatabaseFunction;
#endif

FOUNDATION_EXTERN NSString * const MDDatabaseToken;

FOUNDATION_EXTERN MDDatabaseFunction   const MDDatabaseFunctionSUM;
FOUNDATION_EXTERN MDDatabaseFunction   const MDDatabaseFunctionMAX;
FOUNDATION_EXTERN MDDatabaseFunction   const MDDatabaseFunctionMIN;
FOUNDATION_EXTERN MDDatabaseFunction   const MDDatabaseFunctionCOUNT;
FOUNDATION_EXTERN MDDatabaseFunction   const MDDatabaseFunctionAVERAGE;

