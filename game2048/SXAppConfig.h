//
//  SXAppConfig.h
//  game2048
//
//  Created by Sun Xi on 3/24/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SXHistoryModel.h"

@interface SXAppConfig : NSObject

+ (instancetype)sharedAppConfig;

- (void)appendHistory:(SXHistoryModel*)model;

- (void)removeHistory:(SXHistoryModel*)model;

@property (strong, nonatomic) NSMutableArray* history;

@property (strong, nonatomic) NSArray* theme;

@property (nonatomic) int currectTheme;

@property (nonatomic) int currentMode;

@property (nonatomic) int currectDifficult;

@property (nonatomic) BOOL shakeToPlay;

@property (nonatomic) BOOL isStartedUp;

@end
