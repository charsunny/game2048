//
//  SXGCHelper.h
//  game2048
//
//  Created by Sun Xi on 3/25/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SXGCHelper : NSObject

@property(assign) BOOL gameCenterAvailable;
@property(assign) BOOL userAuthenticated;

+ (SXGCHelper *)sharedInstance;
- (void)authenticateLocalUser;

@end
