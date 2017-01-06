//
//  ShareManager.h
//  Test
//
//  Created by abc on 2017/1/5.
//  Copyright © 2017年 MEMEDA. All rights reserved.
//

#import <Cordova/CDV.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WXApi.h"
#import "WXApiObject.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "WeiboSDK.h"

enum  CDVWechatSharingType {
    CDVWXSharingTypeApp = 1,
    CDVWXSharingTypeEmotion,
    CDVWXSharingTypeFile,
    CDVWXSharingTypeImage,
    CDVWXSharingTypeMusic,
    CDVWXSharingTypeVideo,
    CDVWXSharingTypeWebPage
};

@interface ShareManager : CDVPlugin<WXApiDelegate,TencentSessionDelegate,QQApiInterfaceDelegate,WeiboSDKDelegate>

- (void)shareAction:(CDVInvokedUrlCommand*)command;


@property (nonatomic, strong) NSString *currentCallbackId;
@property (nonatomic, strong) NSString *wechatAppId;

- (void)isWXAppInstalled:(CDVInvokedUrlCommand *)command;
- (void)sendAuthRequest:(CDVInvokedUrlCommand *)command;
- (void)sendPaymentRequest:(CDVInvokedUrlCommand *)command;
- (void)jumpToBizProfile:(CDVInvokedUrlCommand *)command;
- (void)jumpToWechat:(CDVInvokedUrlCommand *)command;




@property(nonatomic) TencentOAuth *tencentOAuth;
@property(nonatomic, copy) NSString *callback;
@property(nonatomic, copy) NSArray *permissions;

- (void)ssoLogin:(CDVInvokedUrlCommand *)command;

- (void)logout:(CDVInvokedUrlCommand *)command;

- (void)shareToQQ:(CDVInvokedUrlCommand *)command;

- (void)shareToQzone:(CDVInvokedUrlCommand *)command;

- (void)checkClientInstalled:(CDVInvokedUrlCommand *)command;

- (void)addToQQFavorites:(CDVInvokedUrlCommand *)command;




@property(nonatomic, copy) NSString *redirectURI;
@property(nonatomic, copy) NSString *weiboAppId;

- (void)ssoLogin:(CDVInvokedUrlCommand *)command;

- (void)logout:(CDVInvokedUrlCommand *)command;

- (void)shareToWeibo:(CDVInvokedUrlCommand *)command;

- (void)checkClientInstalled:(CDVInvokedUrlCommand *)command;
@end
