//
//  ShareManager.m
//  Test
//
//  Created by abc on 2017/1/5.
//  Copyright © 2017年 MEMEDA. All rights reserved.
//

#import "ShareManager.h"
#import "BDSquareMoreView.h"

static int const MAX_THUMBNAIL_SIZE = 320;
NSString *QQ_NOT_INSTALLED = @"QQ Client is not installed";
NSString *QQ_PARAM_NOT_FOUND = @"param is not found";
NSString *QQ_LOGIN_ERROR = @"QQ login error";
NSString *QQ_LOGIN_CANCEL = @"QQ login cancelled";
NSString *QQ_LOGIN_NETWORK_ERROR = @"QQ login network error";
NSString *QQ_SHARE_CANCEL = @"QQ share cancelled by user";
NSString *appId=@"";



NSString *WEBIO_APP_ID = @"weibo_app_id";
NSString *WEBIO_REDIRECT_URI = @"redirecturi";
NSString *WEBIO_DEFUALT_REDIRECT_URI = @"https://api.weibo.com/oauth2/default.html";
NSString *WEIBO_CANCEL_BY_USER = @"cancel by user";
NSString *WEIBO_SHARE_INSDK_FAIL = @"share in sdk failed";
NSString *WEIBO_SEND_FAIL = @"send failed";
NSString *WEIBO_UNSPPORTTED = @"Weibo unspport";
NSString *WEIBO_AUTH_ERROR = @"Weibo auth error";
NSString *WEIBO_UNKNOW_ERROR = @"Weibo unknow error";
NSString *WEIBO_USER_CANCEL_INSTALL = @"user cancel install weibo";



@interface ShareManager ()
@property(nonatomic, strong)  BDSquareMoreView *shareView;

@end
@implementation ShareManager

- (void)coolMethod:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* echo = [command.arguments objectAtIndex:0];
    
    if (echo != nil && [echo length] > 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}




- (void)shareAction:(CDVInvokedUrlCommand*)command{
    
    self.currentCallbackId = command.callbackId;
    
    self.shareView = nil;
    self.shareView = [[BDSquareMoreView alloc]init];
    
    NSArray *itemAry = [NSArray arrayWithArray:(NSArray *)[command.arguments objectAtIndex:0]];
    
    [self.shareView showWith:itemAry];
    __weak ShareManager *weakSelf = self;
    self.shareView.shareClickBlock = ^(NSInteger idx){
        // 分享对应的操作行为
        
        if (idx == 0) {
            [weakSelf share:command With:0];
        }else if (idx == 1){
            [weakSelf share:command With:1];
        }else if (idx == 2){
            [weakSelf shareToQzone:command];
        }else if (idx == 3){
            [weakSelf shareToQQ:command];
        }else if (idx == 4){
            [weakSelf shareToWeibo:command];
        }
    };
}






#pragma mark "API"
- (void)pluginInitialize {
    
    // 微信注册
    self.wechatAppId = [[self.commandDelegate settings] objectForKey:@"wechatappid"];
    [WXApi registerApp: self.wechatAppId];
    
    // QQ注册
    appId = [[self.commandDelegate settings] objectForKey:@"qq_app_id"];
    if (nil == self.tencentOAuth) {
        self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:appId andDelegate:self];
    }
    
    // 微博注册
    NSString *weiboAppId = [[self.commandDelegate settings] objectForKey:WEBIO_APP_ID];
    self.weiboAppId = weiboAppId;
    [WeiboSDK registerApp:weiboAppId];
    
    UInt64 typeFlag = MMAPP_SUPPORT_TEXT | MMAPP_SUPPORT_PICTURE | MMAPP_SUPPORT_LOCATION | MMAPP_SUPPORT_VIDEO |MMAPP_SUPPORT_AUDIO | MMAPP_SUPPORT_WEBPAGE | MMAPP_SUPPORT_DOC | MMAPP_SUPPORT_DOCX | MMAPP_SUPPORT_PPT | MMAPP_SUPPORT_PPTX | MMAPP_SUPPORT_XLS | MMAPP_SUPPORT_XLSX | MMAPP_SUPPORT_PDF;
    [WXApi registerAppSupportContentFlag:typeFlag];
    NSString *redirectURI = [[self.commandDelegate settings] objectForKey:WEBIO_REDIRECT_URI];
    if (nil == redirectURI) {
        self.redirectURI = WEBIO_DEFUALT_REDIRECT_URI;
    } else {
        self.redirectURI = redirectURI;
    }
    
}

