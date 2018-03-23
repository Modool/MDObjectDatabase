//
//  MDDDescriptor+Private.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/30.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDDescriptor.h"

@protocol MDDObject;
@class MDDTableInfo;
@interface MDDDescriptor ()

- (NSString *)descriptionWithTableInfo:(MDDTableInfo *)tableInfo value:(id *)value;

@end

