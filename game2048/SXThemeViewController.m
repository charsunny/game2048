//
//  SXThemeViewController.m
//  game2048
//
//  Created by Sun Xi on 3/21/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import "SXThemeViewController.h"

@interface SXThemeViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (strong, nonatomic) NSArray* numberArray;

@end

@implementation SXThemeViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _numberArray = @[@"2",@"4",@"8",@"16",@"32",@"64",@"128",@"256",@"512",@"1024",@"2048",@"4096",@"8192"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:[_currectTheme intValue] inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

- (void)addCellBg:(UIView*)bgView withColor:(UIColor*)color
{
    for (int i =0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            UIView* bgCell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            [bgCell setBackgroundColor:color];
            [bgCell.layer setCornerRadius:3.0f];
            [bgCell.layer setMasksToBounds:YES];
            bgCell.center = CGPointMake(19 + 34*j , 19 + 34*i);
            [bgView addSubview:bgCell];
        }
    }
}

- (void)addTestNumber:(UIView*)bgView withColor:(UIColor*)color andPos:(int)pos {
    
    int posX = pos%4;
    int posY = pos/4;
    
    UILabel* numLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [numLabel setFont:[UIFont systemFontOfSize:18]];
    [numLabel setText:_numberArray[pos]];
    [numLabel setBackgroundColor:[UIColor clearColor]];
    [numLabel setTextColor:[UIColor colorWithRed:119/255.0 green:110/255.0 blue:101/255.0 alpha:1.0f]];
    [numLabel setTextAlignment:NSTextAlignmentCenter];
    [numLabel setAdjustsFontSizeToFitWidth:YES];
    
    UIView* bgCell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [bgCell setBackgroundColor:color];
    [bgCell.layer setCornerRadius:3.0f];
    [bgCell.layer setMasksToBounds:YES];
    bgCell.center = CGPointMake(19 + 34*posX , 19 + 34*posY);
    [bgCell addSubview:numLabel];
    
    [bgView addSubview:bgCell];
}

#pragma mark -- collection view delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _themes.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* themeprop = _themes[indexPath.row];
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.layer.cornerRadius = 3.0f;
    [cell.layer setMasksToBounds:YES];
    
    UIView* selectBg = [[UIView alloc] init];
    selectBg.backgroundColor = [UIColor darkGrayColor];
    [cell setSelectedBackgroundView:selectBg];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UILabel* nameLablel = (UILabel*)[cell viewWithTag:101];
        [nameLablel setText:themeprop[@"name"]];
        
        UIView* cellBgView = [cell viewWithTag:100];
        cellBgView.layer.cornerRadius = 2.0f;
        [cellBgView.layer setMasksToBounds:YES];
        [cellBgView setBackgroundColor:UIColorFromRGB([themeprop[@"bg"] intValue])];
        [self addCellBg:cellBgView withColor:UIColorFromRGB([themeprop[@"bgcell"] intValue])];
        
        [themeprop[@"cell"] enumerateObjectsUsingBlock:^(NSNumber* obj, NSUInteger idx, BOOL *stop) {
                [self addTestNumber:cellBgView withColor:UIColorFromRGB([obj intValue]) andPos:(int)idx];
        }];
    });
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.sender isKindOfClass:[UITableViewCell class]]) {
        
        _currectTheme = @(indexPath.row);
        
        NSDictionary* themeprop = _themes[indexPath.row];
        UITableViewCell* cell = (UITableViewCell*)self.sender;
        [cell.detailTextLabel setText:themeprop[@"name"]];
        [[NSUserDefaults standardUserDefaults] setObject:_currectTheme forKey:@"theme"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"themechanged" object:_currectTheme];
    }
}


@end
