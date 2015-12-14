//
//  NYShareObject.h
//  hetoumao
//
//  Created by 倪瑶 on 15/12/8.
//  Copyright © 2015年 Qlulu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import <TencentOpenAPI/TencentOAuth.h>


#define SHARE_BASE_URL @""
/**
 * 分享对象类型
 **/
typedef NS_ENUM(NSInteger, NYShareObjectType) {
    NYShareObjectTypeProject,/**< 分享HTM项目 */
    NYShareObjectTypeActivity,/**< 分享HTM活动 */
    NYShareObjectTypeInvestor,/**< 分享HTM投资人 */
};
/**
 * 分享的对象
 * @description 分享类型:项目、活动、投资人;
 **/
@interface NYShareObject : NSObject
@property (strong, nonatomic) NSString  *title;         /**< 分享的标题[项目名称｜活动名称｜投资人姓名] */
@property (strong, nonatomic) NSString  *content;       /**< 分享的内容[项目简介｜活动地点－时间｜投资人简介] */
@property (strong, nonatomic) NSString  *shareImageURL; /**< 分享的图片URL */
@property (strong, nonatomic) UIImage   *shareImage;    /**< 分享的图片对象[项目Logo｜活动Logo｜投资人头像] */
@property (strong, nonatomic) NSString  *shareURL;      /**< 分享的网页URL */
@property (assign, nonatomic) NYShareObjectType objectType;/**< 分享内容的类型[项目、活动、投资人] */
@property (strong, nonatomic) NSNumber *shareID; /**< URL的ID */
@property (strong, nonatomic) NSString *location; /**< 活动地点 */
@property (strong, nonatomic) NSString *date; /**< 活动时间 */
- (WBMessageObject *)WeiboMessageObject;/**< 获得微博分享的对象 */
- (WXMediaMessage *)WeChatMessageObject;/**< 获得分享到微信的对象 */
- (QQApiNewsObject *)QQNewsObject; /**< 分享QQ新闻链接 */
@end
