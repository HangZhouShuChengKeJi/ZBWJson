//
//  NSObject+Property.m
//  Template
//
//  Created by Bowen on 15/9/11.
//  Copyright (c) 2015年 Bowen. All rights reserved.
//

#import "NSObject+ZBWProperty.h"
#import <objc/runtime.h>

static const void *zbwOP_CurrentPropertyDic_Key = &zbwOP_CurrentPropertyDic_Key;
static const void *zbwOP_PropertyDic_Key = &zbwOP_PropertyDic_Key;
static const void *zbwOP_PropertyList_Key = &zbwOP_PropertyList_Key;

@implementation NSObject (ZBWProperty)

+ (NSDictionary *)zbwOP_currentPropertyDic
{
    Class aClass = self;
    NSMutableDictionary *result = objc_getAssociatedObject(aClass, &zbwOP_CurrentPropertyDic_Key);
    if (result)
    {
        return result;
    }
    
    @synchronized (self) {
        result = objc_getAssociatedObject(aClass, &zbwOP_CurrentPropertyDic_Key);
        if (result)
        {
            return result;
        }
        
        result = [[NSMutableDictionary alloc] initWithCapacity:5];
        unsigned int count;
        objc_property_t *propertyList = class_copyPropertyList(aClass, &count);
        
        NSDictionary *orm = [self zbwOP_orm];
        NSArray *ignoreList = [self zbwOP_ignoreList];
        for (int i = 0; i < count; i++)
        {
            objc_property_t property = propertyList[i];
            NSString *name = [NSString stringWithUTF8String:property_getName(property)];
            NSString *attrType = [NSString stringWithUTF8String:property_getAttributes(property)];
            if ([@[@"hash",@"superclass",@"description",@"debugDescription"] containsObject:name]) {
                continue;
            }
            
            NSString *jsonFeildName = name;
            if (orm && orm[name]) {
                jsonFeildName = orm[name];
            }
            
            if (ignoreList && [ignoreList containsObject:name]) {
                jsonFeildName = @"ZBWJson ignore feild";
            }
            
            ZBWProperty *op = [[ZBWProperty alloc] initWithName:name typeString:attrType];
            op.jsonFeildName = jsonFeildName;
            [result setObject:op forKey:name];
        }
        //    CFRelease(propertyList);
        free(propertyList);
        
        objc_setAssociatedObject(aClass, &zbwOP_CurrentPropertyDic_Key, result, OBJC_ASSOCIATION_RETAIN);
        return result;
    }
}

+ (NSDictionary *)zbwOP_propertyDic
{
    Class aClass = self;
    NSMutableDictionary *result = objc_getAssociatedObject(aClass, &zbwOP_PropertyDic_Key);
    if (result)
    {
        return result;
    }
    
    result = [[NSMutableDictionary alloc] initWithCapacity:3];
    if (aClass == [NSObject class])
    {
        return nil;
    }

    @synchronized (self) {
        result = objc_getAssociatedObject(aClass, &zbwOP_PropertyDic_Key);
        if (result)
        {
            return result;
        }
        
        NSDictionary *dic = [aClass zbwOP_currentPropertyDic];
        [result setObject:NSStringFromClass(aClass) forKey:@"Class"];
        [result setObject:dic forKey:@"propertyList"];
        NSDictionary *superDic = [class_getSuperclass(aClass) zbwOP_propertyDic];
        if (superDic)
        {
            [result setObject:superDic forKey:@"super"];
        }
        
        objc_setAssociatedObject(aClass, &zbwOP_PropertyDic_Key, result, OBJC_ASSOCIATION_RETAIN);
        
        return [result copy];
    }
}

+ (NSArray *)zbwOP_currentPropertyList
{
    NSDictionary *dict = [self zbwOP_currentPropertyDic];
    return [dict allValues];
}

+ (NSArray *)zbwOP_propertyList
{
     Class aClass = self;
    if (aClass == [NSObject class])
    {
        return nil;
    }
    
    NSArray *result = objc_getAssociatedObject(aClass, &zbwOP_PropertyList_Key);
    if (result) {
        return result;
    }
    
    @synchronized (self) {
        result = objc_getAssociatedObject(aClass, &zbwOP_PropertyList_Key);
        if (result) {
            return result;
        }
        
        // 当前对象自己的成员变量属性list(不包含父类的)
        NSMutableArray *array = [NSMutableArray arrayWithArray:[aClass zbwOP_currentPropertyList]];
        // 父类的成员变量属性list
        id supArr = [class_getSuperclass(aClass) zbwOP_propertyList];
        if (supArr)
        {
            [array addObjectsFromArray:supArr];
        }
        
        // orm 重新映射（因为子类可以覆盖orm） key: 字段名， value：json名
        NSDictionary *orm = [self zbwOP_orm];
        
        if (orm) {
            NSMutableArray *copyArray = [NSMutableArray array];
            [array enumerateObjectsUsingBlock:^(ZBWProperty*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *propertyName = obj.name;
                
                NSString *ormValue = [orm objectForKey:propertyName];
                // 不一样，需要覆盖
                if (ormValue && ![ormValue isEqualToString:obj.jsonFeildName]) {
                    ZBWProperty *clone = [obj clone];
                    clone.jsonFeildName = ormValue;
                    [copyArray addObject:clone];
                } else {
                    [copyArray addObject:obj];
                }
            }];
            
            result = [copyArray copy];
        } else {
            result = [array copy];
        }
        
        objc_setAssociatedObject(aClass, &zbwOP_PropertyList_Key, result, OBJC_ASSOCIATION_RETAIN);
        
        return result;
    }
}

