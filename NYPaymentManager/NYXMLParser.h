//
//  NYXMLParser.h
//  NYShare
//
//  Created by 倪瑶 on 15/12/10.
//  Copyright © 2015年 nycode. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 * XML解析器
 **/
@interface NYXMLParser : NSObject <NSXMLParserDelegate> {
    NSXMLParser *xmlParser;             /**< 解析器 */
    NSMutableArray *xmlElements;        /**< 解析元素 */
    NSMutableDictionary *dictionary;    /**< 解析结果 */
    NSMutableString *contentString;     /**< 临时串变量 */
}

- (void)parseData:(NSData *)data;/**< 解析数据 */
- (NSMutableDictionary *)dictionary;/**< 获得字典 */

@end
