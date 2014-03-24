//
//  SXNumberCell.h
//  game2048
//
//  Created by Sun Xi on 3/20/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SXNumberCell : UIView

@property (nonatomic) NSInteger number;

@property (nonatomic) NSInteger mergeCell;

- (id)initWithNumber: (NSInteger)number andFrame:(CGRect)frame;

+ (instancetype)numberCellWithNumber:(NSInteger)number andFrame:(CGRect)frame;

- (void)moveToTag:(NSInteger)tag andNumber:(NSInteger)number;

@end