- (void)isWXAppInstalled:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[WXApi isWXAppInstalled]];
    
    [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
}

- (void)share:(CDVInvokedUrlCommand *)command With:(int)scene
{
    // if not installed
    if (![WXApi isWXAppInstalled])
    {
        [self failWithCallbackID:command.callbackId withMessage:@"未安装微信"];
        return ;
    }
    
    // check arguments
    NSDictionary *params = [command.arguments objectAtIndex:1];
    if (!params)
    {
        [self failWithCallbackID:command.callbackId withMessage:@"参数格式错误"];
        return ;
    }
    
    // save the callback id
    //    self.currentCallbackId = command.callbackId;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.scene = scene;
    
    // message or text?
//    NSDictionary *message = [params objectForKey:@"title"];
    
    if (params)
    {
        req.bText = NO;
        
        // async
        [self.commandDelegate runInBackground:^{
            req.message = [self buildSharingMessage:params];
            
            if (![WXApi sendReq:req])
            {
                [self failWithCallbackID:command.callbackId withMessage:@"发送请求失败"];
                self.currentCallbackId = nil;
            }
        }];
    }
    else
    {
        req.bText = YES;
        req.text = [params objectForKey:@"text"];
        
        if (![WXApi sendReq:req])
        {
            [self failWithCallbackID:command.callbackId withMessage:@"发送请求失败"];
            self.currentCallbackId = nil;
        }
    }
}


- (void)sendAuthRequest:(CDVInvokedUrlCommand *)command
{
    
    SendAuthReq* req =[[SendAuthReq alloc] init];
    
    // scope
    if ([command.arguments count] > 0)
    {
        req.scope = [command.arguments objectAtIndex:0];
    }
    else
    {
        req.scope = @"snsapi_userinfo";
    }
    
    // state
    if ([command.arguments count] > 1)
    {
        req.state = [command.arguments objectAtIndex:1];
    }
    
    if ([WXApi sendAuthReq:req viewController:self.viewController delegate:self])
    {
        // save the callback id
        //        self.currentCallbackId = command.callbackId;
    }
    else
    {
        [self failWithCallbackID:command.callbackId withMessage:@"发送请求失败"];
    }
}

- (void)sendPaymentRequest:(CDVInvokedUrlCommand *)command
{
    // check arguments
    NSDictionary *params = [command.arguments objectAtIndex:0];
    if (!params)
    {
        [self failWithCallbackID:command.callbackId withMessage:@"参数格式错误"];
        return ;
    }
    
    // check required parameters
    NSArray *requiredParams;
    if ([params objectForKey:@"mch_id"])
    {
        requiredParams = @[@"mch_id", @"prepay_id", @"timestamp", @"nonce", @"sign"];
    }
    else
    {
        requiredParams = @[@"partnerid", @"prepayid", @"timestamp", @"noncestr", @"sign"];
    }
    
    for (NSString *key in requiredParams)
    {
        if (![params objectForKey:key])
        {
            [self failWithCallbackID:command.callbackId withMessage:@"参数格式错误"];
            return ;
        }
    }
    
    PayReq *req = [[PayReq alloc] init];
    req.partnerId = [params objectForKey:requiredParams[0]];
    req.prepayId = [params objectForKey:requiredParams[1]];
    req.timeStamp = [[params objectForKey:requiredParams[2]] intValue];
    req.nonceStr = [params objectForKey:requiredParams[3]];
    req.package = @"Sign=WXPay";
    req.sign = [params objectForKey:requiredParams[4]];
    
    if ([WXApi sendReq:req])
    {
        // save the callback id
        //        self.currentCallbackId = command.callbackId;
    }
    else
    {
        [self failWithCallbackID:command.callbackId withMessage:@"发送请求失败"];
    }
}

