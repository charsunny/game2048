//
//  SXNumberCell.m
//  game2048
//
//  Created by Sun Xi on 3/20/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import "SXNumberCell.h"


@interface SXNumberCell()

@property (strong, nonatomic) UILabel* numLabel;


@end

@implementation SXNumberCell

- (UIColor*)getNumberColor:(NSInteger)number {
    switch (number) {
        case 2:
            return UIColorFromRGB(0xFFBBFF);
        case 4:
            return UIColorFromRGB(0xFFAEB9);
        case 8:
            return UIColorFromRGB(0xFF8C69);
        case 16:
            return UIColorFromRGB(0xFF34B3);
        case 32:
            return UIColorFromRGB(0x9B30FF);
        case 64:
            return UIColorFromRGB(0xA0522D);
        case 128:
            return UIColorFromRGB(0xA2CD5A);
        case 256:
            return UIColorFromRGB(0x8E8E38);
        case 512:
            return UIColorFromRGB(0x8B2500);
        case 1024:
            return UIColorFromRGB(0x00EE00);
        case 2048:
            return UIColorFromRGB(0x218868);
        case 4096:
            return UIColorFromRGB(0x4169E1);
        case 8192:
            return UIColorFromRGB(0xEE0000);
        default:
            break;
    }
    return [UIColor whiteColor];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor colorWithRed:238/255.0f green:228/255.0f blue:218/255.0f alpha:1.0f]];
        [self.layer setCornerRadius:3.0f];
        [self.layer setMasksToBounds:YES];
        _numLabel = [[UILabel alloc] initWithFrame:self.frame];
        [_numLabel setFont:[UIFont systemFontOfSize:40]];
        [_numLabel setBackgroundColor:[UIColor clearColor]];
        [_numLabel setTextColor:[UIColor colorWithRed:119/255.0 green:110/255.0 blue:101/255.0 alpha:1.0f]];
        [_numLabel setTextAlignment:NSTextAlignmentCenter];
        [_numLabel setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:_numLabel];
    }
    return self;
}

- (id)initWithNumber: (NSInteger)number andFrame:(CGRect)frame {
    if (self = [self initWithFrame:frame]) {
        [self setNumber:number];
    }
    return self;
}

+ (instancetype)numberCellWithNumber:(NSInteger)number andFrame:(CGRect)frame {
    return [[SXNumberCell alloc] initWithNumber:number andFrame:frame];
}

- (void)setNumber:(NSInteger)number {
    _number = number;
    [self setBackgroundColor:[self getNumberColor:number]];
    [_numLabel setText:[NSString stringWithFormat:@"%ld",(long)_number]];
}

- (void)dismissToTag:(NSInteger)tag {
    NSInteger posX = (tag-1)%4;
    NSInteger posY = (tag-1)/4;
    [UIView animateWithDuration:0.1f animations:^{
        self.center = CGPointMake(43+78*posX, 43 + 78*posY);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

- (void)moveToTag:(NSInteger)tag andNumber:(NSInteger)number {
    if (self.tag == tag && self.mergeCell == 0) {
        return;
    }
    if (self.mergeCell) {
        SXNumberCell* mergecell = (SXNumberCell*)[[self superview] viewWithTag:self.mergeCell];
        self.mergeCell = 0;
        [mergecell dismissToTag:tag];
    }
    NSInteger posX = (tag-1)%4;
    NSInteger posY = (tag-1)/4;
    [UIView animateWithDuration:0.15f animations:^{
        self.center = CGPointMake(43+78*posX, 43 + 78*posY);
    } completion:^(BOOL finished) {
        if (finished) {
            [self setTag:tag];
            [self setNumber:number];
        }
    }];
}

@end
