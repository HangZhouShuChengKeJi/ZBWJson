//
//  NSObject+JSON.m
//  Template
//
//  Created by Bowen on 15/9/17.
//  Copyright (c) 2015年 Bowen. All rights reserved.
//

#import "NSObject+ZBWJson.h"
#import "NSObject+ZBWProperty.h"
#import <UIKit/UIKit.h>
#import "NSDate+ZBWAddition.h"

#define zbw_Max_Depth       16

@implementation NSObject (ZBW_JSONDeserialization)

- (id)zbw_initWithJsonDic:(NSDictionary *)dictionary
{
    return [self zbw_initWithJsonDic:dictionary depth:zbw_Max_Depth];
}

- (id)zbw_initWithJsonDic:(NSDictionary *)dictionary depth:(NSInteger)depth
{
    if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    Class aClass = [self class];
    
    [[aClass zbwOP_propertyList] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ZBWProperty *property = (ZBWProperty *)obj;
        id jsonValue = dictionary[property.jsonFeildName];
        if (jsonValue && ![jsonValue isKindOfClass:[NSNull class]])
        {
            id valueOfProperty = [NSObject zbw_valueOfProperty:property withJsonValue:jsonValue depth:depth];
            if (valueOfProperty)
            {
                [self setValue:valueOfProperty forKey:property.name];
            }
        }
    }];
    
    return self;
}

- (id)zbw_initWithJsonStr:(NSString *)jsonStr {
    NSDictionary *dic = jsonStr.zbw_jsonObject;
    return [self zbw_initWithJsonDic:dic];
}

- (id)zbw_initWithJsonStr:(NSString *)jsonStr depth:(NSInteger)depth {
    NSDictionary *dic = jsonStr.zbw_jsonObject;
    return [self zbw_initWithJsonDic:dic depth:depth];
}

+ (NSArray *)zbw_arrayWithJsonArray:(NSArray *)array itemClass:(Class)itemClass
{
    return [self zbw_arrayWithJsonArray:array itemClass:itemClass depth:zbw_Max_Depth];
}

+ (NSArray *)zbw_arrayWithJsonArray:(NSArray *)array itemClass:(Class)itemClass depth:(NSInteger)depth
{
    if (!array || ![array isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    if (!itemClass) {
        return nil;
    }
    
    if (depth == 0) {
        return nil;
    }
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:array.count];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
        }
        else if ([obj isKindOfClass:[NSDictionary class]]){
            id v = [[itemClass alloc] zbw_initWithJsonDic:obj depth:depth-1];
            v ? [mutableArray addObject:v] : nil;
        }
        else if ([obj isKindOfClass:[NSArray class]]) {
            id v = [NSObject zbw_arrayWithJsonArray:obj itemClass:itemClass depth:depth-1];
            v ? [mutableArray addObject:v] : nil;
        }
    }];
    
    return mutableArray;
}

+ (NSArray *)zbw_arrayWithJsonStr:(NSString *)jsonStr itemClass:(Class)itemClass {
    NSArray *array = jsonStr.zbw_jsonObject;
    return [NSArray zbw_arrayWithJsonArray:array itemClass:itemClass];
}

+ (NSArray *)zbw_arrayWithJsonStr:(NSString *)jsonStr itemClass:(Class)itemClass depth:(NSInteger)depth {
    NSArray *array = jsonStr.zbw_jsonObject;
    return [NSArray zbw_arrayWithJsonArray:array itemClass:itemClass depth:depth];
}

