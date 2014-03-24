//
//  SXHistoryModel.m
//  game2048
//
//  Created by Sun Xi on 3/24/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import "SXHistoryModel.h"

@implementation SXHistoryModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.time forKey:@"time"];
    [aCoder encodeObject:@(self.score) forKey:@"score"];
    [aCoder encodeObject:self.steps forKey:@"steps"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.score = [[aDecoder decodeObjectForKey:@"score"] integerValue];
        self.time = [aDecoder decodeObjectForKey:@"time"];
        self.steps = [aDecoder decodeObjectForKey:@"steps"];
    }
    return self;
}

@end
