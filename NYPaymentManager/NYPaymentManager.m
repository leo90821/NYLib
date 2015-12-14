//
//  NYPaymentManager.m
//  NYShare
//
//  Created by 倪瑶 on 15/12/10.
//  Copyright © 2015年 nycode. All rights reserved.
//

#import "NYPaymentManager.h"

@implementation NYPaymentObject


@end

@implementation NYPaymentManager

+ (instancetype)defaultManager {
    static NYPaymentManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)registerPaymentApp {
    [WXApi registerApp:WX_PAY_APP_ID];
    
}


#pragma mark - payment
- (void)payForType:(NYPaymentType)payType paymentObject:(NYPaymentObject *)object completion:(NYPaymentComletion)completion {
    switch (payType) {
        case NYPaymentTypeALiPay: {
            
            break;
        }
        case NYPaymentTypeWeChat: {
            [[NYPaymentManager defaultManager] payForWeChatWithOrderObject:object completion:completion];
            break;
        }
        default:
            break;
    }
}


- (void)payTestForWeChatWithOrderObject:(NYPaymentObject *)object completion:(NYPaymentComletion)completion {
    NSString *centPrice = [NSString stringWithFormat:@"%.f",object.orderPrice.floatValue*100];
    
    [self sendWeChatPrePayRequestWithOrderID:object.orderID orderTitle:object.orderTitle price:centPrice completion:^(NSError *error, id requestObject, id responseObject) {
        if (error != nil) {
//            NSLog(@"Domain:%@\n Description:%@\n request:%@\n", error.domain, error.description, requestObject);
            if (completion != nil) {
                completion(error, requestObject, nil);
            }
        } else {
            
            if (centPrice.floatValue < 0) {
                NSError *error = [NSError errorWithDomain:PAYMENT_ERROR_DOMAIN_WX_PRICE code:NYPaymentErrorCodeWeChatPriceLow userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"价格为负数！"]}];
                if (completion != nil) {
                    completion(error, nil, nil);
                }
            } else {
                if (responseObject != nil) {
                    NSString     *time_stamp, *nonce_str;
                    //设置支付参数
                    time_t now;
                    time(&now);
                    time_stamp  = [NSString stringWithFormat:@"%ld", now];
                    nonce_str	= [NYWXPayUtility md5:time_stamp];
                    //支付请求的参数一定要核对清楚
                    PayReq *payRequest             = [[PayReq alloc] init];
                    payRequest.openID              = WX_PAY_APP_ID;
                    payRequest.partnerId           = WX_PAY_PARTNER_ID;
                    payRequest.prepayId            = [responseObject objectForKey:@"prepayid"];//!!!!
                    payRequest.nonceStr            = nonce_str;
                    payRequest.timeStamp           = time_stamp.intValue;
                    payRequest.package             = WX_PAY_PACKAGE;//????
                    
                    //第二次签名参数列表
                    NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
                    [signParams setObject: WX_PAY_APP_ID        forKey:@"appid"];
                    [signParams setObject: nonce_str    forKey:@"noncestr"];
                    [signParams setObject: WX_PAY_PACKAGE      forKey:@"package"];
                    [signParams setObject: WX_PAY_PARTNER_ID        forKey:@"partnerid"];
                    [signParams setObject: time_stamp   forKey:@"timestamp"];
                    [signParams setObject: [responseObject objectForKey:@"prepayid"]     forKey:@"prepayid"];
                    //[signParams setObject: @"MD5"       forKey:@"signType"];
                    //生成签名
                    NSString *sign  = [self createMd5Sign:signParams];
                    payRequest.sign                = sign;//????
                    BOOL status = [WXApi sendReq:payRequest];
                    if (!status) {
                        NSError *error = [NSError errorWithDomain:PAYMENT_ERROR_DOMAIN_WX_REQUEST code:NYPaymentErrorCodeWeChatRequestError userInfo:@{NSLocalizedDescriptionKey:@"支付请求失败！"}];
                        if (completion != nil) {
                            completion(error, nil, nil);
                        }
                    } else {
                        if (completion != nil) {
                            completion(nil, nil, nil);
                        }
                    }

                } else {
                    NSError *error = [NSError errorWithDomain:PAYMENT_ERROR_DOMAIN_WX_RESPONSE code:NYPaymentErrorCodeWeChatResponseError userInfo:@{NSLocalizedDescriptionKey:@"服务器返回对象为空！"}];
                    if (completion != nil) {
                        completion(error, nil, nil);
                    }
                }
            }
            
            
        }
    }];
}

