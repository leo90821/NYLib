//
//  NYXMLParser.m
//  NYShare
//
//  Created by 倪瑶 on 15/12/10.
//  Copyright © 2015年 nycode. All rights reserved.
//

#import "NYXMLParser.h"

@implementation NYXMLParser

- (void)parseData:(NSData *)data {
    
    dictionary =[NSMutableDictionary dictionary];
    contentString=[NSMutableString string];
   
    xmlElements = [[NSMutableArray alloc] init];
    xmlParser = [[NSXMLParser alloc] initWithData:data];
    
    [xmlParser setDelegate:self];
    [xmlParser parse];
    
}

- (NSMutableDictionary *)dictionary {
    return dictionary;
}

#pragma mark - delegate

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [contentString setString:string];
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
   
    if( ![contentString isEqualToString:@"\n"] && ![elementName isEqualToString:@"root"]){
        [dictionary setObject: [contentString copy] forKey:elementName];
    }
}


- (void)parserDidEndDocument:(NSXMLParser *)parser{
        
}
@end
