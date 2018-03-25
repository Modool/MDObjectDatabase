//
//  MDDAccessorConstants.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/12/22.
//  Copyright © 2017年 modool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDDMacros.h"

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

MDD_EXTERN NSString * const MDDatabaseToken;

MDD_EXTERN MDDFunction const MDDFunctionSUM;
MDD_EXTERN MDDFunction const MDDFunctionMAX;
MDD_EXTERN MDDFunction const MDDFunctionMIN;
MDD_EXTERN MDDFunction const MDDFunctionCOUNT;
MDD_EXTERN MDDFunction const MDDFunctionAVERAGE;

MDD_EXTERN NSString *MDOperationDescription(MDDOperation operation);
MDD_EXTERN NSString *MDConditionOperationDescription(MDDConditionOperation operation);
MDD_EXTERN Class MDOperationValueRequireClass(MDDOperation operation);