- (void)jumpToBizProfile:(CDVInvokedUrlCommand *)command
{
    // check arguments
    NSDictionary *params = [command.arguments objectAtIndex:0];
    if (!params)
    {
        [self failWithCallbackID:command.callbackId withMessage:@"参数格式错误"];
        return ;
    }
    
    // check required parameters
    NSArray *requiredParams;
    requiredParams = @[@"type", @"info"];
    
    for (NSString *key in requiredParams)
    {
        if (![params objectForKey:key])
        {
            [self failWithCallbackID:command.callbackId withMessage:@"参数格式错误"];
            return ;
        }
    }
    JumpToBizProfileReq *req = [JumpToBizProfileReq new];
    NSString *bizType =  [params objectForKey:requiredParams[0]];
    
    if ([bizType isEqualToString:@"Normal"]) {
        req.profileType = WXBizProfileType_Normal;
        req.username = [params objectForKey:requiredParams[1]];
    } else {
        req.profileType = WXBizProfileType_Device;
        req.extMsg = [params objectForKey:requiredParams[1]];
    }
    
    if ([WXApi sendReq:req])
    {
        // save the callback id
        //        self.currentCallbackId = command.callbackId;
    }
    else
    {
        [self failWithCallbackID:command.callbackId withMessage:@"发送请求失败"];
    }
}

- (void)jumpToWechat:(CDVInvokedUrlCommand *)command
{
    // check arguments
    NSString *url = [command.arguments objectAtIndex:0];
    if (!url || ![url hasPrefix:@"weixin://"])
    {
        [self failWithCallbackID:command.callbackId withMessage:@"参数格式错误"];
        return ;
    }
    
    NSURL *formatUrl = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if ([[UIApplication sharedApplication] canOpenURL:formatUrl]) {
        [[UIApplication sharedApplication] openURL:formatUrl];
    } else{
        [self failWithCallbackID:command.callbackId withMessage:@"未安装微信或其他错误"];
    }
    return ;
}



#pragma mark "WXApiDelegate"

/**
 * Not implemented
 */
- (void)onReq:(BaseReq *)req
{
    NSLog(@"%@", req);
}

- (void)onResp:(BaseResp *)resp
{
    
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        // 微信登陆的返回信息
        SendAuthResp *sendAuthResp = (SendAuthResp *)resp;
        
    }else if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
        // QQ分享
        SendMessageToQQResp * tmpResp = (SendMessageToQQResp *)resp;
        switch ([tmpResp.result integerValue]) {
            case 0: {
                
                 [self.shareView showTips:@"分享成功"];
                break;
            }
            case -4: {
//                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:QQ_SHARE_CANCEL];
//                [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callback];
                [self.shareView showTips:@"取消分享"];
                break;
            }
            default:{
//                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"分享失败"];
//                [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callback];
                [self.shareView showTips:@"分享失败"];
                break;
            }
        }
    }else if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        
        // 微信分享
        BOOL success = NO;
        NSString *message = @"Unknown";
        NSDictionary *response = nil;
        
        switch (resp.errCode)
        {
            case WXSuccess:
                success = YES;
                [self.shareView showTips:@"分享成功"];
                break;
                
            case WXErrCodeCommon:
                message = @"普通错误";
                break;
                
            case WXErrCodeUserCancel:
                [self.shareView showTips:@"取消分享"];
                message = @"用户点击取消并返回";
                break;
                
            case WXErrCodeSentFail:
                [self.shareView showTips:@"分享失败"];
                message = @"发送失败";
                break;
                
            case WXErrCodeAuthDeny:
                message = @"授权失败";
                break;
                
            case WXErrCodeUnsupport:
                message = @"微信不支持";
                break;
                
            default:
                message = @"未知错误";
        }
        
