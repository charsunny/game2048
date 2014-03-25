//
//  SXViewController.m
//  game2048
//
//  Created by Sun Xi on 3/19/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import "SXViewController.h"
#import "SXNumberCell.h"
#import "SXSettingViewController.h"
#import "SXAppConfig.h"
#import "WXApi.h"

@interface SXViewController ()<UIAlertViewDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (strong, nonatomic) NSMutableSet* emptyCellIndexes;

@property (weak, nonatomic) IBOutlet UIView *scoreBgView;

@property (weak, nonatomic) IBOutlet UIView *highScoreBgView;

@property (weak, nonatomic) IBOutlet UILabel *nowScoreLabel;

@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel;

@property (weak, nonatomic) IBOutlet UIView *headerBar;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *undoButton;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (assign) NSInteger nowScore;

@property (assign) NSInteger highScore;

@property (assign) BOOL moved;

@property (strong, nonatomic) NSMutableArray* stateArray;

@property (strong, nonatomic) NSArray* themes;

@end

@implementation SXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib
    
    _themes = [[SXAppConfig sharedAppConfig] theme];
    
    int currentTheme = [[SXAppConfig sharedAppConfig] currectTheme];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB([_themes[currentTheme][@"bgcell"] integerValue])];
        [self.toolbar setBarTintColor:UIColorFromRGB([_themes[currentTheme][@"bgcell"] integerValue])];
    }
    
    [_headerBar setBackgroundColor:UIColorFromRGB([_themes[currentTheme][@"bg"] integerValue])];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onThemeChanged:) name:@"themechanged" object:nil];
    _stateArray = [NSMutableArray new];
    
    _scoreBgView.layer.cornerRadius = 3.0f;
    _scoreBgView.layer.masksToBounds = YES;
    _highScoreBgView.layer.cornerRadius = 3.0f;
    _highScoreBgView.layer.masksToBounds = YES;
    
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"highscore"]) {
        [[NSUserDefaults standardUserDefaults] setValue:@(_highScore) forKey:@"highscore"];
    }
    _highScore = [[[NSUserDefaults standardUserDefaults] valueForKey:@"highscore"] integerValue];
    [_highScoreLabel setText:[NSString stringWithFormat:@"%ld",(long)_highScore]];
    
    srand((int)time(NULL));
    _emptyCellIndexes = [[NSMutableSet alloc] initWithObjects:
                         @0, @1, @2, @3,
                         @4, @5, @6, @7,
                         @8, @9, @10, @11,
                         @12, @13, @14, @15,
                         nil];
    [self initBgWith:_themes[currentTheme]];
    UISwipeGestureRecognizer* swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveLeft)];
    [swipeLeftRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeftRecognizer];
    
    UISwipeGestureRecognizer* swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveRight)];
    [swipeRightRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRightRecognizer];
    
    UISwipeGestureRecognizer* swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveUp)];
    [swipeUpRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:swipeUpRecognizer];
    
    UISwipeGestureRecognizer* swipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveDown)];
    [swipeDownRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swipeDownRecognizer];
    
    _moved = YES;
    [self addNumberCell];
    [self addNumberCell];
    [self updateState];
    _moved = NO;
    [_undoButton setEnabled:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        _bgView.center = CGPointMake(_bgView.center.x, _bgView.center.y-32);
    }
}

- (void)initBgWith:(NSDictionary*)theme
{
    [_bgView.layer setCornerRadius:3];
    [_bgView.layer setMasksToBounds:YES];
    [_bgView setBackgroundColor:UIColorFromRGB([theme[@"bg"] integerValue])];
    for (int i =0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
            [bgView setBackgroundColor:UIColorFromRGB([theme[@"bgcell"] integerValue])];
            [bgView.layer setCornerRadius:3.0f];
            [bgView.layer setMasksToBounds:YES];
            [bgView setTag:i*4+j+100];
            bgView.center = CGPointMake(43 + 78*j , 43 + 78*i);
            [_bgView addSubview:bgView];
        }
    }
}

- (void)judgeIsOver {
    BOOL over = YES;
    for (int i = 0; i < 4; i++) {
        for (int j = 1; j < 4; j++) {
            SXNumberCell* rowcell = (SXNumberCell*)[_bgView viewWithTag:i*4+j+1];
            SXNumberCell* perrowcell = (SXNumberCell*)[_bgView viewWithTag:i*4+j];
            if (rowcell.number == perrowcell.number) {
                over = NO;
                break;
            }
            SXNumberCell* colcell = (SXNumberCell*)[_bgView viewWithTag:j*4+i+1];
            SXNumberCell* percolcell = (SXNumberCell*)[_bgView viewWithTag:(j-1)*4+i+1];
            if (colcell.number == percolcell.number) {
                over = NO;
                break;
            }
        }
    }
    if (over) {
        [[NSUserDefaults standardUserDefaults] setValue:@(_highScore) forKey:@"highscore"];
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"你输了，哈哈！" delegate:self cancelButtonTitle:@"再来一发" otherButtonTitles:nil, nil] show];
    }
}

