//
//  BDSquareMoreView.m
//  BengDa
//
//  Created by abc on 16/4/6.
//  Copyright © 2016年 daniel.sun. All rights reserved.
//

#import "BDSquareMoreView.h"




@interface BDSquareMoreView ()
{
    UIWindow *_mainWindow;
    UIControl*_backgroundView;
    BDSquareMoreViewNoneController *tmpCtr;
}
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UIButton *weiBo;
@property (strong, nonatomic) UIButton *weiXin;
@property (strong, nonatomic) UIButton *pengYouQuan;
@property (strong, nonatomic) UIButton *KongJian;
@property (strong, nonatomic) UILabel *weiBoLabel;
@property (strong, nonatomic) UILabel *weiXinLabel;
@property (strong, nonatomic) UILabel *pengYouQuanLabel;
@property (strong, nonatomic) UILabel *kongJianLabel;
@property (strong, nonatomic) UIButton *QQ;
@property (strong, nonatomic) UILabel *qqLabel;
@property (strong, nonatomic) UIButton *quXiao;


@property (strong, nonatomic) __block UILabel *tipsLabel; // 提示label

@property (assign, nonatomic) BOOL isCancle;
@end
@implementation BDSquareMoreView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubView];
        
    }
    return self;
}

-(void)initSubView{
    
    self.backgroundColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:243/255.0 alpha:1.0];
    
    _bottomView = [[UIView alloc]init];
    _bottomView.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
    
    [self addSubview:_bottomView];
    
    
    
    _weiXin = [UIButton buttonWithType:UIButtonTypeCustom];
    _weiXin.tag = 1000;
    [_weiXin setBackgroundImage:[UIImage imageNamed:@"icon_weixin"] forState:UIControlStateNormal];
    [_weiXin addTarget:self action:@selector(shareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _pengYouQuan = [UIButton buttonWithType:UIButtonTypeCustom];
    _pengYouQuan.tag = 1001;
    [_pengYouQuan setBackgroundImage:[UIImage imageNamed:@"icon_pyq"] forState:UIControlStateNormal];
    [_pengYouQuan addTarget:self action:@selector(shareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _KongJian = [UIButton buttonWithType:UIButtonTypeCustom];
    _KongJian.tag = 1002;
    [_KongJian setBackgroundImage:[UIImage imageNamed:@"icon_kongjian"] forState:UIControlStateNormal];
    [_KongJian addTarget:self action:@selector(shareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _QQ = [UIButton buttonWithType:UIButtonTypeCustom];
    _QQ.tag = 1003;
    [_QQ setBackgroundImage:[UIImage imageNamed:@"icon_weibo"] forState:UIControlStateNormal];
    [_QQ addTarget:self action:@selector(shareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _weiBo = [UIButton buttonWithType:UIButtonTypeCustom];
    _weiBo.tag = 1004;
    [_weiBo setBackgroundImage:[UIImage imageNamed:@"icon_weibo"] forState:UIControlStateNormal];
    [_weiBo addTarget:self action:@selector(shareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _weiXinLabel = [[UILabel alloc]init];
    _weiXinLabel.textAlignment = NSTextAlignmentCenter;
    _weiXinLabel.font = [UIFont systemFontOfSize:12];
    _weiXinLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
    
    
    _pengYouQuanLabel = [[UILabel alloc]init];
    _pengYouQuanLabel.textAlignment = NSTextAlignmentCenter;
    _pengYouQuanLabel.font = [UIFont systemFontOfSize:12];
    _pengYouQuanLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
    
    
    _kongJianLabel = [[UILabel alloc]init];
    _kongJianLabel.font = [UIFont systemFontOfSize:12];
    _kongJianLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
    _kongJianLabel.textAlignment = NSTextAlignmentCenter;
    
    
    
    _qqLabel = [[UILabel alloc]init];
    _qqLabel.font = [UIFont systemFontOfSize:12];
    _qqLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
    _qqLabel.textAlignment = NSTextAlignmentCenter;
    
    
    _weiBoLabel = [[UILabel alloc]init];
    _weiBoLabel.textAlignment = NSTextAlignmentCenter;
    _weiBoLabel.font = [UIFont systemFontOfSize:12];
    _weiBoLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
    
    
    [_bottomView addSubview:_weiXin];
    [_bottomView addSubview:_pengYouQuan];
    [_bottomView addSubview:_KongJian];
    [_bottomView addSubview:_QQ];
    [_bottomView addSubview:_weiBo];
    
    
    [_bottomView addSubview:_weiXinLabel];
    [_bottomView addSubview:_pengYouQuanLabel];
    [_bottomView addSubview:_kongJianLabel];
    [_bottomView addSubview:_qqLabel];
    [_bottomView addSubview:_weiBoLabel];
    
    _quXiao = [UIButton buttonWithType:UIButtonTypeCustom];
    [_quXiao setTitle:@"取消" forState:UIControlStateNormal];
    [_quXiao setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0] forState:UIControlStateNormal];
    [_quXiao addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _quXiao.backgroundColor = [UIColor whiteColor];
    _quXiao.titleLabel.font = [UIFont systemFontOfSize:15];
    [_bottomView addSubview:_quXiao];
    
    
    
    _mainWindow = [[UIWindow alloc] initWithFrame:BY_ScreenBounds];
    _mainWindow.windowLevel = UIWindowLevelAlert;
    [_mainWindow makeKeyAndVisible];
    
    _backgroundView = [[UIControl alloc] initWithFrame:BY_ScreenBounds];
    _backgroundView.backgroundColor = [UIColor colorWithHue:178/255.0f saturation:116/255.0f brightness:24/255.0f alpha:0.5f];
    _backgroundView.alpha = 0.0f;
    [_backgroundView addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}




-(void)showWith:(NSArray *)itemAry{
    
    CGFloat height;
    CGFloat width = BY_ScreenBounds.size.width;
    if (itemAry.count <= 4) {
        height = 160;
    }else{
        height = 275;
    }
    self.frame = CGRectMake(0, BY_ScreenBounds.size.height-height, width, height);
    _bottomView.frame = CGRectMake(0, 0, width, height);
    
    
    _weiBo.hidden = YES;
    _weiBoLabel.hidden = YES;
    
    _weiXin.hidden = YES;
    _weiXinLabel.hidden = YES;
    
    _pengYouQuan.hidden = YES;
    _pengYouQuanLabel.hidden = YES;
    
    _KongJian.hidden = YES;
    _kongJianLabel.hidden = YES;
    
    CGFloat jianGe;
    if (itemAry.count ==2) {
        jianGe = 42.0;
        _weiXin.hidden = NO;
        _weiXinLabel.hidden = NO;
        _pengYouQuan.hidden = NO;
        _pengYouQuanLabel.hidden = NO;
        
        _weiXin.frame = CGRectMake(width/2-88, 23, 46, 46);
        _weiXinLabel.text = (NSString *)itemAry[0];
        
        _pengYouQuan.frame = CGRectMake(CGRectGetMaxX(_weiXin.frame)+jianGe, 49, 40, 40);
        _pengYouQuanLabel.text = (NSString *)itemAry[1];
        
        _weiXinLabel.frame = CGRectMake(CGRectGetMidX(_weiXin.frame)-20, CGRectGetMaxY(_weiBo.frame)+7, 40, 12);
        _pengYouQuanLabel.frame = CGRectMake(CGRectGetMidX(_pengYouQuan.frame)-30, CGRectGetMaxY(_weiBo.frame)+7, 60, 12);
        
        
    }else {
        jianGe = (width-234)/3;
        _weiBo.hidden = NO;
        _weiBoLabel.hidden = NO;
        _weiXin.hidden = NO;
        _weiXinLabel.hidden = NO;
        _pengYouQuan.hidden = NO;
        _pengYouQuanLabel.hidden = NO;
        _KongJian.hidden = NO;
        _kongJianLabel.hidden = NO;
        
        
        _weiXin.frame = CGRectMake(25, 51, 46, 46);
        _weiXinLabel.frame = CGRectMake(CGRectGetMidX(_weiXin.frame)-20, CGRectGetMaxY(_weiXin.frame)+7, 40, 12);
        _weiXinLabel.text = (NSString *)itemAry[0];
        
        _pengYouQuan.frame = CGRectMake(CGRectGetMaxX(_weiXin.frame)+jianGe, 51, 46, 46);
        _pengYouQuanLabel.frame = CGRectMake(CGRectGetMidX(_pengYouQuan.frame)-30, CGRectGetMaxY(_pengYouQuan.frame)+7, 60, 12);
        _pengYouQuanLabel.text = (NSString *)itemAry[1];
        
        
        _KongJian.frame = CGRectMake(CGRectGetMaxX(_pengYouQuan.frame)+jianGe, 51, 46, 46);
        _kongJianLabel.text = (NSString *)itemAry[2];
        _kongJianLabel.frame = CGRectMake(CGRectGetMidX(_KongJian.frame)-40, CGRectGetMaxY(_KongJian.frame)+7, 80, 12);
        
        
        _QQ.frame = CGRectMake(CGRectGetMaxX(_KongJian.frame)+jianGe, 51, 46, 46);
        _qqLabel.text = (NSString *)itemAry[3];
        _qqLabel.frame = CGRectMake(CGRectGetMidX(_QQ.frame)-40, CGRectGetMaxY(_QQ.frame)+7, 80, 12);
        
        _weiBo.frame = CGRectMake(25, 142, 46, 46);
        _weiBoLabel.text = (NSString *)itemAry[4];
        _weiBoLabel.frame = CGRectMake(CGRectGetMidX(_weiBo.frame)-20, CGRectGetMaxY(_weiBo.frame)+7, 40, 12);
    }
    
    _quXiao.frame = CGRectMake(0, height-48, width, 48);
    
    [self animationShow];
}



-(void) showTips:(NSString *)tips{
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc]init];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.font = [UIFont systemFontOfSize:14];
        _tipsLabel.textColor = [UIColor whiteColor];
        _tipsLabel.layer.cornerRadius = 3.0f;
        _tipsLabel.layer.masksToBounds = YES;
        _tipsLabel.backgroundColor = [UIColor redColor];
    }
    _tipsLabel.text = nil;
    _tipsLabel.text = tips;
    [_tipsLabel sizeToFit];
//    BY_ScreenBounds
    _tipsLabel.frame = CGRectMake((BY_ScreenBounds.size.width - CGRectGetWidth(_tipsLabel.frame)-40)/2, (BY_ScreenBounds.size.height - CGRectGetHeight(_tipsLabel.frame)-20)/2, CGRectGetWidth(_tipsLabel.frame)+40, CGRectGetHeight(_tipsLabel.frame)+20);
    
    
    [_backgroundView addSubview:_tipsLabel];
    [_backgroundView bringSubviewToFront:_tipsLabel];

    [self performSelector:@selector(ShowTipsHiddeAnimotion) withObject:nil afterDelay:3.0];
}


-(void)ShowTipsHiddeAnimotion{
    
    __weak BDSquareMoreView *weakSelf = self;
    [UIView animateWithDuration:1.0f
                        animations:^{
        weakSelf.tipsLabel.alpha = 0.0f;
    }completion:^(BOOL finished) {
        [weakSelf.tipsLabel removeFromSuperview];
        weakSelf.tipsLabel = nil;
    }];
    
}
#pragma mark 取消对应的操作
- (void)cancelButtonPressed:(id)sender{
    
    if (self.cancelClickBlock) {
        self.cancelClickBlock();
    }
    self.isCancle = YES;
    [self animationHidden];
}

#pragma mark 分享对应的操作
- (void)shareButtonPressed:(id)sender{
    UIButton *button = (UIButton *)sender;
    if (self.shareClickBlock) {
        self.shareClickBlock(button.tag-1000);
    }
}

#pragma mark 举报，删除，收藏对应的操作
-(void)otherButtonPressed:(id)sender{
    
    UIButton *button = (UIButton *)sender;
    if (self.otherClickBlock) {
        self.otherClickBlock(button.tag-2000);
    }
}

#pragma mark- commons
- (void)animationShow{
    
    __weak UIView *weakBackgroundView = _backgroundView;
    __weak BDSquareMoreView *weakSelf = self;
    
    [_mainWindow addSubview:_backgroundView];
    [_mainWindow addSubview:self];
    [_mainWindow makeKeyAndVisible];
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         
                         weakBackgroundView.alpha = 1.0f;
                         weakSelf.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
}


- (void)animationHidden{
    
    __weak BDSquareMoreView *weakSelf = self;
    __weak UIControl *weakBackgroundView = _backgroundView;
    __weak UIWindow *weakMainWindow = _mainWindow;
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         
                         weakBackgroundView.alpha = 0.0f;
                         weakSelf.alpha = 0.0f;
                         weakMainWindow.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [weakMainWindow removeFromSuperview];
                         _mainWindow.rootViewController = nil;
                         [weakSelf removeFromSuperview];
                         if (!self.isCancle) {
                             
                         }
                         
                     }];
}


@end

@implementation BDSquareMoreViewNoneController

- (void)viewDidLoad{
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.bounds = [UIScreen mainScreen].bounds;
    
}

#pragma mark 屏幕旋转
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    
    return  YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
- (BOOL)shouldAutorotate{
    
    return YES;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    
    
    return UIInterfaceOrientationPortrait;
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    if (self.orientationBlock) {
        self.orientationBlock();
    }
}


@end

