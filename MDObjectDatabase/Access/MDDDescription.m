//
//  MDDDescription.m
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDDescription.h"
#import "MDDConstants.h"

@implementation MDDDescription
@synthesize normalizedSQL = _normalizedSQL;

+ (instancetype)descriptionWithSQL:(NSString *)SQL;{
    NSParameterAssert(SQL);
    return [self descriptionWithSQL:SQL values:nil];
}

+ (instancetype)descriptionWithSQL:(NSString *)SQL values:(NSArray *)values{
    NSParameterAssert(SQL);
    
    MDDDescription *description = [[self alloc] init];
    description->_SQL = [SQL copy];
    description->_values = [values ?: @[] copy];
    
    return description;
}

- (NSString *)normalizedSQL{
    if (!_normalizedSQL) {
        NSArray<NSString *> *components = [[self SQL] componentsSeparatedByString:[NSString stringWithFormat:@"= %@", MDDatabaseToken]];
        NSMutableString *string = [NSMutableString string];
        [components enumerateObjectsUsingBlock:^(NSString *sql, NSUInteger index, BOOL *stop) {
            [string appendString:sql];
            if (index < ([components count] - 1)) {
                NSString *value = [self values][index];
                
                BOOL isStringValue = [value isKindOfClass:[NSString class]] && ![[[NSNumberFormatter alloc] init] numberFromString:value];
                value = isStringValue ? [NSString stringWithFormat:@"'%@'", value] : [value description];
                
                [string appendString:[NSString stringWithFormat:@"= %@", value]];
            }
        }];
        
        _normalizedSQL = string;
    }
    return _normalizedSQL;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"\ntoken_string: %@\nnormalize_string: %@\nvalues:%@", self.SQL, self.normalizedSQL, self.values];
}

@end
