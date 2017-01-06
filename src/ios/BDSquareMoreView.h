//
//  BDSquareMoreView.h
//  BengDa
//
//  Created by abc on 16/4/6.
//  Copyright © 2016年 daniel.sun. All rights reserved.
//

#import <UIKit/UIKit.h>


#define BY_ScreenFrame   [UIScreen mainScreen].applicationFrame
#define BY_ScreenBounds  [UIScreen mainScreen].bounds




@interface BDSquareMoreView : UIView



@property (copy, nonatomic) void (^shareClickBlock)(NSInteger aIndex);
@property (copy, nonatomic) void (^cancelClickBlock)(void);
@property (copy, nonatomic) void (^otherClickBlock)(NSInteger aIdex);


@property (assign, nonatomic) BOOL isLandscape;


- (void)showWith:(NSArray *)itemAry;
- (void)shareButtonPressed:(id)sender;
- (void)cancelButtonPressed:(id)sender;

- (void)animationHidden;

-(void) showTips:(NSString *)tips;

@end


@interface BDSquareMoreViewNoneController : UIViewController


@property (copy , nonatomic) void (^orientationBlock)(void);

@end