- (void)addNumberCell {
    if (_emptyCellIndexes.count > 0) {
        NSArray* objects = [_emptyCellIndexes allObjects];
        NSInteger cellIndex = [[objects objectAtIndex:(rand()%objects.count)] integerValue];
        [_emptyCellIndexes removeObject:@(cellIndex)];
        SXNumberCell* cell = [SXNumberCell numberCellWithNumber:rand()%15?2:4 andFrame:CGRectMake(0, 0, 70, 70)];
        NSInteger posX = cellIndex%4;
        NSInteger posY = cellIndex/4;
        cell.center = CGPointMake(43+78*posX, 43 + 78*posY);
        cell.transform = CGAffineTransformMakeScale(0.05, 0.05);
        [cell setTag:cellIndex+1];
        [_bgView addSubview:cell];
        [UIView animateWithDuration:0.1f animations:^{
            cell.transform = CGAffineTransformMakeScale(1.1, 1.1);
        } completion:^(BOOL finished) {
            if (finished) {
                [UIView animateWithDuration:0.15 animations:^{
                    cell.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                }];
            }
        }];
    }
}

- (void)addNumberCellAtIndex:(NSInteger)index withNumber:(NSInteger)number{
    if (_emptyCellIndexes.count > 0) {
        [_emptyCellIndexes removeObject:@(index)];
        SXNumberCell* cell = [SXNumberCell numberCellWithNumber:number andFrame:CGRectMake(0, 0, 70, 70)];
        NSInteger posX = index%4;
        NSInteger posY = index/4;
        cell.center = CGPointMake(43+78*posX, 43 + 78*posY);
        cell.transform = CGAffineTransformMakeScale(0.05, 0.05);
        [cell setTag:index+1];
        [_bgView addSubview:cell];
        [UIView animateWithDuration:0.1f animations:^{
            cell.transform = CGAffineTransformMakeScale(1.1, 1.1);
        } completion:^(BOOL finished) {
            if (finished) {
                [UIView animateWithDuration:0.15 animations:^{
                    cell.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                }];
            }
        }];
    }
}

- (void)updateState {
    [_undoButton setEnabled:YES];
    [_nowScoreLabel setText:[NSString stringWithFormat:@"%ld",(long)_nowScore]];
    if(_nowScore > _highScore) {
        _highScore = _nowScore;
        [_highScoreLabel setText:[NSString stringWithFormat:@"%ld",(long)_highScore]];
    }
    _emptyCellIndexes.count?:[self judgeIsOver];
    if(_moved) {
        [self addNumberCell];
        NSMutableArray* nowstate = [NSMutableArray new];
        for (int i = 0; i < 16; i++) {
            SXNumberCell* cell = (SXNumberCell*)[_bgView viewWithTag:(i+1)];
            if (cell && [cell isKindOfClass:[SXNumberCell class]]) {
                [nowstate addObject:@(cell.number)];
            } else {
                [nowstate addObject:@0];
            }
        }
        [nowstate addObject:@(_nowScore)];
        [nowstate addObject:@(_highScore)];
        [_stateArray addObject:nowstate];
    }
}

- (void)restoreState {
    [_stateArray removeLastObject];
    NSArray* nowstate = [_stateArray lastObject];
    if (_stateArray.count == 1) {
        [_undoButton setEnabled:NO];
    }
    for (int i = 0; i < 16; i++) {
        int number = [nowstate[i] intValue];
        SXNumberCell* cell = (SXNumberCell*)[_bgView viewWithTag:i+1];
        if (number > 0) {
            [_emptyCellIndexes removeObject:@(i)];
            if ([cell isKindOfClass:[SXNumberCell class]]) {
                [cell setNumber:number];
            } else {
                [self addNumberCellAtIndex:i withNumber:number];
            }
        } else {
            if ([cell isKindOfClass:[SXNumberCell class]]) {
                [cell removeFromSuperview];
                [_emptyCellIndexes addObject:@(i)];
            }
        }
    }
}

