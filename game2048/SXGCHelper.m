//
//  SXGCHelper.m
//  game2048
//
//  Created by Sun Xi on 3/25/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import "SXGCHelper.h"
@import GameKit;

@implementation SXGCHelper

+ (SXGCHelper *)sharedInstance {
    static SXGCHelper *sharedHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHelper = [[SXGCHelper alloc] init];
    });
    return sharedHelper;
}

- (id)init {
    if ((self = [super init])) {
        _gameCenterAvailable = [self isGameCenterAvailable];
        if (_gameCenterAvailable) {
            NSNotificationCenter *nc =
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(authenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName
                     object:nil];
        }
    }
    return self;
}

- (BOOL)isGameCenterAvailable {
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer =@"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer
                                           options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (void)authenticationChanged {
    
    if ([GKLocalPlayer localPlayer].isAuthenticated &&!_userAuthenticated) {
        NSLog(@"Authentication changed: player authenticated.");
        _userAuthenticated = TRUE;
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && _userAuthenticated) {
        NSLog(@"Authentication changed: player not authenticated");
        _userAuthenticated = FALSE;
    }
    
}


- (void)authenticateLocalUser {
    if (!_gameCenterAvailable) return;
    
    NSLog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        [[GKLocalPlayer localPlayer] setAuthenticateHandler:^(UIViewController *controller, NSError *error) {
            NSLog(@"%@", error);
        }];
    } else {
        NSLog(@"Already authenticated!");
    }
}

@end
