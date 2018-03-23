//
//  MDDRange.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/5.
//  Copyright © 2018年 Modool. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    double minimum;
    double maximum;
} MDDFloatRange;

typedef struct {
    NSInteger minimum;
    NSInteger maximum;
} MDDIntegerRange;

FOUNDATION_STATIC_INLINE MDDFloatRange MDDFloatRangeMake(double minimum, double maximum) {
    return (MDDFloatRange){minimum, maximum};
}

FOUNDATION_STATIC_INLINE BOOL MDDFloatRangeContained(MDDFloatRange range, double value) {
    return range.minimum <= value && range.maximum >= value;
}

FOUNDATION_STATIC_INLINE MDDIntegerRange MDDIntegerRangeMake(NSInteger minimum, NSInteger maximum) {
    return (MDDIntegerRange){minimum, maximum};
}

FOUNDATION_STATIC_INLINE BOOL MDDIntegerRangeContained(MDDIntegerRange range, NSInteger value) {
    return range.minimum <= value && range.maximum >= value;
}

static const NSRange MDDatabaseMaximumRange = (NSRange){0, NSIntegerMax};
static const NSRange NSRangeZore = (NSRange){0, 0};
static const NSRange NSRangeUnset = (NSRange){0, 0};