+ (id)zbw_valueOfProperty:(ZBWProperty *)property withJsonValue:(id)value depth:(NSInteger)depth
{
    if (depth == 0) {
        return nil;
    }
    id resultValue = value;
    if (value == nil || [value isKindOfClass:[NSNull class]])
    {
        resultValue = nil;
    }
    else
    {
        if (property.valueType != ZBWOPTypeObject)
        {
            /*当属性为原始数据类型而对应的json dict中的value的类型为字符串对象的时候
             则对字符串进行相应的转换*/
            if ([value isKindOfClass:[NSString class]])
            {
                if (property.valueType == ZBWOPTypeInt ||
                    property.valueType == ZBWOPTypeUnsignedInt||
                    property.valueType == ZBWOPTypeShort||
                    property.valueType == ZBWOPTypeUnsignedShort)
                {
                    resultValue = [NSNumber numberWithInt:[(NSString *)value intValue]];
                }
                if (property.valueType == ZBWOPTypeLong ||
                    property.valueType == ZBWOPTypeUnsignedLong ||
                    property.valueType == ZBWOPTypeLongLong ||
                    property.valueType == ZBWOPTypeUnsignedLongLong)
                {
                    resultValue = [NSNumber numberWithLongLong:[(NSString *)value longLongValue]];
                }
                if (property.valueType == ZBWOPTypeFloat)
                {
                    resultValue = [NSNumber numberWithFloat:[(NSString *)value floatValue]];
                }
                if (property.valueType == ZBWOPTypeDouble)
                {
                    resultValue = [NSNumber numberWithDouble:[(NSString *)value doubleValue]];
                }
                if (property.valueType == ZBWOPTypeChar)
                {
                    //对于BOOL而言，@encode(BOOL) 为 c 也就是signed char
                    resultValue = [NSNumber numberWithBool:[(NSString *)value boolValue]];
                }
            }
        }
        else
        {
            Class valueClass = property.objectClass;
            
            //当当前属性为NSString类型，而对应的json的value为非NSString对象，自动进行转换
            if ([valueClass isSubclassOfClass:[NSString class]])
            {
                if (![value isKindOfClass:[NSString class]])
                {
                    // number转字符串。避免出现精度问题
                    if ([value isKindOfClass:[NSNumber class]]) {
                        NSNumber *number = value;
                        NSString *dStr = [NSString stringWithFormat:@"%f", number.doubleValue];
                        NSDecimalNumber *dn = [NSDecimalNumber decimalNumberWithString:dStr];
                        resultValue = dn.stringValue;
                    } else {
                        resultValue = [NSString stringWithFormat:@"%@",value];
                    }
                }
            }
            //当当前属性为NSNumber类型，而对应的json的value为NSString的时候
            else if ([valueClass isSubclassOfClass:[NSNumber class]])
            {
                if ([value isKindOfClass:[NSString class]])
                {
                    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                    resultValue = [numberFormatter numberFromString:value];
                }
            }
            else if ([valueClass isKindOfClass:[NSDate class]]) {
                if ([value isKindOfClass:[NSString class]]) {
                    resultValue = [NSDate zbw_dateFromString:value withFormat:@"yyyy-MM-dd HH:mm:ss"];
                } else {
                    return nil;
                }
            }
            else if ([valueClass isSubclassOfClass:[NSArray class]])
            {
                resultValue = [NSMutableArray arrayWithCapacity:10];
                if ([value isKindOfClass:[NSArray class]])
                {
                    for (id item in value)
                    {
                        if ([item isKindOfClass:[NSDictionary class]] && property.objectProtocols.count > 0)
                        {
                            Class protocolClass = NSClassFromString(property.objectProtocols[0]);
                            id itemValue = [[protocolClass alloc] zbw_initWithJsonDic:item depth:depth - 1];
                            if (itemValue)
                            {
                                [(NSMutableArray *)resultValue addObject:itemValue];
                            }
                        }
                        else if (property.objectProtocols.count > 0 && NSClassFromString(property.objectProtocols[0]) == [NSString class]) {
                            if ([item isKindOfClass:[NSString class]]) {
                                [(NSMutableArray *)resultValue addObject:item];
                            } else {
                                [(NSMutableArray *)resultValue addObject:[(NSObject *)item description]];
                            }
                        }
                        else
                        {
                            [(NSMutableArray *)resultValue addObject:item];
                        }
                    }
                }
            }
            else if ([valueClass isSubclassOfClass:[NSDictionary class]])
            {
                if ([value isKindOfClass:[NSDictionary class]])
                {
                    resultValue = value;
                }
                else
                {
                    resultValue = nil;
                }
            }
            else
            {
                resultValue = [[valueClass alloc] zbw_initWithJsonDic:value depth:depth - 1];
            }
        }
    }
    return resultValue;
}

