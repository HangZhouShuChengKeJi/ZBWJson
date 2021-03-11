//
//  NSObject+JSON.h
//  Template
//
//  Created by Bowen on 15/9/17.
//  Copyright (c) 2015年 Bowen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 【反序列化】 json的字典或数组，转换成Objc对象
 */
@interface NSObject (ZBW_JSONDeserialization)

#pragma mark- 反序列化
#pragma mark- 【json dictionary】 转成 【Object对象】
- (id)zbw_initWithJsonDic:(NSDictionary *)dictionary;
- (id)zbw_initWithJsonDic:(NSDictionary *)dictionary depth:(NSInteger)depth;
- (id)zbw_initWithJsonStr:(NSString *)jsonStr;
- (id)zbw_initWithJsonStr:(NSString *)jsonStr depth:(NSInteger)depth;

+ (NSArray *)zbw_arrayWithJsonArray:(NSArray *)array itemClass:(Class)itemClass;
+ (NSArray *)zbw_arrayWithJsonArray:(NSArray *)array itemClass:(Class)itemClass depth:(NSInteger)depth;
+ (NSArray *)zbw_arrayWithJsonStr:(NSString *)jsonStr itemClass:(Class)itemClass;
+ (NSArray *)zbw_arrayWithJsonStr:(NSString *)jsonStr itemClass:(Class)itemClass depth:(NSInteger)depth;

@end


#pragma mark- 序列化

/**
 *  【序列化】 把对象转成json 字典、NSData 或 字符串
 */
@interface NSObject (ZBW_JSONSerialization)
#pragma mark- 【Object对象】转成【json，如NSArray,NSDictionary等等】
- (id)zbw_jsonObject;
- (id)zbw_jsonObjectWithDepth:(NSInteger)depth;

- (NSData *)zbw_jsonData;
- (NSData *)zbw_jsonDataWithDepth:(NSInteger)depth;

- (NSString *)zbw_jsonString;
- (NSString *)zbw_jsonStringWithDepth:(NSInteger)depth;
@end
