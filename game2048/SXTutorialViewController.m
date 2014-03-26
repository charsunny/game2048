//
//  SXTutorialViewController.m
//  game2048
//
//  Created by Sun Xi on 3/25/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import "SXTutorialViewController.h"

@interface SXTutorialViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation SXTutorialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews
{
    [_scrollview setContentSize:CGSizeMake(640, _scrollview.frame.size.height)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    int page = _scrollview.contentOffset.x/320;//通过滚动的偏移量来判断目前页面所对应的小白点
    
    _pageControl.currentPage = page;//pagecontroll响应值的变化
    
}



- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    
    
}


- (IBAction)changePage:(id)sender {
    
    NSInteger page = _pageControl.currentPage;//获取当前pagecontroll的值
    
    [_scrollview setContentOffset:CGPointMake(320 * page, 0)];//根据pagecontroll的值来改变scrollview的滚动位置，以此切换到指定的页面
    
}

- (IBAction)startGame:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        //do nothing
    }];
}

@end