//        if (success)
//        {
//            if ([resp isKindOfClass:[SendAuthResp class]])
//            {
//                // fix issue that lang and country could be nil for iPhone 6 which caused crash.
//                SendAuthResp* authResp = (SendAuthResp*)resp;
//                response = @{
//                             @"code": authResp.code != nil ? authResp.code : @"",
//                             @"state": authResp.state != nil ? authResp.state : @"",
//                             @"lang": authResp.lang != nil ? authResp.lang : @"",
//                             @"country": authResp.country != nil ? authResp.country : @"",
//                             };
//                
//                CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:response];
//                
//                [self.commandDelegate sendPluginResult:commandResult callbackId:self.currentCallbackId];
//            }
//            else
//            {
//                [self successWithCallbackID:self.currentCallbackId withMessage:message];
//            }
//        }
//        else
//        {
//            [self failWithCallbackID:self.currentCallbackId withMessage:message];
//        }
        
    }else if ([resp isKindOfClass:[PayResp class]]) {
        // 微信支付回调
        //支付返回结果，实际支付结果需要去微信服务器端查询
        NSString *strMsg;
        switch (resp.errCode) {
            case WXSuccess:
//                strMsg = @"支付结果：成功！";
                [self.shareView showTips:@"支付成功"];
                break;
                
            default:
//                strMsg = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr];
                [self.shareView showTips:@"支付失败"];
                break;
        }
    }
    
}

#pragma mark "CDVPlugin Overrides"

- (void)handleOpenURL:(NSNotification *)notification
{
    NSURL* url = [notification object];
    
    if ([url isKindOfClass:[NSURL class]] && [url.scheme isEqualToString:self.wechatAppId])
    {
        [WXApi handleOpenURL:url delegate:self];
    }
    
    NSString *schemaPrefix = [@"tencent" stringByAppendingString:appId];
    if ([url isKindOfClass:[NSURL class]] && [[url absoluteString] hasPrefix:[schemaPrefix stringByAppendingString:@"://response_from_qq"]]) {
        [QQApiInterface handleOpenURL:url delegate:self];
    } else {
        [TencentOAuth HandleOpenURL:url];
    }
    
    
    NSString *wb = @"wb";
    if ([url isKindOfClass:[NSURL class]] && [url.absoluteString hasPrefix:[wb stringByAppendingString:self.weiboAppId]]) {
        [WeiboSDK handleOpenURL:url delegate:self];
    }
}

#pragma mark "Private methods"

- (WXMediaMessage *)buildSharingMessage:(NSDictionary *)message
{
    WXMediaMessage *wxMediaMessage = [WXMediaMessage message];
    wxMediaMessage.title = [message objectForKey:@"title"];
    wxMediaMessage.description = [message objectForKey:@"description"];
    //    wxMediaMessage.mediaTagName = [message objectForKey:@"mediaTagName"];
    //    wxMediaMessage.messageExt = [message objectForKey:@"messageExt"];
    //    wxMediaMessage.messageAction = [message objectForKey:@"messageAction"];
    if ([message objectForKey:@"imageUrl"])
    {
        [wxMediaMessage setThumbImage:[self getUIImageFromURL:[message objectForKey:@"imageUrl"]]];
    }
    
    // media parameters
    id mediaObject = nil;
    mediaObject = [WXWebpageObject object];
    ((WXWebpageObject *)mediaObject).webpageUrl = [message objectForKey:@"url"];

    
    wxMediaMessage.mediaObject = mediaObject;
    return wxMediaMessage;
}

- (NSData *)getNSDataFromURL:(NSString *)url
{
    NSData *data = nil;
    
    if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"])
    {
        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    }
    else if ([url hasPrefix:@"data:image"])
    {
        // a base 64 string
        NSURL *base64URL = [NSURL URLWithString:url];
        data = [NSData dataWithContentsOfURL:base64URL];
    }
    else if ([url rangeOfString:@"temp:"].length != 0)
    {
        url =  [NSTemporaryDirectory() stringByAppendingPathComponent:[url componentsSeparatedByString:@"temp:"][1]];
        data = [NSData dataWithContentsOfFile:url];
    }
    else
    {
        // local file
        url = [[NSBundle mainBundle] pathForResource:[url stringByDeletingPathExtension] ofType:[url pathExtension]];
        data = [NSData dataWithContentsOfFile:url];
    }
    
    return data;
}