@end


@implementation NSObject (ZBW_JSONSerialization)

- (id)zbw_jsonObject
{
    return [self zbw_jsonObjectWithDepth:zbw_Max_Depth];
}

- (id)zbw_jsonObjectWithDepth:(NSInteger)depth
{
    if (depth == 0) {
        return nil;
    }
    // NSString 和 NSNumber,直接返回self
    if ([self isKindOfClass:[NSString class]]) {
        NSData *data = [(NSString *)self dataUsingEncoding:NSUTF8StringEncoding];
        if (data) {
            id v = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (v) {
                return v;
            }
        }
        return self;
    }
    else if ([self isKindOfClass:[NSData class]]) {
        return [NSJSONSerialization JSONObjectWithData:(NSData *)self options:0 error:nil];
    }
    else if ([self isKindOfClass:[NSDate class]]) {
        return [(NSDate *)self zbw_stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    else if ([self isKindOfClass:[NSNumber class]]) {
        return self;
    }
    else if ([self isKindOfClass:[NSNull class]]) {
        return nil;
    }
    else if ([self isKindOfClass:[UIResponder class]]) {
        return nil;
    }
    // 如果是dictionary，便利value
    else if ([self isKindOfClass:[NSDictionary class]]) {
        NSArray *allKey = [(NSDictionary *)self allKeys];
        NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithCapacity:allKey.count];
        [allKey enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id v = [(NSDictionary *)self objectForKey:obj];
            id v1 = [v zbw_jsonObjectWithDepth:depth-1];
            if (v1) {
                mutableDic[obj] = v1;
            }
        }];
        return [mutableDic copy];
    }
    else if ([self isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:[(NSArray *)self count]];
        [(NSArray *)self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id v = [obj zbw_jsonObjectWithDepth:depth-1];
            if (v) {
                [array addObject:v];
            }
        }];
        return array;
    }
    
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithCapacity:5];
    [[self.class zbwOP_propertyList] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZBWProperty *property = (ZBWProperty *)obj;
        if (property.isWeak) {
            return;
        }
        id jsonValue = [self zbw_jsonValueOfProperty:property depth:depth];
        if (jsonValue && property.jsonFeildName) {
            mutableDic[property.jsonFeildName] = jsonValue;
        }
    }];
    
    return mutableDic;
}

- (NSData *)zbw_jsonData
{
    return [self zbw_jsonDataWithDepth:zbw_Max_Depth];
}
- (NSData *)zbw_jsonDataWithDepth:(NSInteger)depth
{
    id jsonObj = [self zbw_jsonObjectWithDepth:depth];
    if (!jsonObj) {
        return nil;
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonObj options:0 error:nil];
    return data;
}

- (NSString *)zbw_jsonString
{
    return [self zbw_jsonStringWithDepth:zbw_Max_Depth];
}

- (NSString *)zbw_jsonStringWithDepth:(NSInteger)depth
{
    NSData *data = [self zbw_jsonDataWithDepth:depth];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (id)zbw_jsonValueOfProperty:(ZBWProperty *)property depth:(NSInteger)depth;
{
    id value = [self valueForKey:property.name];
    
    // 基本类型直接返回value
    if (property.valueType != ZBWOPTypeObject) {
        // BOOL 值做一些处理，否则json化后，是true或false，转换成对应的1或0
        if (property.valueType == ZBWOPTypeBool) {
            return [(NSNumber *)value boolValue] ? @(1) : @(0);
        }
        
        return value;
    }
    
    //
    if ([self isKindOfClass:[NSString class]]) {
        return self;
    }
    else if ([self isKindOfClass:[NSData class]]) {
        return nil;
        //        return [NSJSONSerialization JSONObjectWithData:(NSData *)self options:0 error:nil];
    }
    else if ([self isKindOfClass:[NSNumber class]]) {
        return self;
    }
    else if ([self isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    return [value zbw_jsonObjectWithDepth:depth--];
}

@end