- (void)payForWeChatWithOrderObject:(NYPaymentObject *)object completion:(NYPaymentComletion)completion {
    if (object.wxPrePayID.length == 0) {
        NSError *error  = [NSError errorWithDomain:PAYMENT_ERROR_DOMAIN_WX_PREPAYID code:NYPaymentErrorCodeWeChatGetPrePayIDFailed userInfo:@{NSLocalizedDescriptionKey:@"获取prepayid失败！\n"}];
        if (completion != nil) {
            completion(error, nil, nil);
        }
    } else {
        NSString     *time_stamp, *nonce_str;
        //设置支付参数
        time_t now;
        time(&now);
        time_stamp  = [NSString stringWithFormat:@"%ld", now];
        nonce_str	= [NYWXPayUtility md5:time_stamp];
        //支付请求的参数一定要核对清楚
        PayReq *payRequest             = [[PayReq alloc] init];
        payRequest.openID              = WX_PAY_APP_ID;
        payRequest.partnerId           = WX_PAY_PARTNER_ID;
        payRequest.prepayId            = object.wxPrePayID;//!!!!
        payRequest.nonceStr            = nonce_str;
        payRequest.timeStamp           = time_stamp.intValue;
        payRequest.package             = WX_PAY_PACKAGE;//????
        
        //第二次签名参数列表
        NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
        [signParams setObject: WX_PAY_APP_ID        forKey:@"appid"];
        [signParams setObject: nonce_str    forKey:@"noncestr"];
        [signParams setObject: WX_PAY_PACKAGE      forKey:@"package"];
        [signParams setObject: WX_PAY_PARTNER_ID        forKey:@"partnerid"];
        [signParams setObject: time_stamp   forKey:@"timestamp"];
        [signParams setObject: object.wxPrePayID     forKey:@"prepayid"];
        //[signParams setObject: @"MD5"       forKey:@"signType"];
        //生成签名
        NSString *sign  = [self createMd5Sign:signParams];
        payRequest.sign                = sign;//????
        BOOL status = [WXApi sendReq:payRequest];
        if (!status) {
            NSError *error = [NSError errorWithDomain:PAYMENT_ERROR_DOMAIN_WX_REQUEST code:NYPaymentErrorCodeWeChatRequestError userInfo:@{NSLocalizedDescriptionKey:@"支付请求失败！"}];
            if (completion != nil) {
                completion(error, nil, nil);
            }
        } else {
            if (completion != nil) {
                completion(nil, nil, nil);
            }
        }
    }
}

