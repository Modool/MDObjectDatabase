//
//  MDDConstants.h
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
    
    MDDOperationNull,
    MDDOperationNonull,
    
    MDDOperationExists,
    MDDOperationNotExists,
    
    MDDOperationLike,
    MDDOperationNotLike,
    
    MDDOperationGlob,
    MDDOperationNotGlob,
    
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
    MDDOperationMod,
};

typedef NS_ENUM(NSUInteger, MDDConditionOperation) {
    MDDConditionOperationAnd,
    MDDConditionOperationOr,
};

typedef NSString * MDDFunction;
MDD_EXTERN NSString * const MDDatabaseToken;

MDD_EXTERN MDDFunction const MDDFunctionSUM;
MDD_EXTERN MDDFunction const MDDFunctionMAX;
MDD_EXTERN MDDFunction const MDDFunctionMIN;
MDD_EXTERN MDDFunction const MDDFunctionCOUNT;
MDD_EXTERN MDDFunction const MDDFunctionAVERAGE;

MDD_EXTERN NSString *MDOperationDescription(MDDOperation operation);
MDD_EXTERN NSString *MDConditionOperationDescription(MDDConditionOperation operation);
MDD_EXTERN BOOL MDOperationShoulExchangePosition(MDDOperation operation);
MDD_EXTERN Class MDOperationValueRequireClass(MDDOperation operation);
