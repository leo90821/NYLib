//
//  NYShareObject.m
//  hetoumao
//
//  Created by 倪瑶 on 15/12/8.
//  Copyright © 2015年 Qlulu. All rights reserved.
//

#import "NYShareObject.h"

@implementation NYShareObject

@synthesize objectType = _objectType;


- (void)setObjectType:(NYShareObjectType)objectType {
    switch (objectType) {
        case NYShareObjectTypeProject: {
            self.title = [NSString stringWithFormat:@"合投猫推荐项目[%@]", _title];
            self.content = [NSString stringWithFormat:@"%@", _content];
            self.shareURL = [NSString stringWithFormat:@"%@/share/proj?id=%@&from=appshare", SHARE_BASE_URL, _shareID];
            self.shareImage = _shareImage;
            
            break;
        }
        case NYShareObjectTypeActivity: {
            self.title = [NSString stringWithFormat:@"合投猫活动[%@]", _title];
            self.content = [NSString stringWithFormat:@"%@ %@", _location, _date];
            self.shareURL = [NSString stringWithFormat:@"%@/act/act_details/?id=%@&from=appshare", SHARE_BASE_URL, _shareID];
            self.shareImage = _shareImage;
            break;
        }
        case NYShareObjectTypeInvestor: {
            self.title = [NSString stringWithFormat:@"合投猫推荐投资人[%@]", _title];
            self.content = [NSString stringWithFormat:@"%@", _content];
            self.shareURL = [NSString stringWithFormat:@"%@/share/invester?id=%@&from=appshare", SHARE_BASE_URL, _shareID];
            self.shareImage = _shareImage;
            break;
        }
        default:
            break;
    }
}

- (WBMessageObject *)WeiboMessageObject {
    //!!!判断为空等情况
    WBImageObject *imageObj = [WBImageObject object];
    imageObj.imageData = UIImageJPEGRepresentation(self.shareImage, 0);
    
    WBMessageObject *message = [WBMessageObject message];
    message.text = [NSString stringWithFormat:@"%@：%@。分享链接：%@", self.title, self.content, self.shareURL];
    message.imageObject = imageObj;
   
    return message;
}

- (WXMediaMessage *)WeChatMessageObject {
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = [NSString stringWithFormat:@"%@", self.title];
    message.description = (self.content.length > 50)?[self.content substringToIndex:50]:self.content;
    
    if (self.shareImage != nil) {
        //!!!需要压缩
        NSData *imgData = UIImageJPEGRepresentation(self.shareImage, 0);
        UIImage *smallImage = [UIImage imageWithData:imgData];
        [message setThumbImage:smallImage];
    }
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = [NSString stringWithFormat:@"%@", self.shareURL];
    message.mediaObject = ext;
    return message;
}

- (QQApiNewsObject *)QQNewsObject {
    NSURL *previewURL = [NSURL URLWithString:self.shareImageURL];
    NSURL *url = [NSURL URLWithString:self.shareURL];
    
    QQApiNewsObject *obj = [QQApiNewsObject objectWithURL:url title:self.title description:self.content previewImageURL:previewURL];
    return obj;
}

@end