- (void)sendWeChatPrePayRequestWithOrderID:(NSString *)orderID orderTitle:(NSString *)orderTitle price:(NSString *)price completion:(NYPaymentComletion)completion {
    self.completion = completion;
    NSMutableDictionary *preOrder = [NSMutableDictionary dictionary];
    srand( (unsigned)time(0) );
    NSString *noncestr  = [NSString stringWithFormat:@"%d", rand()];
    
    
    [preOrder setObject: WX_PAY_APP_ID          forKey:@"appid"];       //开放平台appid
    [preOrder setObject: WX_PAY_PARTNER_ID      forKey:@"mch_id"];      //商户号
    [preOrder setObject: WX_PAY_DEVICE_INFO     forKey:@"device_info"]; //支付设备号或门店号
    [preOrder setObject: noncestr               forKey:@"nonce_str"];   //随机串
    [preOrder setObject: @"APP"                 forKey:@"trade_type"];  //支付类型，固定为APP
    [preOrder setObject: orderTitle             forKey:@"body"];        //订单描述，展示给用户
    [preOrder setObject: WX_PAY_NOTIFY_URL      forKey:@"notify_url"];  //支付结果异步通知
    [preOrder setObject: orderID                forKey:@"out_trade_no"];//商户订单号
    [preOrder setObject: WX_PAY_BILL_CREATE_IP  forKey:@"spbill_create_ip"];//发器支付的机器ip
    [preOrder setObject: price                  forKey:@"total_fee"];       //订单金额，单位为分
    
    NSString *prePayID = [self getPrePayIDWithPrePayOrder:preOrder];
    if (prePayID.length != 0) {
        
        NSString    *package, *time_stamp, *nonce_str;
        //设置支付参数
        time_t now;
        time(&now);
        time_stamp  = [NSString stringWithFormat:@"%ld", now];
        nonce_str	= [NYWXPayUtility md5:time_stamp];
        //重新按提交格式组包，微信客户端暂只支持package=Sign=WXPay格式，须考虑升级后支持携带package具体参数的情况
        //package       = [NSString stringWithFormat:@"Sign=%@",package];
        package         = WX_PAY_PACKAGE;
        //第二次签名参数列表
        NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
        [signParams setObject: WX_PAY_APP_ID        forKey:@"appid"];
        [signParams setObject: nonce_str    forKey:@"noncestr"];
        [signParams setObject: package      forKey:@"package"];
        [signParams setObject: WX_PAY_PARTNER_ID        forKey:@"partnerid"];
        [signParams setObject: time_stamp   forKey:@"timestamp"];
        [signParams setObject: prePayID     forKey:@"prepayid"];
        //[signParams setObject: @"MD5"       forKey:@"signType"];
        //生成签名
        NSString *sign  = [self createMd5Sign:signParams];
        
        //添加签名
        [signParams setObject: sign         forKey:@"sign"];
        if (self.completion != nil) {
            self.completion(nil, nil, signParams);
        }
        
    } else {
        NSError *error  = [NSError errorWithDomain:PAYMENT_ERROR_DOMAIN_WX_PREPAYID code:NYPaymentErrorCodeWeChatGetPrePayIDFailed userInfo:@{NSLocalizedDescriptionKey:@"获取prepayid失败！\n"}];
        if (self.completion != nil) {
            self.completion(error, preOrder, nil);
        }
    }
   
}

- (NSString *)getPrePayIDWithPrePayOrder:(NSMutableDictionary *)preOrder {
    NSString *prePayID = nil;
    NSString *packageSign = [self packageSign:preOrder];
    
    NSData *response = [NYWXPayUtility postSynchronousRequestWithURL:WX_PAY_UNIFIEDORDER_API httpBody:packageSign];
    NYXMLParser *xml = [[NYXMLParser alloc] init];
    [xml parseData:response];
    NSMutableDictionary *dictionary = [xml dictionary];
    //判断返回
    NSString *return_code   = [dictionary objectForKey:@"return_code"];
    NSString *return_msg    = [dictionary objectForKey:@"return_msg"];
    NSString *result_code   = [dictionary objectForKey:@"result_code"];
    NSString *err_code = [dictionary objectForKey:@"err_code"];
    NSString *err_code_des = [dictionary objectForKey:@"err_code_des"];
    if ( [return_code isEqualToString:@"SUCCESS"] ) {
        //生成返回数据的签名
        NSString *sign      = [self createMd5Sign:dictionary ];
        NSString *send_sign =[dictionary objectForKey:@"sign"] ;
        
        //验证签名正确性
        if( [sign isEqualToString:send_sign]){
            if( [result_code isEqualToString:@"SUCCESS"]) {
                //验证业务处理状态
                prePayID    = [dictionary objectForKey:@"prepay_id"];
                return_code = 0;
//                if (self.completion != nil) {
//                    self.completion(nil, nil, nil);
//                }
//                [debugInfo appendFormat:@"获取预支付交易标示成功！\n"];
            } else {
                NSError *error = [NSError errorWithDomain:PAYMENT_ERROR_DOMAIN_WX_RESULT_FAIL code:NYPaymentErrorCodeWeChatResultCodeFail userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"获得prepayid失败, %@, %@", err_code, err_code_des]}];
                if (self.completion != nil) {
                    self.completion(error, nil, nil);
                }
            }
        } else {
            NSError *error = [NSError errorWithDomain:PAYMENT_ERROR_DOMAIN_WX_SIGN code:NYPaymentErrorCodeWeChatSignVerifyError userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat: @"服务器返回签名验证错误！！！\n返回信息：%@", return_msg]}];
            if (self.completion != nil) {
                self.completion(error, send_sign, nil);
            }
