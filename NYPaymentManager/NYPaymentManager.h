//
//  NYPaymentManager.h
//  NYShare
//
//  Created by 倪瑶 on 15/12/10.
//  Copyright © 2015年 nycode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NYXMLParser.h"
#import "NYWXPayUtility.h"
#import "WXApi.h"
//暂时用 创友
#define WX_PAY_APP_ID @""                     /**< 微信开放应用APP ID ！重要：必须是和商户关联的APP ID  */
#define WX_PAY_APP_SECRET @""   /**< 微信开放应用APP SECRET */

#define WX_PAY_API_KEY @""      /**< API密钥*/
#define WX_PAY_PARTNER_ID @""                         /**< 微信支付商户号 */
#define WX_PAY_DEVICE_INFO @""              /**< 支付设备号或门店号 */
#define WX_PAY_BILL_CREATE_IP @"192.168.0.1"                    /**< 发器支付的机器ip */
#define WX_PAY_NOTIFY_URL @""               /**< 回调URL，接收异步通知 */
#define WX_PAY_UNIFIEDORDER_API @"https://api.mch.weixin.qq.com/pay/unifiedorder" /**< 统一订单接口，详见https://pay.weixin.qq.com/wiki/doc/api/app.php?chapter=9_1 */
#define WX_PAY_PACKAGE @"Sign=WXPay"



#define PAYMENT_ERROR_DOMAIN_WX_PREPAYID    @"PAYMENT_ERROR_DOMAIN_WX_PREPAYID"     //获取prepayid失败
#define PAYMENT_ERROR_DOMAIN_WX_SIGN        @"PAYMENT_ERROR_DOMAIN_WX_SIGN"         //服务器返回签名验证错误
#define PAYMENT_ERROR_DOMAIN_WX_SERVER      @"PAYMENT_ERROR_DOMAIN_WX_SERVER"       //请求接口返回错误
#define PAYMENT_ERROR_DOMAIN_WX_PRICE      @"PAYMENT_ERROR_DOMAIN_WX_PRICE"         //价格为负数
#define PAYMENT_ERROR_DOMAIN_WX_RESPONSE      @"PAYMENT_ERROR_DOMAIN_WX_RESPONSE"   //服务器返回对象为空
#define PAYMENT_ERROR_DOMAIN_WX_REQUEST      @"PAYMENT_ERROR_DOMAIN_WX_REQUEST"     //支付请求失败
#define PAYMENT_ERROR_DOMAIN_WX_RESULT_FAIL      @"PAYMENT_ERROR_DOMAIN_WX_RESULT_FAIL"//返回失败
#define PAYMENT_ERROR_DOMAIN_WX_PAYFAILED      @"PAYMENT_ERROR_DOMAIN_WX_PAYFAILED"//可能的原因：签名错误、未注册APPID、项目设置APPID不正确、注册的APPID与设置的不匹配、其他异常等
#define PAYMENT_ERROR_DOMAIN_WX_PAYCANCELED @"PAYMENT_ERROR_DOMAIN_WX_PAYCANCELED"
/**
 * 支付错误码类型
 **/
typedef NS_ENUM(NSInteger, NYPaymentErrorCode) {
    NYPaymentErrorCodeWeChatSignVerifyError,
    NYPaymentErrorCodeWeChatApiResponseError,
    NYPaymentErrorCodeWeChatGetPrePayIDFailed,
    NYPaymentErrorCodeWeChatPriceLow,
    NYPaymentErrorCodeWeChatResponseError,
    NYPaymentErrorCodeWeChatRequestError,
    NYPaymentErrorCodeWeChatResultCodeFail,
    NYPaymentErrorCodeWeChatPayFailed,
    NYPaymentErrorCodeWeChatPayCanceled,
    NYPaymentErrorCodeWeChatPaySuccess,//暂不用，最好后台请求获取，以服务器饭或为准
    NYPaymentErrorCodeALiPay,
};

/**
 * 支付类型
 **/
typedef NS_ENUM(NSInteger, NYPaymentType) {
    NYPaymentTypeWeChat,
    NYPaymentTypeALiPay,
};

/**
 * 回调
 * @param error             支付请求返回的错误
 * @param requestObject     支付请求发送的对象
 * @param responseObject    支付相应返回的对象
 **/
typedef void(^NYPaymentComletion)(NSError *error, id requestObject, id responseObject);

/**
 * 支付订单对象
 **/
@interface NYPaymentObject : NSObject
@property (strong, nonatomic) NSString *orderID;    /**< 商户订单ID，商户后台提供 */
@property (strong, nonatomic) NSString *orderTitle; /**< 商户订单标题，商户后台提供 */
@property (strong, nonatomic) NSString *orderPrice; /**< 订单价格，单位为元 */
@property (strong, nonatomic) NSString *wxPrePayID; /**< 微信预支付订单号,微信支付时必填！ */
@end
/**
 * 支付通用类
 **/
@interface NYPaymentManager : NSObject <WXApiDelegate>
@property (strong, nonatomic) NYPaymentComletion completion; /**< 回调 */

/**
 * 单例 
 **/
+ (instancetype)defaultManager;
- (void)registerPaymentApp;
/**
 * 微信移动端独立发送统一订单请求方法
 * @param orderID       商户订单ID，商户后台提供
 * @param orderTitle    商户订单标题，商户后台提供
 * @param price         订单价格，单位为分
 * @param completion    业务回调
 * @brief 该方法用于没有后台请求统一下单接口的情况
 * @description 仅供测试用
 **/
//- (void)sendWeChatPrePayRequestWithOrderID:(NSString *)orderID orderTitle:(NSString *)orderTitle price:(NSString *)price completion:(NYPaymentComletion)completion;
/**
 * 微信支付方法
 * @param object 支付的订单对象
 * @param completion 支付的回调方法
 **/
- (void)payForWeChatWithOrderObject:(NYPaymentObject *)object completion:(NYPaymentComletion)completion;
/**
 * 支付统一方法
 * @param payType 支付类型，阿里支付、微信支付
 * @param object 支付订单对象
 * @param completion 回调函数
 **/
- (void)payForType:(NYPaymentType)payType paymentObject:(NYPaymentObject *)object completion:(NYPaymentComletion)completion;
/**
 * 分享打开三方应用代理回调方法
 **/
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
/**
 * 分享打开三方应用代理回调方法
 **/
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
@end
