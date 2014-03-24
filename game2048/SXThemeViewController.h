//
//  SXThemeViewController.h
//  game2048
//
//  Created by Sun Xi on 3/21/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SXThemeViewController : UICollectionViewController

@property(nonatomic) NSNumber* currectTheme;

@property (strong, nonatomic) NSArray* themes;

@property (weak, nonatomic) id sender;

@end