//            last_errcode = 1;
//            [debugInfo appendFormat:@"gen_sign=%@\n   _sign=%@\n",sign,send_sign];
//            [debugInfo appendFormat:@"服务器返回签名验证错误！！！\n"];
            
        }
    } else {
        NSError *error = [NSError errorWithDomain:PAYMENT_ERROR_DOMAIN_WX_SERVER code:NYPaymentErrorCodeWeChatSignVerifyError userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat: @"请求接口返回错误！！！\n返回信息：%@", return_msg]}];
        if (self.completion != nil) {
            self.completion(error, packageSign, nil);
        }

//        last_errcode = 2;
//        [debugInfo appendFormat:@"接口返回错误！！！\n"];
    }
    return prePayID;
}
//获取package带参数的签名包
- (NSString *)packageSign:(NSMutableDictionary *)packageParams {
    NSString *sign;
    NSMutableString *reqPars = [NSMutableString string];
    //生成签名
    sign        = [self createMd5Sign:packageParams];
    //生成xml的package
    NSArray *keys = [packageParams allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    [reqPars appendString:@"<xml>\n"];
    for (NSString *categoryId in sortedArray) {
        [reqPars appendFormat:@"<%@>%@</%@>\n", categoryId, [packageParams objectForKey:categoryId],categoryId];
    }
    [reqPars appendFormat:@"<sign>%@</sign>\n</xml>", sign];
    
    return [NSString stringWithString:reqPars];
}
/**
 * 具体签名加密方法见 https://pay.weixin.qq.com/wiki/doc/api/app.php?chapter=4_3
 **/
- (NSString *)createMd5Sign:(NSMutableDictionary*)dict {
    NSMutableString *contentString  =[NSMutableString string];
    NSArray *keys = [dict allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    for (NSString *categoryId in sortedArray) {
        if (   ![[dict objectForKey:categoryId] isEqualToString:@""]
            && ![categoryId isEqualToString:@"sign"]
            && ![categoryId isEqualToString:@"key"]
            )
        {
            [contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
        }
        
    }
    //添加key字段
    [contentString appendFormat:@"key=%@", WX_PAY_API_KEY];
    //得到MD5 sign签名
    NSString *md5Sign =[NYWXPayUtility md5:contentString];
    
    return md5Sign;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    BOOL result = NO;
    if ([url.scheme isEqualToString:[NSString stringWithFormat:@"%@", WX_PAY_APP_ID]]) {
        result = [WXApi handleOpenURL:url delegate:self];
    }
    return result;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL result = NO;
    if ([url.scheme isEqualToString:[NSString stringWithFormat:@"%@", WX_PAY_APP_ID]]) {
        result = [WXApi handleOpenURL:url delegate:self];
    }
    return result;
}

#pragma mark - wechat delegate

- (void)onReq:(BaseReq *)req {
    
}

- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *paymentResponse = (PayResp *)resp;
        switch (paymentResponse.errCode) {
            case 0: {
                
                break;
            }
            case -1: {
                NSError *error = [NSError errorWithDomain:PAYMENT_ERROR_DOMAIN_WX_PAYFAILED code:NYPaymentErrorCodeWeChatPayFailed userInfo:@{NSLocalizedDescriptionKey:@"支付失败，可能的原因：签名错误、未注册APPID、项目设置APPID不正确、注册的APPID与设置的不匹配、其他异常等"}];
                if (self.completion != nil) {
                    self.completion(error, nil, nil);
                }
                break;
            }
            case -2: {
                NSError *error = [NSError errorWithDomain:PAYMENT_ERROR_DOMAIN_WX_PAYCANCELED code:NYPaymentErrorCodeWeChatPayCanceled userInfo:@{NSLocalizedDescriptionKey:@"用户取消支付"}];
                if (self.completion != nil) {
                    self.completion(error, nil, nil);
                }
                break;
            }
            default:
                break;
        }
    }
}


@end
