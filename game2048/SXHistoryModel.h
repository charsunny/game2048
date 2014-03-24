//
//  SXHistoryModel.h
//  game2048
//
//  Created by Sun Xi on 3/24/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SXHistoryModel : NSObject<NSCoding>

@property (nonatomic, strong) NSString* time;

@property (nonatomic,) NSInteger score;

@property (strong, nonatomic) NSMutableArray* steps;

@end
