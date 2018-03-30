
//
//  MDDConstants.m
//  MDDatabase
//
//  Created by xulinfeng on 2017/12/22.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDConstants.h"

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
        
        case MDDOperationNull: return @"IS NULL";
        case MDDOperationNonull: return @"NOT NULL";
            
        case MDDOperationExists: return @"EXISTS";
        case MDDOperationNotExists: return @"NOT EXISTS";
            
        case MDDOperationLike: return @"LIKE";
        case MDDOperationNotLike: return @"NOT LIKE";
        
        case MDDOperationGlob: return @"GLOB";
        case MDDOperationNotGlob: return @"NOT GLOB";
            
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
        case MDDOperationMod: return @"%";
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

BOOL MDOperationShoulExchangePosition(MDDOperation operation){
    switch (operation) {
        case MDDOperationExists:
        case MDDOperationNotExists: return YES;
        default: return NO;
    }
}

Class MDOperationValueRequireClass(MDDOperation operation){
    switch (operation) {
        case MDDOperationIn:
        case MDDOperationNotIn: return [NSArray class];
        default: return nil;
    }
}
