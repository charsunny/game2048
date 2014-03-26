//
//  SXReplayViewController.m
//  game2048
//
//  Created by Sun Xi on 3/26/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//
#import "WXApi.h"
#import "WeiboSDK.h"
#import "SXReplayViewController.h"
#import "SXAppConfig.h"
#import "SXNumberCell.h"

@interface SXReplayViewController ()<UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UIView *scoreBgView;

@property (weak, nonatomic) IBOutlet UIView *highScoreBgView;

@property (weak, nonatomic) IBOutlet UILabel *nowScoreLabel;

@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel;

@property (weak, nonatomic) IBOutlet UIView *headerBar;

@property (strong, nonatomic) NSArray* themes;

@property (assign) NSInteger nowScore;

@property (assign) NSInteger highScore;

@end

@implementation SXReplayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _themes = [[SXAppConfig sharedAppConfig] theme];
    
    int currentTheme = [[SXAppConfig sharedAppConfig] currectTheme];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB([_themes[currentTheme][@"bgcell"] integerValue])];
    }
    
    [_headerBar setBackgroundColor:UIColorFromRGB([_themes[currentTheme][@"bg"] integerValue])];
    
    _scoreBgView.layer.cornerRadius = 3.0f;
    _scoreBgView.layer.masksToBounds = YES;
    _highScoreBgView.layer.cornerRadius = 3.0f;
    _highScoreBgView.layer.masksToBounds = YES;
    
    [self initBgWith:_themes[currentTheme]];
    
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"highscore"]) {
        [[NSUserDefaults standardUserDefaults] setValue:@(_highScore) forKey:@"highscore"];
    }
    _highScore = [[[NSUserDefaults standardUserDefaults] valueForKey:@"highscore"] integerValue];
    [_highScoreLabel setText:[NSString stringWithFormat:@"%ld",(long)_highScore]];
    [self restoreHistory:_repleyInfo.steps];
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

- (void)restoreHistory:(NSArray*)nowstate {
    for (int i = 0; i < 16; i++) {
        int number = [nowstate[i] intValue];
        SXNumberCell* cell = (SXNumberCell*)[_bgView viewWithTag:i+1];
        if (number > 0) {
            if ([cell isKindOfClass:[SXNumberCell class]]) {
                [cell setNumber:number];
            } else {
                [self addNumberCellAtIndex:i withNumber:number];
            }
        } else {
            if ([cell isKindOfClass:[SXNumberCell class]]) {
                [cell removeFromSuperview];
            }
        }
    }
    _nowScore = [nowstate[16] integerValue];
    _highScore = [nowstate[17] integerValue];
    [_nowScoreLabel setText:[NSString stringWithFormat:@"%ld",(long)_nowScore]];
    [_highScoreLabel setText:[NSString stringWithFormat:@"%ld",(long)_highScore]];
}

- (void)addNumberCellAtIndex:(NSInteger)index withNumber:(NSInteger)number{
    SXNumberCell* cell = [SXNumberCell numberCellWithNumber:number andFrame:CGRectMake(0, 0, 70, 70)];
    NSInteger posX = index%4;
    NSInteger posY = index/4;
    cell.center = CGPointMake(43+78*posX, 43 + 78*posY);
    [cell setTag:index+1];
    [_bgView addSubview:cell];
}

#pragma mark -- share methods

- (IBAction)shareButtonClicked:(id)sender {
    [[[UIActionSheet alloc] initWithTitle:@"分享" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"微信好友",@"微信朋友圈",@"新浪微博",nil] showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [self sendImageContentToCircle:NO];
    } else if (buttonIndex == 1) {
        [self sendImageContentToCircle:YES];
    } else if (buttonIndex == 2) {
        [self sendImageContentToWeibo];
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

- (void)sendImageContentToWeibo {
    WBMessageObject* message = [[WBMessageObject alloc] init];
    message.text = @"好玩的2048游戏";
    WBImageObject* imageObject = [[WBImageObject alloc] init];
    imageObject.imageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tt1" ofType:@"png"]];
    message.imageObject = imageObject;
    WBSendMessageToWeiboRequest* request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    request.userInfo = @{@"ShareMessageFrom": @"SXViewController"};
    [WeiboSDK sendRequest:request];
}


@end
