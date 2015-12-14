//
//  NYShareEngine.h
//  NYShare
//
//  Created by 倪瑶 on 15/12/9.
//  Copyright © 2015年 nycode. All rights reserved.
//


#import "NYShareObject.h"

/**
 * 分享类型：微信、朋友圈、微博、QQ
 */
typedef NS_ENUM(NSInteger, NYShareType) {
    NYShareTypeQQ,              /**< QQ */
    NYShareTypeWeChatSession,   /**< 微信好友对话 */
    NYShareTypeWeChatMomemts,   /**< 微信朋友圈 */
    NYShareTypeWeibo,           /**< 新浪微博 */
};
/**
 * 错误码类型
 **/
typedef NS_ENUM(NSInteger, NYErrorCode) {
    NYErrorCodeShareWeibo,
    NYErrorCodeShareWeChatMoments,
    NYErrorCodeShareWeChatSession,
};


typedef void(^NYShareComletion)(NSError *error, id response);/**< 回调 */
/**
 * 出错域
 **/
#define ERROR_DOMAIN_SHARE_WEIBO @"WEIBO_SHARE"
#define ERROR_DOMAIN_SHARE_WECHAT_MOMENTS @"WECHAT_MOMENTS"
#define ERROR_DOMAIN_SHARE_WECHAT_SESSION @"WECHAT_SESSION"

//三方平台注册应用

///--- 微信 --- 
#define WX_APP_ID @""
#define WX_APP_SECRET @""

///--- 微博 ---
#define WB_APP_KEY @""
#define WB_APP_SECRET @""
#define WB_REDIRECT_URL @""

//QQ
#define QQ_APP_ID @""
#define QQ_APP_KEY @""

/**
 * 三方分享类
 **/
@interface NYShareEngine : NSObject <WBHttpRequestDelegate, WeiboSDKDelegate, WXApiDelegate>

@property (strong, nonatomic) NSString *WeiboToken; /**< weibo token*/
@property (strong, nonatomic) NSString *WeChatToken;/**< wechat */
@property (strong, nonatomic) NSString *WeChatRefreshToken;/**< wechat */


+ (instancetype)sharedEngine;/**< 单例 */
- (void)registerApp;/**< 注册应用 */
/**
 * 分享统一方法
 * @param shareType 分享类型，包括QQ、微信好友、微信朋友圈、微博 @see NYShareType
 * @param object    分享的图文对象
 * @param completion 回调函数
 **/
- (void)shareWithShareType:(NYShareType)shareType object:(NYShareObject *)object completion:(NYShareComletion)completion;



#pragma mark - delegate
/**
 * 分享打开三方应用代理回调方法
 **/
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
/**
 * 分享打开三方应用代理回调方法
 **/
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

@end
