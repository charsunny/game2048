//
//  SXAppConfig.m
//  game2048
//
//  Created by Sun Xi on 3/24/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import "SXAppConfig.h"

@implementation SXAppConfig

+ (instancetype)sharedAppConfig
{
    static SXAppConfig* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [SXAppConfig new];
    });
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        NSString* themepath = [[NSBundle mainBundle] pathForResource:@"theme" ofType:@"plist"];
        
        self.theme = [NSArray arrayWithContentsOfFile:themepath];
        
        NSString* docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString* historyFile = [docPath stringByAppendingPathComponent:@"history.dat"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:historyFile]) {
            [[NSFileManager defaultManager] createFileAtPath:historyFile contents:nil attributes:nil];
        }
        _history = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:historyFile]];
        _history = _history?:[NSMutableArray new];
    }
    return self;
}

- (void)appendHistory:(SXHistoryModel*)model {
    if ([_history count] >= 30) {
        [_history removeLastObject];
    }
    [_history insertObject:model atIndex:0];
    NSString* docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString* historyFile = [docPath stringByAppendingPathComponent:@"history.dat"];
    [NSKeyedArchiver archiveRootObject:_history toFile:historyFile];
    
}

- (void)removeHistory:(SXHistoryModel*)model {
    [_history removeObject:model];
    NSString* docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString* historyFile = [docPath stringByAppendingPathComponent:@"history.dat"];
    [NSKeyedArchiver archiveRootObject:_history toFile:historyFile];
}

- (void)setCurrectTheme:(int)currectTheme {
    [[NSUserDefaults standardUserDefaults] setObject:@(currectTheme) forKey:@"theme"];
}

- (int)currectTheme {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"theme"] intValue];
}

@end
