//
//  MDDRange.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/5.
//  Copyright © 2018年 Modool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDDMacros.h"

typedef struct {
    double minimum;
    double maximum;
} MDDFloatRange;

typedef struct {
    NSInteger minimum;
    NSInteger maximum;
} MDDIntegerRange;

MDD_STATIC_INLINE MDDFloatRange MDDFloatRangeMake(double minimum, double maximum) {
    return (MDDFloatRange){minimum, maximum};
}

MDD_STATIC_INLINE BOOL MDDFloatRangeContained(MDDFloatRange range, double value) {
    return range.minimum <= value && range.maximum >= value;
}

MDD_STATIC_INLINE MDDIntegerRange MDDIntegerRangeMake(NSInteger minimum, NSInteger maximum) {
    return (MDDIntegerRange){minimum, maximum};
}

MDD_STATIC_INLINE BOOL MDDIntegerRangeContained(MDDIntegerRange range, NSInteger value) {
    return range.minimum <= value && range.maximum >= value;
}

MDD_STATIC_CONST NSRange MDDatabaseMaximumRange = (NSRange){0, NSIntegerMax};
MDD_STATIC_CONST NSRange NSRangeZore = (NSRange){0, 0};
MDD_STATIC_CONST NSRange NSRangeUnset = (NSRange){0, 0};