- (UIImage *)getUIImageFromURL:(NSString *)url
{
    NSData *data = [self getNSDataFromURL:url];
    UIImage *image = [UIImage imageWithData:data];
    
    if (image.size.width > MAX_THUMBNAIL_SIZE || image.size.height > MAX_THUMBNAIL_SIZE)
    {
        CGFloat width = 0;
        CGFloat height = 0;
        
        // calculate size
        if (image.size.width > image.size.height)
        {
            width = MAX_THUMBNAIL_SIZE;
            height = width * image.size.height / image.size.width;
        }
        else
        {
            height = MAX_THUMBNAIL_SIZE;
            width = height * image.size.width / image.size.height;
        }
        
        // scale it
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        [image drawInRect:CGRectMake(0, 0, width, height)];
        UIImage *scaled = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return scaled;
    }
    
    return image;
}

- (void)successWithCallbackID:(NSString *)callbackID
{
    [self successWithCallbackID:callbackID withMessage:@"OK"];
}

- (void)successWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

- (void)failWithCallbackID:(NSString *)callbackID withError:(NSError *)error
{
    [self failWithCallbackID:callbackID withMessage:[error localizedDescription]];
}

- (void)failWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}




/**
 *  QQ单点登录
 *
 *  @param command CDVInvokedUrlCommand
 */
- (void)ssoLogin:(CDVInvokedUrlCommand *)command {
    
    NSString *checkQQInstalled = [command.arguments objectAtIndex:0];
    if (([checkQQInstalled integerValue] == 1)) {
        if ([TencentOAuth iphoneQQInstalled]) {
            [self qqLogin:command];
        }
        else {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:QQ_NOT_INSTALLED];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }else {
        [self qqLogin:command];
    }
    
    
    // 微博的断点登录
    
    self.callback = command.callbackId;
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = self.redirectURI;
    request.scope = @"all";
    request.userInfo = @{@"SSO_From" : @"YCWeibo",
                         @"Other_Info_1" : [NSNumber numberWithInt:123],
                         @"Other_Info_2" : @[@"obj1", @"obj2"],
                         @"Other_Info_3" : @{@"key1" : @"obj1", @"key2" : @"obj2"}};
    [WeiboSDK sendRequest:request];
}

/**
 *  QQ 登出
 *
 *  @param command CDVInvokedUrlCommand
 */