+ (NSDictionary *)zbwOP_orm {
    return nil;
}

+ (NSArray *)zbwOP_ignoreList {
    return nil;
}

@end


@implementation ZBWProperty

- (id)initWithName:(NSString *)name typeString:(NSString *)typeString{
//    NSLog(@"\n%@\n%@\n", name, typeString);
    self = [super init];
    if (self != nil) {
        self.name = name;
        
        NSArray *typeStringComponents = [typeString componentsSeparatedByString:@","];
        
        //解析类型信息
        if ([typeStringComponents count] > 0) {
            //类型信息肯定是放在最前面的且以“T”打头
            NSString *typeInfo = [typeStringComponents objectAtIndex:0];
            
            NSScanner *scanner = [NSScanner scannerWithString:typeInfo];
            [scanner scanUpToString:@"T" intoString:NULL];
            [scanner scanString:@"T" intoString:NULL];
            NSUInteger scanLocation = scanner.scanLocation;
            if ([typeInfo length] > scanLocation) {
                NSString *typeCode = [typeInfo substringWithRange:NSMakeRange(scanLocation, 1)];
                self.valueType = [typeCode characterAtIndex:0];
                
                //当当前的类型为对象的时候，解析出对象对应的类型的相关信息
                //T@"NSArray<OtherObject>"
                if (self.valueType == ZBWOPTypeObject) {
                    scanner.scanLocation += 1;
                    if ([scanner scanString:@"\"" intoString:NULL]) {
                        NSString *objectClassName = nil;
                        [scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet]
                                            intoString:&objectClassName];
                        self.typeName = objectClassName;
                        self.objectClass = NSClassFromString(objectClassName);
                        
                        NSMutableArray *protocols = [NSMutableArray array];
                        while ([scanner scanString:@"<" intoString:NULL]) {
                            NSString* protocolName = nil;
                            [scanner scanUpToString:@">" intoString: &protocolName];
                            if (protocolName != nil) {
                                // Xcode11.1后，NSArray<NSString>格式编译报错。使用NSArray<ZBWString>替换
                                if ([protocolName isEqualToString:@"ZBWString"]) {
                                    protocolName = @"NSString";
                                }
                                [protocols addObject:protocolName];
                            }
                            [scanner scanString:@">" intoString:NULL];
                        }
                        if ([protocols count] > 0) {
                            self.objectProtocols = protocols;
                        }
                    }
                }
            }
            
            for (int i = 1; i < typeStringComponents.count; i++) {
                NSString *str = typeStringComponents[i];
                if ([str hasPrefix:@"R"]) {
                    self.isReadonly = YES;
                } else if ([str hasPrefix:@"G"]) {
                    self.getter = NSSelectorFromString([str substringFromIndex:1]);
                } else if ([str hasPrefix:@"S"]) {
                    self.setter = NSSelectorFromString([str substringFromIndex:1]);
                }
                
                if ([str hasPrefix:@"W"]) {
                    self.isWeak = YES;
                }
            }
            
            if (!self.getter) {
                self.getter = NSSelectorFromString(self.name);
            }
            if (!self.setter && !self.isReadonly) {
                self.setter = [self.class zbw_setterMethodName:self.name];
            }
        }
    }
    return self;
}

- (instancetype)clone {
    ZBWProperty *clone = [[ZBWProperty alloc] init];
    
    clone.name = self.name;
    clone.jsonFeildName = self.jsonFeildName;
    clone.valueType = self.valueType;
    clone.typeName = self.typeName;
    clone.objectClass = self.objectClass;
    clone.objectProtocols = self.objectProtocols;
    clone.isReadonly = self.isReadonly;
    clone.getter = self.getter;
    clone.setter = self.setter;
    
    return clone;
}

+ (SEL)zbw_setterMethodName:(NSString *)propertyName
{
    if ([propertyName length] == 0)
        return nil;
    
    NSString *firstChar = [propertyName substringToIndex:1];
    firstChar = [firstChar uppercaseString];
    NSString *lastName = [propertyName substringFromIndex:1];
    return NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", firstChar, lastName]);
}

@end
