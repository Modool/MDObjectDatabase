//
//  MDDatabaseCenter.m
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/25.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDatabaseCenter.h"
#import "MDDLogger.h"
#import "MDDatabase.h"

@interface MDDatabaseCenter ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, MDDatabase *> *databases;

@end

@implementation MDDatabaseCenter

- (instancetype)init{
    if (self = [super init]) {
        _logger = [[MDDLogger alloc] init];
        _databases = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - accessor

- (void)setDebugEnable:(BOOL)debugEnable{
    _logger.enable = debugEnable;
}

- (BOOL)isDebugEnabled{
    return _logger.enable;
}

#pragma mark - public

+ (MDDatabaseCenter *)defaultCenter;{
    static MDDatabaseCenter *center = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [[self alloc] init];
    });
    return center;
}

- (MDDatabase *)requrieDatabaseWithFilepath:(NSString *)filepath;{
    MDDatabase *database = self.databases[filepath];
    if (!database) {
        database = [MDDatabase databaseWithFilepath:filepath];
        self.databases[filepath] = database;
    }
    return database;
}

@end
