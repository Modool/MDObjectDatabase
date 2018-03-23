//
//  MDDAccessorConstants.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/12/22.
//  Copyright © 2017年 modool. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MDDOperation) {
    MDDOperationEqual,
    MDDOperationNotEqual,
    MDDOperationGreaterThan,
    MDDOperationGreaterThanOrEqual,
    MDDOperationLessThan,
    MDDOperationLessThanOrEqual,
    
    MDDOperationLike,
    MDDOperationNotLike,
    MDDOperationIn,
    MDDOperationNotIn,
    
    // Calculation
    MDDOperationByteOr,
    MDDOperationByteAnd,
    MDDOperationByteNot,
    
    MDDOperationByteLeft,
    MDDOperationByteRight,
    
    MDDOperationAdd,
    MDDOperationMinus,
    
    MDDOperationMultiply,
    MDDOperationDivide,
};

typedef NS_ENUM(NSUInteger, MDDConditionOperation) {
    MDDConditionOperationAnd,
    MDDConditionOperationOr,
};

#if UIKIT_STRING_ENUMS
typedef NSString * MDDFunction NS_EXTENSIBLE_STRING_ENUM;
#else
typedef NSString * MDDFunction;
#endif

FOUNDATION_EXTERN NSString * const MDDatabaseToken;

FOUNDATION_EXTERN MDDFunction   const MDDFunctionSUM;
FOUNDATION_EXTERN MDDFunction   const MDDFunctionMAX;
FOUNDATION_EXTERN MDDFunction   const MDDFunctionMIN;
FOUNDATION_EXTERN MDDFunction   const MDDFunctionCOUNT;
FOUNDATION_EXTERN MDDFunction   const MDDFunctionAVERAGE;

FOUNDATION_EXTERN NSString *MDOperationDescription(MDDOperation operation);
FOUNDATION_EXTERN NSString *MDConditionOperationDescription(MDDConditionOperation operation);
FOUNDATION_EXTERN Class MDOperationValueRequireClass(MDDOperation operation);