- (void)logout:(CDVInvokedUrlCommand *)command {
    if (self.tencentOAuth.isSessionValid) {
        [self.tencentOAuth logout:self];
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    
    // 微博的登出
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [saveDefaults objectForKey:@"access_token"];
    [saveDefaults removeObjectForKey:@"userid"];
    [saveDefaults removeObjectForKey:@"access_token"];
    [saveDefaults removeObjectForKey:@"expires_time"];
    [saveDefaults synchronize];
    if (token) {
        [WeiboSDK logOutWithToken:token delegate:self.appDelegate withTag:nil];
    }
//    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 *  检查QQ官方客户端是否安装
 *
 *  @param command CDVInvokedUrlCommand
 */
- (void)checkClientInstalled:(CDVInvokedUrlCommand *)command {
    if ([TencentOAuth iphoneQQInstalled] && [TencentOAuth iphoneQQSupportSSOLogin]) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else if ([WeiboSDK isWeiboAppInstalled]){
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }else {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
 
//        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
//        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];


}

/**
 *  分享到QQ
 *
 *  @param command CDVInvokedUrlCommand
 */
- (void)shareToQQ:(CDVInvokedUrlCommand *)command {
    self.callback = command.callbackId;
    NSDictionary *args = [command.arguments objectAtIndex:1];
    if (args) {
        QQApiNewsObject *newsObj = [self makeNewsObject:args with:1];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
        [QQApiInterface sendReq:req];
    }
    else {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:QQ_PARAM_NOT_FOUND];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

/**
 *  分享到QQ空间
 *
 *  @param command CDVInvokedUrlCommand
 */
- (void)shareToQzone:(CDVInvokedUrlCommand *)command {
    self.callback = command.callbackId;
    NSDictionary *args = [command.arguments objectAtIndex:1];
    if (args) {
        QQApiNewsObject *newsObj = [self makeNewsObject:args with:2];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
        [QQApiInterface SendReqToQZone:req];
    }
    else {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:QQ_PARAM_NOT_FOUND];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

/**
 *  添加到收藏
 *
 *  @param command CDVInvokedUrlCommand
 */
- (void)addToQQFavorites:(CDVInvokedUrlCommand *)command {
    self.callback = command.callbackId;
    NSDictionary *args = [command.arguments objectAtIndex:0];
    if (args) {
        QQApiNewsObject *newsObj = [self makeNewsObject:args with:1];
        [newsObj setCflag:kQQAPICtrlFlagQQShareFavorites];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
        [QQApiInterface sendReq:req];
    }
    else {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:QQ_PARAM_NOT_FOUND];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

/**
 *  创建要分享的新闻类
 *
 *  @param args      新闻类所需要的参数
 *  @param shareType 分享的类型
 *
 *  @return QQApiNewsObject
 */
- (QQApiNewsObject *)makeNewsObject:(NSDictionary *)args with:(int)shareType {
    if (!args) {
        return nil;
    }
    NSString *url = [args objectForKey:@"url"];
    NSString *previewImageUrl;
    NSData *previewImageData;
    if (shareType == 1) {
        previewImageUrl = [args objectForKey:@"imageUrl"];
        if (NSNotFound == [previewImageUrl rangeOfString:@"http://" options:NSCaseInsensitiveSearch].location &&
            NSNotFound == [previewImageUrl rangeOfString:@"https://" options:NSCaseInsensitiveSearch].location) {
            previewImageData = [NSData dataWithContentsOfFile:previewImageUrl];
            previewImageUrl = nil;
        }
    }
    else if (shareType == 2) {
        previewImageUrl = [args objectForKey:@"imageUrl"];
        if (NSNotFound == [previewImageUrl rangeOfString:@"http://" options:NSCaseInsensitiveSearch].location &&
            NSNotFound == [previewImageUrl rangeOfString:@"https://" options:NSCaseInsensitiveSearch].location) {
            previewImageData = [NSData dataWithContentsOfFile:previewImageUrl];
            previewImageUrl = nil;
        }
    }
    
    QQApiNewsObject *newsObj;
    NSString *title = [args objectForKey:@"title"];
    NSString *description = [args objectForKey:@"description"];
    if (previewImageUrl) {
        newsObj = [QQApiNewsObject
                   objectWithURL:[NSURL URLWithString:url]
                   title:title
                   description:description
                   previewImageURL:[NSURL URLWithString:previewImageUrl]];
    }
    else {
        newsObj = [QQApiNewsObject
                   objectWithURL:[NSURL URLWithString:url]
                   title:[args objectForKey:@"title"]
                   description:[args objectForKey:@"description"]
                   previewImageData:previewImageData];
    }
    
    return newsObj;
}

- (void)isOnlineResponse:(NSDictionary *)response {
    NSLog(@"response is %@",response);
}



#pragma mark - TencentSessionDelegate
- (void)tencentDidLogin {
    if (self.tencentOAuth.accessToken && 0 != [self.tencentOAuth.accessToken length]) {
        NSMutableDictionary *Dic = [NSMutableDictionary dictionaryWithCapacity:2];
        [Dic setObject:self.tencentOAuth.openId forKey:@"userid"];
        [Dic setObject:self.tencentOAuth.accessToken forKey:@"access_token"];
        [Dic setObject:[NSString stringWithFormat:@"%f",[self.tencentOAuth.expirationDate timeIntervalSince1970] * 1000] forKey:@"expires_time"];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:Dic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callback];
    }
    else {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:QQ_LOGIN_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callback];
    }
}

- (void)tencentDidLogout {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callback];
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    if (cancelled) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:QQ_LOGIN_CANCEL];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callback];
    }
}

- (void)tencentDidNotNetWork {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:QQ_LOGIN_NETWORK_ERROR];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callback];
}
/**
 *  QQ 登录
 *
 *  @param command CDVInvokedUrlCommand
 */
