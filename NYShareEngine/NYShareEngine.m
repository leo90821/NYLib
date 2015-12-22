//
//  NYShareEngine.m
//  NYShare
//
//  Created by 倪瑶 on 15/12/9.
//  Copyright © 2015年 nycode. All rights reserved.
//

#import "NYShareEngine.h"
@interface NYShareEngine ()

@property (assign, nonatomic) NYShareType shareType;/**< 分享平台类型 */
@property (strong, nonatomic) NYShareComletion completion;/**< 回调 */
@property (strong, nonatomic) NYShareObject *shareObject;/**< 分享的对象 */

@end

@implementation NYShareEngine
+ (instancetype)sharedEngine {
    static NYShareEngine *share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[self alloc] init];
    });
    return share;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)registerApp {
    [WeiboSDK registerApp:WB_APP_KEY];
    [WeiboSDK enableDebugMode:NO];
    [WXApi registerApp:WX_APP_ID];
    [[TencentOAuth alloc] initWithAppId:QQ_APP_ID andDelegate:self];

}

#pragma mark - share

- (void)shareWithShareType:(NYShareType)shareType object:(NYShareObject *)object completion:(NYShareComletion)completion {
    self.completion = completion;
    self.shareType = shareType;
    self.shareObject = object;
    [self shareRequest:shareType];
}

- (void)shareRequest:(NYShareType)shareType {
    self.isAppDelegate = YES;
    BOOL status = NO;
    switch (shareType) {
        case NYShareTypeQQ: {
            SendMessageToQQReq *request = [SendMessageToQQReq reqWithContent:[self.shareObject QQNewsObject]];
            status = [QQApiInterface sendReq:request];
            break;
        }
        case NYShareTypeWeChatSession:
        case NYShareTypeWeChatMomemts: {
            
            SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = [self.shareObject WeChatMessageObject];
            req.scene = (self.shareType == NYShareTypeWeChatSession)?WXSceneSession:WXSceneTimeline;
            status = [WXApi sendReq:req];
            
            break;
        }
        case NYShareTypeWeibo: {
            WBAuthorizeRequest *request = [[WBAuthorizeRequest alloc] init];
            request.redirectURI = WB_REDIRECT_URL;
            request.scope = @"all";
            WBSendMessageToWeiboRequest *sendMsg = [WBSendMessageToWeiboRequest requestWithMessage:[self.shareObject WeiboMessageObject] authInfo:request access_token:self.WeiboToken];
            status = [WeiboSDK sendRequest:sendMsg];
            break;
        }
        default:
            break;
    }
}



#pragma mark - login / authorize

#pragma mark - weibo delegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    if ([response isKindOfClass:[WBAuthorizeResponse class]]) {
        //获得授权响应
        WBAuthorizeResponse *autorize = (WBAuthorizeResponse *)response;
        self.WeiboToken = autorize.accessToken;
        if (self.WeiboToken.length != 0) {
            //获得认证口令
            if (self.completion != nil) {
                self.completion(nil, nil);
            }
        } else {
            NSError *fail = [NSError errorWithDomain:ERROR_DOMAIN_SHARE_WEIBO code:NYErrorCodeShareWeibo userInfo:@{NSLocalizedDescriptionKey: @"获得授权失败！"}];
            if (self.completion != nil) {
                self.completion(fail, nil);
            }
        }
    } else if ([response isKindOfClass:[WBSendMessageToWeiboResponse class]]) {
        switch (response.statusCode) {
            case WeiboSDKResponseStatusCodeSuccess:
                self.completion(nil, @(WeiboSDKResponseStatusCodeSuccess));
                break;
                
            default:
                break;
        }
    }
    self.isAppDelegate = NO;
}

#pragma mark - wechat delegate / QQ

//- (void)onReq:(BaseReq *)req {
//    
//}
//
//- (void)onResp:(BaseResp *)resp {
//    
//}

- (void)onReq:(id)req {
    
}

- (void)onResp:(id)resp {
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        NSInteger code = ((SendMessageToWXResp *)resp).errCode;
        switch (code) {
            case 0: {
                self.completion(nil, @(code));
                break;
            }
            default:
                break;
        }
    } else if ([resp isKindOfClass:[QQBaseResp class]]) {
        NSInteger type = ((QQBaseResp *)resp).type;
        switch (type) {
            case ESENDMESSAGETOQQRESPTYPE:
                self.completion(nil, nil);
                break;
                
            default:
                break;
        }
    }
    
    self.isAppDelegate = NO;

}


- (void)isOnlineResponse:(NSDictionary *)response {
    
}

#pragma mark - application delegate 

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    BOOL result = NO;
    if ([url.scheme isEqualToString:[NSString stringWithFormat:@"wb%@", WB_APP_KEY]]) {
        //微博
        result = [WeiboSDK handleOpenURL:url delegate:self];
    } else if ([url.scheme isEqualToString:[NSString stringWithFormat:@"%@", WX_APP_ID]]) {
        result = [WXApi handleOpenURL:url delegate:self];
    } else if ([url.scheme isEqualToString:[NSString stringWithFormat:@"tencent%@", QQ_APP_ID]]) {
        result = [TencentOAuth HandleOpenURL:url];
    }
    return result;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL result = NO;
    if ([url.scheme isEqualToString:[NSString stringWithFormat:@"wb%@", WB_APP_KEY]]) {
        //微博
        result = [WeiboSDK handleOpenURL:url delegate:self];
    } else if ([url.scheme isEqualToString:[NSString stringWithFormat:@"%@", WX_APP_ID]]) {
        result = [WXApi handleOpenURL:url delegate:self];
    } else if ([url.scheme isEqualToString:[NSString stringWithFormat:@"tencent%@", QQ_APP_ID]]) {
        result = [TencentOAuth HandleOpenURL:url];
    }
    return result;
}

@end
