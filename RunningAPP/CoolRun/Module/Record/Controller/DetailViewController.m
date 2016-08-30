//
//  DetailViewController.m
//  CoolRun
//
//  Created by 蔡欣东 on 16/5/17.
//  Copyright © 2016年 蔡欣东. All rights reserved.
//

#import "DetailViewController.h"
#import "ResultViewController.h"
#import "RecordCardView.h"
#import "XDPageView.h"

@interface DetailViewController ()

@property (weak, nonatomic, readwrite) IBOutlet UILabel *nameLabel;

@property (nonatomic, strong, readwrite) XDPageView *pageView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initContentView];
    
    [self KVOHandler];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.KVOController = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - private

- (void)initContentView {
    
    if (_viewModel.recordViewModels.count>0) self.nameLabel.text = [NSString stringWithFormat:@"1/%ld",(unsigned long)_viewModel.recordViewModels.count];
    
    __weak typeof(self)self_weak_ = self;
    _pageView = [[XDPageView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT-64)];

    _pageView.pagesCount = ^NSInteger(){
        return self_weak_.viewModel.recordViewModels.count;
    };
    
    _pageView.loadViewAtIndexBlock = ^UIView *(NSInteger pageIndex,UIView *dequeueView) {
        RecordCardView *cardView = nil;
        if (dequeueView == nil) {
            dequeueView = [[UIView alloc] initWithFrame:self_weak_.pageView.bounds];
            cardView = [[RecordCardView alloc] init];
            cardView.tag = 1;
            [cardView setFrame:CGRectMake(20 , 0, WIDTH - 40, HEIGHT - 100 - 40)];
            [dequeueView addSubview:cardView];
        }else {
            cardView = (RecordCardView *)[dequeueView viewWithTag:1];
        }

        [cardView configureViewWithViewModel:self_weak_.viewModel.recordViewModels[pageIndex]];

        return dequeueView;
    };
    
    [self.view addSubview:_pageView];
    [self.view sendSubviewToBack:_pageView];
    
}

- (void)KVOHandler {
    [self.KVOController observe:_pageView keyPath:@"currentPageIndex" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        self.nameLabel.text = [NSString stringWithFormat:@"%ld/%ld",_pageView.currentPageIndex+1,(unsigned long)_viewModel.recordViewModels.count];
    }];
}

#pragma mark - event

- (IBAction)closeBtnClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)shareBtnClick:(UIButton *)sender {
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = @"测试";
    [UMSocialData defaultData].extConfig.wechatSessionData.title = @"测试";
    [UMSocialData defaultData].extConfig.wechatSessionData.url = @"http://www.baidu.com";
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = @"http://www.baidu.com";
    if (![[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"weixin://app/wx9f58f3e0c08f1f2a/"]]) {
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:nil
                                          shareText:@"测试"
                                         shareImage:nil
                                    shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,nil]
                                           delegate:nil];
    }else {
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:nil
                                          shareText:@"测试"
                                         shareImage:nil
                                    shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline,nil]
                                           delegate:nil];
        
    }
}



@end
