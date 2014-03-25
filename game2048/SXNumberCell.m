//
//  SXNumberCell.m
//  game2048
//
//  Created by Sun Xi on 3/20/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import "SXNumberCell.h"
#import "SXAppConfig.h"


@interface SXNumberCell()

@property (strong, nonatomic) UILabel* numLabel;


@end

@implementation SXNumberCell

- (UIColor*)getNumberColor:(NSInteger)number {
    int currectTheme = [[SXAppConfig sharedAppConfig] currectTheme];
    NSDictionary* theme = [[SXAppConfig sharedAppConfig] theme][currectTheme];
    NSArray* colors = theme[@"cell"];
    int index = (int)log2(number);
    int color = [colors[index%colors.count] intValue];
    return UIColorFromRGB(color);
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
        [_numLabel setTextColor:[UIColor whiteColor]];
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