- (void)moveRight {
    _moved = NO;
    for (NSInteger i = 0; i < 4; i++) {
        NSMutableArray* array = [NSMutableArray new];
        for (NSInteger j = 3; j >= 0; j--) {
            NSInteger tag = i*4 + j + 1;
            if ([_bgView viewWithTag:tag]) {
                SXNumberCell* cell = (SXNumberCell*)[_bgView viewWithTag:tag];
                SXNumberCell* lastCell = [array lastObject];
                if (cell.number == lastCell.number && !lastCell.mergeCell) {
                    [lastCell setMergeCell:cell.tag];
                    [lastCell setNumber:2*cell.number];
                    _nowScore += lastCell.number;
                } else {
                    [array addObject:cell];
                }
            }
        }
        [array enumerateObjectsUsingBlock:^(SXNumberCell* cell, NSUInteger idx, BOOL *stop) {
            if (cell.tag != i*4+4-idx || cell.mergeCell != 0) {
                _moved = YES;
                [_emptyCellIndexes removeObject:@(i*4+3-idx)];
                [cell moveToTag:i*4+4-idx andNumber:cell.number];
            }
        }];
        for (int k = 0; k < 4 - array.count; k++) {
            [_emptyCellIndexes addObject:@(i*4+k)];
        }
    }
    [self updateState];
}

- (void)moveLeft {
    _moved = NO;
    for (NSInteger i = 0; i < 4; i++) {
        NSMutableArray* array = [NSMutableArray new];
        for (NSInteger j = 0; j < 4; j++) {
            NSInteger tag = i*4 + j + 1;
            if ([_bgView viewWithTag:tag]) {
                SXNumberCell* cell = (SXNumberCell*)[_bgView viewWithTag:tag];
                SXNumberCell* lastCell = [array lastObject];
                if (cell.number == lastCell.number && !lastCell.mergeCell) {
                    [lastCell setMergeCell:cell.tag];
                    [lastCell setNumber:2*cell.number];
                    _nowScore += lastCell.number;
                } else {
                    [array addObject:cell];
                }
            }
        }
        [array enumerateObjectsUsingBlock:^(SXNumberCell* cell, NSUInteger idx, BOOL *stop) {
            if (cell.tag != i*4+idx+1 || cell.mergeCell != 0) {
                _moved = YES;
                [_emptyCellIndexes removeObject:@(i*4+idx)];
                [cell moveToTag:i*4+idx+1 andNumber:cell.number];
            }
        }];
        for (int k = 0; k < 4 - array.count; k++) {
            [_emptyCellIndexes addObject:@(i*4+3-k)];
        }
    }
    [self updateState];
}

- (void)moveUp {
    _moved = NO;
    for (NSInteger i = 0; i < 4; i++) {
        NSMutableArray* array = [NSMutableArray new];
        for (NSInteger j = 0; j < 4; j++) {
            NSInteger tag = j*4 + i + 1;
            if ([_bgView viewWithTag:tag]) {
                SXNumberCell* cell = (SXNumberCell*)[_bgView viewWithTag:tag];
                SXNumberCell* lastCell = [array lastObject];
                if (cell.number == lastCell.number && !lastCell.mergeCell) {
                    [lastCell setMergeCell:cell.tag];
                    [lastCell setNumber:2*cell.number];
                    _nowScore += lastCell.number;
                } else {
                    [array addObject:cell];
                }
            }
        }
        [array enumerateObjectsUsingBlock:^(SXNumberCell* cell, NSUInteger idx, BOOL *stop) {
            if (cell.tag != i+4*idx+1 || cell.mergeCell != 0) {
                _moved = YES;
                [_emptyCellIndexes removeObject:@(i+4*idx)];
                [cell moveToTag:i+4*idx+1 andNumber:cell.number];
            }
        }];
        for (int k = 0; k < 4 - array.count; k++) {
            [_emptyCellIndexes addObject:@((3-k)*4+i)];
        }
    }
    [self updateState];
}

- (void)moveDown {
    _moved = NO;
    for (NSInteger i = 0; i < 4; i++) {
        NSMutableArray* array = [NSMutableArray new];
        for (NSInteger j = 3; j >= 0; j--) {
            NSInteger tag = j*4 + i + 1;
            if ([_bgView viewWithTag:tag]) {
                SXNumberCell* cell = (SXNumberCell*)[_bgView viewWithTag:tag];
                SXNumberCell* lastCell = [array lastObject];
                if (cell.number == lastCell.number && !lastCell.mergeCell) {
                    [lastCell setMergeCell:cell.tag];
                    [lastCell setNumber:2*cell.number];
                    _nowScore += lastCell.number;
                } else {
                    [array addObject:cell];
                }
            }
        }
        [array enumerateObjectsUsingBlock:^(SXNumberCell* cell, NSUInteger idx, BOOL *stop) {
            if (cell.tag != (3-idx)*4+i+1 || cell.mergeCell != 0) {
                _moved = YES;
                [_emptyCellIndexes removeObject:@((3-idx)*4+i)];
                [cell moveToTag:(3-idx)*4+i+1 andNumber:cell.number];
            }
        }];
        for (int k = 0; k < 4 - array.count; k++) {
            [_emptyCellIndexes addObject:@(i+4*k)];
        }
    }
    [self updateState];
}