- (void)qqLogin:(CDVInvokedUrlCommand *)command {
    self.permissions = [NSArray arrayWithObjects:
                        kOPEN_PERMISSION_GET_USER_INFO,
                        kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                        kOPEN_PERMISSION_ADD_ALBUM,
                        kOPEN_PERMISSION_ADD_ONE_BLOG,
                        kOPEN_PERMISSION_ADD_SHARE,
                        kOPEN_PERMISSION_ADD_TOPIC,
                        kOPEN_PERMISSION_CHECK_PAGE_FANS,
                        kOPEN_PERMISSION_GET_INFO,
                        kOPEN_PERMISSION_GET_OTHER_INFO,
                        kOPEN_PERMISSION_LIST_ALBUM,
                        kOPEN_PERMISSION_UPLOAD_PIC,
                        kOPEN_PERMISSION_GET_VIP_INFO,
                        kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                        nil];
    self.callback = command.callbackId;
    if (self.tencentOAuth.isSessionValid) {
        NSMutableDictionary *Dic = [NSMutableDictionary dictionaryWithCapacity:2];
        [Dic setObject:self.tencentOAuth.openId forKey:@"userid"];
        [Dic setObject:self.tencentOAuth.accessToken forKey:@"access_token"];
        [Dic setObject:[NSString stringWithFormat:@"%f",[self.tencentOAuth.expirationDate timeIntervalSince1970] * 1000] forKey:@"expires_time"];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:Dic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callback];
    }
    else {
        [self.tencentOAuth authorize:self.permissions inSafari:NO];
    }
}



/**
 *  分享到微博
 *
 *  @param command CDVInvokedUrlCommand
 */
- (void)shareToWeibo:(CDVInvokedUrlCommand *)command {
    self.callback = command.callbackId;
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = self.redirectURI;
    authRequest.scope = @"all";
    NSDictionary *params = [command.arguments objectAtIndex:1];
    if (!params) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    } else {
        // if([WeiboSDK isWeiboAppInstalled]){
        WBMessageObject *message = [WBMessageObject message];
        
        WBImageObject *imageObject = [WBImageObject object];
        message.text = [NSString stringWithFormat:@"%@ %@",[params objectForKey:@"description"],[params objectForKey:@"url"]];
        if (([params objectForKey:@"imageUrl"] && ![[params objectForKey:@"imageUrl"] isEqualToString:@""])) {
            if ([[params objectForKey:@"imageUrl"] hasPrefix:@"http://"] || [[params objectForKey:@"imageUrl"] hasPrefix:@"https://"]) {
                imageObject.imageData = [NSData dataWithContentsOfURL:
                                         [NSURL URLWithString:[params  objectForKey:@"imageUrl"]]];
            }
        }
        message.imageObject = imageObject;
        
        
        
        
//        WBWebpageObject *webpageObject = [WBWebpageObject object];
//        webpageObject.webpageUrl = [params objectForKey:@"url"];
//        webpageObject.title = [params objectForKey:@"description"];
//        webpageObject.thumbnailData = [NSData dataWithContentsOfURL:
//                                       [NSURL URLWithString:[params objectForKey:@"imageUrl"]]];
//        webpageObject.objectID = self.weiboAppId;
//        message.mediaObject = webpageObject;
        
        WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:nil access_token:nil];
        
        
        
//        WBMessageObject *message = [WBMessageObject message];
//        message.text = mModel.shareTitle;
//        // 消息的图片内容中，图片数据不能为空并且大小不能超过10M
//        WBImageObject *imageObject = [WBImageObject object];
//        imageObject.imageData = mModel.shareImgData;
//        message.imageObject = imageObject;
//        WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
//        [WeiboSDK sendRequest:request];
        
//        request.userInfo = @{@"ShareMessageFrom" : @"YCWEIBO",
//                             @"Other_Info_1" : [NSNumber numberWithInt:123],
//                             @"Other_Info_2" : @[@"obj1", @"obj2"],
//                             @"Other_Info_3" : @{@"key1" : @"obj1", @"key2" : @"obj2"}};
        [WeiboSDK sendRequest:request];
    }
}


