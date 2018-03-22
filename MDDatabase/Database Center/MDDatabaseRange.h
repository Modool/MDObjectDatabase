//
//  MDDatabaseRange.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/5.
//  Copyright © 2018年 Modool. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    double minimum;
    double maximum;
} MDFloatRange;

typedef struct {
    NSInteger minimum;
    NSInteger maximum;
} MDIntegerRange;

FOUNDATION_STATIC_INLINE MDFloatRange MDFloatRangeMake(double minimum, double maximum) {
    return (MDFloatRange){minimum, maximum};
}

FOUNDATION_STATIC_INLINE BOOL MDFloatRangeContained(MDFloatRange range, double value) {
    return range.minimum <= value && range.maximum >= value;
}

FOUNDATION_STATIC_INLINE MDIntegerRange MDIntegerRangeMake(NSInteger minimum, NSInteger maximum) {
    return (MDIntegerRange){minimum, maximum};
}

FOUNDATION_STATIC_INLINE BOOL MDIntegerRangeContained(MDIntegerRange range, NSInteger value) {
    return range.minimum <= value && range.maximum >= value;
}

static const NSRange MDDatabaseMaximumRange = (NSRange){0, NSIntegerMax};
static const NSRange NSRangeZore = (NSRange){0, 0};
static const NSRange NSRangeUnset = (NSRange){0, 0};