- (IBAction)refresh:(id)sender {
    SXHistoryModel* model = [SXHistoryModel new];
    model.score = _nowScore;
    model.steps = _stateArray;
    NSDateFormatter* foramter = [NSDateFormatter new];
    [foramter setDateFormat:@"yyyy-MM-dd HH:mm"];
    model.time = [foramter stringFromDate:[NSDate date]];
    [[SXAppConfig sharedAppConfig] appendHistory:model];
    _nowScore = 0;
    [_stateArray removeAllObjects];
    [_nowScoreLabel setText:[NSString stringWithFormat:@"%ld",(long)_nowScore]];
    if(_nowScore > _highScore) {
        _highScore = _nowScore;
        [_highScoreLabel setText:[NSString stringWithFormat:@"%ld",(long)_highScore]];
    }
    [[NSUserDefaults standardUserDefaults] setValue:@(_highScore) forKey:@"highscore"];
    _emptyCellIndexes = [[NSMutableSet alloc] initWithObjects:
                         @0, @1, @2, @3,
                         @4, @5, @6, @7,
                         @8, @9, @10, @11,
                         @12, @13, @14, @15,
                         nil];
    [[_bgView subviews] enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[SXNumberCell class]]) {
            [obj removeFromSuperview];
        }
    }];
    _moved = YES;
    [self addNumberCell];
    [self addNumberCell];
    [self updateState];
    _moved = NO;
    [_undoButton setEnabled:NO];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self refresh:nil];
    }
}

#pragma mark -- toolbar methods

- (IBAction)onUndo:(UIBarButtonItem*)sender {
    [self restoreState];
}

- (IBAction)onRetry:(UIBarButtonItem*)sender {
    [[[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要重新开始吗？" delegate:self cancelButtonTitle:@"再来一发" otherButtonTitles:@"取消", nil] show];
}

#pragma mark -- notification

- (void)onThemeChanged:(NSNotification*)notify {
    NSDictionary* theme = [_themes objectAtIndex:[notify.object intValue]];
    [_bgView setBackgroundColor:UIColorFromRGB([theme[@"bg"] integerValue])];
    [_headerBar setBackgroundColor:UIColorFromRGB([theme[@"bgcell"] integerValue])];
    for (int i =0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            UIView* cellBg = [_bgView viewWithTag:i*4+j+100];;
            [cellBg setBackgroundColor:UIColorFromRGB([theme[@"bgcell"] integerValue])];
            SXNumberCell* cell = (SXNumberCell*)[_bgView viewWithTag:i*4+j+1];
            if (cell) {
                [cell setNumber:cell.number];
            }
        }
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB([theme[@"bgcell"] integerValue])];
        [self.toolbar setBarTintColor:UIColorFromRGB([theme[@"bgcell"] integerValue])];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SXSettingViewController class]] ) {
        SXSettingViewController* controller = segue.destinationViewController;
        controller.themes = _themes;
    }
}

- (IBAction)shareButtonClicked:(id)sender {
    [[[UIActionSheet alloc] initWithTitle:@"分享" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"微信好友",@"微信朋友圈",nil] showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [self sendImageContentToCircle:NO];
    } else if (buttonIndex == 1) {
        [self sendImageContentToCircle:YES];
    }
}

- (void) sendImageContentToCircle:(BOOL)circle {    //发送内容给微信
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"好玩的2048游戏";
    message.description = @"过来跟我一起玩吧！";
    [message setThumbImage:[UIImage imageNamed:@"AppIcon"]];
    
    WXAppExtendObject *ext = [WXAppExtendObject object];
    ext.extInfo = @"<xml>test</xml>";
    ext.url = @"http://www.baidu.com";
    
    Byte* pBuffer = (Byte *)malloc(1024 * 100);
    memset(pBuffer, 0, 1024 * 100);
    NSData* data = [NSData dataWithBytes:pBuffer length:1024 * 100];
    free(pBuffer);
    
    ext.fileData = data;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = circle?WXSceneTimeline:WXSceneSession;
    
    [WXApi sendReq:req];
}


@end
