
//
//  MDDAccessorConstants.m
//  MDDatabase
//
//  Created by xulinfeng on 2017/12/22.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDAccessorConstants.h"

NSString * const MDDatabaseToken = @"?";

MDDFunction   const MDDFunctionSUM = @"SUM";
MDDFunction   const MDDFunctionMAX = @"MAX";
MDDFunction   const MDDFunctionMIN = @"MIN";
MDDFunction   const MDDFunctionCOUNT = @"COUNT";
MDDFunction   const MDDFunctionAVERAGE = @"AVERAGE";

NSString *MDOperationDescription(MDDOperation operation){
    switch (operation) {
        case MDDOperationEqual: return @"=";
        case MDDOperationNotEqual: return @"!=";
        case MDDOperationGreaterThan: return @">";
        case MDDOperationGreaterThanOrEqual: return @">=";
        case MDDOperationLessThan: return @"<";
        case MDDOperationLessThanOrEqual: return @"<=";
        case MDDOperationLike: return @"LIKE";
        case MDDOperationNotLike: return @"NOT LIKE";
        case MDDOperationIn: return @"IN";
        case MDDOperationNotIn: return @"NOT IN";
            
        case MDDOperationByteOr: return @"|";
        case MDDOperationByteAnd: return @"&";
        case MDDOperationByteNot: return @"~";
        case MDDOperationByteLeft: return @"<<";
        case MDDOperationByteRight: return @">>";
        case MDDOperationAdd: return @"+";
        case MDDOperationMinus: return @"-";
        case MDDOperationMultiply: return @"*";
        case MDDOperationDivide: return @"/";
        default: return nil;
    }
}

NSString *MDConditionOperationDescription(MDDConditionOperation operation){
    switch (operation) {
        case MDDConditionOperationAnd: return @"AND";
        case MDDConditionOperationOr: return @"OR";
        default: return nil;
    }
}

Class MDOperationValueRequireClass(MDDOperation operation){
    switch (operation) {
        case MDDOperationGreaterThan:
        case MDDOperationGreaterThanOrEqual:
        case MDDOperationLessThan:
        case MDDOperationLessThanOrEqual:
        case MDDOperationByteOr:
        case MDDOperationByteAnd:
        case MDDOperationByteNot:
        case MDDOperationByteLeft:
        case MDDOperationByteRight: return [NSNumber class];
        case MDDOperationLike:
        case MDDOperationNotLike: return [NSString class];
        case MDDOperationIn:
        case MDDOperationNotIn: return [NSArray class];
        default: return nil;
    }
}
