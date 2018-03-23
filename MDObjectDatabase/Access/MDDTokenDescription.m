//
//  MDDTokenDescription.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDTokenDescription.h"
#import "MDDAccessorConstants.h"

@implementation MDDTokenDescription
@synthesize normalizeDescription = _normalizeDescription;

+ (instancetype)descriptionWithTokenString:(NSString *)tokenString values:(NSArray *)values{
    NSParameterAssert(tokenString);
    
    MDDTokenDescription *description = [self new];
    description->_tokenString = [tokenString copy];
    description->_values = [values ?: @[] copy];
    
    return description;
}

- (NSString *)normalizeDescription{
    if (!_normalizeDescription) {
        NSArray<NSString *> *components = [[self tokenString] componentsSeparatedByString:[NSString stringWithFormat:@"= %@", MDDatabaseToken]];
        NSMutableString *tokenString = [NSMutableString string];
        
        [components enumerateObjectsUsingBlock:^(NSString *sql, NSUInteger index, BOOL * _Nonnull stop) {
            [tokenString appendString:sql];
            if (index < ([components count] - 1)) {
                NSString *value = [self values][index];
                
                BOOL isStringValue = [value isKindOfClass:[NSString class]] && ![[[NSNumberFormatter alloc] init] numberFromString:value];
                value = isStringValue ? [NSString stringWithFormat:@"'%@'", value] : [value description];
                
                [tokenString appendString:[NSString stringWithFormat:@"= %@", value]];
            }
        }];
        
        _normalizeDescription = tokenString;
    }
    return _normalizeDescription;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"\ntoken_string: %@\nnormalize_string: %@\nvalues:%@", self.tokenString, self.normalizeDescription, self.values];
}

@end