#pragma mark - WeiboSDKDelegate
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class]) {
        if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            [self.shareView showTips:@"分享成功"];
//            WBSendMessageToWeiboResponse *sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse *) response;
//            NSString *accessToken = [sendMessageToWeiboResponse.authResponse accessToken];
//            NSString *userID = [sendMessageToWeiboResponse.authResponse userID];
//            NSString *expirationTime = [NSString stringWithFormat:@"%f",[sendMessageToWeiboResponse.authResponse.expirationDate timeIntervalSince1970] * 1000];
//            if (accessToken && userID && expirationTime) {
//                NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
//                [saveDefaults setValue:accessToken forKey:@"access_token"];
//                [saveDefaults setValue:userID forKey:@"userid"];
//                [saveDefaults setValue:expirationTime forKey:@"expires_time"];
//                [saveDefaults synchronize];
//            }
//            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
//            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callback];
        } else if (response.statusCode == WeiboSDKResponseStatusCodeUserCancel) {
            [self.shareView showTips:@"取消分享"];
//            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:WEIBO_CANCEL_BY_USER];
//            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callback];
        } else if (response.statusCode == WeiboSDKResponseStatusCodeSentFail) {
            [self.shareView showTips:@"分享失败"];
//            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:WEIBO_SEND_FAIL];
//            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callback];
        } else if (response.statusCode == WeiboSDKResponseStatusCodeShareInSDKFailed) {
             [self.shareView showTips:@"分享失败"];
//            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:WEIBO_SHARE_INSDK_FAIL];
//            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callback];
        } else if (response.statusCode == WeiboSDKResponseStatusCodeUnsupport) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:WEIBO_UNSPPORTTED];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callback];
        } else if (response.statusCode == WeiboSDKResponseStatusCodeUnknown) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:WEIBO_UNKNOW_ERROR];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callback];
        } else if (response.statusCode == WeiboSDKResponseStatusCodeAuthDeny) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:WEIBO_AUTH_ERROR];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callback];
        } else if (response.statusCode == WeiboSDKResponseStatusCodeUserCancelInstall) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:WEIBO_USER_CANCEL_INSTALL];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callback];
        }
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            NSMutableDictionary *Dic = [NSMutableDictionary dictionaryWithCapacity:2];
            [Dic setObject:[(WBAuthorizeResponse *) response userID] forKey:@"userid"];
            [Dic setObject:[(WBAuthorizeResponse *) response accessToken] forKey:@"access_token"];
            [Dic setObject:[NSString stringWithFormat:@"%f",[(WBAuthorizeResponse *) response expirationDate].timeIntervalSince1970 * 1000] forKey:@"expires_time"];
            
            NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
            [saveDefaults setValue:[(WBAuthorizeResponse *) response userID] forKey:@"userid"];
            [saveDefaults setValue:[(WBAuthorizeResponse *) response accessToken] forKey:@"access_token"];
            [saveDefaults setValue:[NSString stringWithFormat:@"%f",[(WBAuthorizeResponse *) response expirationDate].timeIntervalSince1970 * 1000] forKey:@"expires_time"];
            [saveDefaults synchronize];
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:Dic];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callback];
        } else if (response.statusCode == WeiboSDKResponseStatusCodeUserCancel) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:WEIBO_CANCEL_BY_USER];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callback];
        } else if (response.statusCode == WeiboSDKResponseStatusCodeSentFail) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:WEIBO_SEND_FAIL];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callback];
        } else if (response.statusCode == WeiboSDKResponseStatusCodeShareInSDKFailed) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:WEIBO_SHARE_INSDK_FAIL];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callback];
        } else if (response.statusCode == WeiboSDKResponseStatusCodeUnsupport) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:WEIBO_UNSPPORTTED];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callback];
        } else if (response.statusCode == WeiboSDKResponseStatusCodeUnknown) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:WEIBO_UNKNOW_ERROR];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callback];
        } else if (response.statusCode == WeiboSDKResponseStatusCodeAuthDeny) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:WEIBO_AUTH_ERROR];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callback];
        } else if (response.statusCode == WeiboSDKResponseStatusCodeUserCancelInstall) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:WEIBO_USER_CANCEL_INSTALL];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callback];
        }
    }
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    
}

@end
