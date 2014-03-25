//
//  SXAppDelegate.h
//  game2048
//
//  Created by Sun Xi on 3/19/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WXApiDelegate;

@interface SXAppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
