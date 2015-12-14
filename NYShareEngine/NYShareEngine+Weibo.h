//
//  NYShareEngine+Weibo.h
//  NYShare
//
//  Created by 倪瑶 on 15/12/9.
//  Copyright © 2015年 nycode. All rights reserved.
//

#import "NYShareEngine.h"

@interface NYShareEngine (Weibo)
/**
 * 分享微博
 * @param object 分享的对象 @see NYShareObject
 * @param completion 回调函数 @see NYShareComletion
 **/
- (void)shareWeiboWithObject:(NYShareObject *)object completion:(NYShareComletion)completion;
@end
