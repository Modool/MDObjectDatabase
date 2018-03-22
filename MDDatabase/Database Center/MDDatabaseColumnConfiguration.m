//
//  MDDatabaseColumnConfiguration.m
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/30.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDatabaseColumnConfiguration.h"
#import "MDDatabaseColumn.h"

@implementation MDDatabaseColumnConfiguration

+ (instancetype)defaultConfigurationWithColumn:(MDDatabaseColumn *)column;{
    MDDatabaseColumnConfiguration *configuration = [self new];
    
    configuration->_primary = [column isPrimary];
//    configuration.autoincrement = ([column isPrimary] && [column type] != MDDatabaseColumnTypeText);
    configuration.nullabled = (![column isPrimary] && [column type] == MDDatabaseColumnTypeText);
    configuration.defaultValue = (![column isPrimary] && [column type] != MDDatabaseColumnTypeText) ? @0 : nil;
    
    return configuration;
}

@end
