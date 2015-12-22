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
@synthesize content = _content;

- (void)setContent:(NSString *)content {
    _content = (content.length > 50)?[NSString stringWithFormat:@"%@", [content substringToIndex:50]]:content;
}
- (void)setObjectType:(NYShareObjectType)objectType {
    _objectType = objectType;
    switch (objectType) {
        case NYShareObjectTypeProject: {
            self.title = [NSString stringWithFormat:@"合投猫推荐项目[%@]", _title];
            self.shareURL = [NSString stringWithFormat:@"%@/share/proj?id=%@&from=appshare", SHARE_BASE_URL, _shareID];
            self.shareImage = _shareImage;
            
            break;
        }
        case NYShareObjectTypeNews: {
            self.title = [NSString stringWithFormat:@"合投猫推荐资讯[%@]", _title];
            self.shareURL = [NSString stringWithFormat:@"%@", _shareURL];
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
    imageObj.imageData = (self.shareImage != nil)?UIImageJPEGRepresentation(self.shareImage, 0):UIImageJPEGRepresentation(DefaultPortrait, 0);
    
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
        CGFloat w = 300;
        
        [message setThumbImage:[smallImage image:smallImage scaleToSize:CGSizeMake(w, w)]];
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
