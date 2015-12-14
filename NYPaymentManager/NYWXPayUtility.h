//
//  NYWXPayUtility.h
//  NYShare
//
//  Created by 倪瑶 on 15/12/10.
//  Copyright © 2015年 nycode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

/**
 * 微信支付工具
 **/
@interface NYWXPayUtility : NSObject
/** 
 * md5加密 
 **/
+ (NSString *)md5:(NSString *)string;
/** 
 * sha1加密 
 **/
+ (NSString *)sha1:(NSString *)string;
/**
 * 发送同步请求
 * @param url
 * @param data http body
 **/
+ (NSData *)postSynchronousRequestWithURL:(NSString *)url httpBody:(NSString *)data;
@end
