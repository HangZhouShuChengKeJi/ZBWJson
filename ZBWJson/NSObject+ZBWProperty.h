//
//  NSObject+ZBWProperty.h
//  Template
//
//  Created by Bowen on 15/9/11.
//  Copyright (c) 2015年 Bowen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ZBWOPType) {
    ZBWOPTypeNone = '0',
    ZBWOPTypeChar = 'c',
    ZBWOPTypeInt = 'i',
    ZBWOPTypeShort = 's',
    ZBWOPTypeLong = 'l',
    ZBWOPTypeLongLong = 'q',
    ZBWOPTypeUnsignedChar = 'C',
    ZBWOPTypeUnsignedInt = 'I',
    ZBWOPTypeUnsignedShort = 'S',
    ZBWOPTypeUnsignedLong = 'L',
    ZBWOPTypeUnsignedLongLong = 'Q',
    ZBWOPTypeFloat = 'f',
    ZBWOPTypeDouble = 'd',
    ZBWOPTypeBool = 'B',
    ZBWOPTypeVoid = 'v',
    ZBWOPTypeCharString = '*',
    ZBWOPTypeObject = '@',
    ZBWOPTypeClassObject = '#',
    ZBWOPTypeSelector = ':',
    ZBWOPTypeArray = '[',
    ZBWOPTypeStruct = '{',
    ZBWOPTypeUnion = '(',
    ZBWOPTypeBitField = 'b',
    ZBWOPTypePointer = '^',
    ZBWOPTypeUnknow = '?'
};

/**
 *  遍历类中所有的property属性，包括对父类遍历
 */
@interface NSObject (ZBWProperty)

/**
 *  获取当前对象的所有属性，不包括父类中的属性； key：属性名 value：ZBWProperty
 *
 *  @return NSDictionary
 */
+ (NSDictionary *)zbwOP_currentPropertyDic;

/**
 *  获取对象的所有属性，包括父类中的属性； key：属性名 value：ZBWProperty
 *
 *  @return NSDictionary
 */
+ (NSDictionary *)zbwOP_propertyDic;

/**
 *  获取当前对象的所有属性，不包括父类中的属性； value：ZBWProperty
 *
 *  @return NSArray
 */
+ (NSArray *)zbwOP_currentPropertyList;

/**
 *  获取对象的所有属性，包括父类中的属性； value：ZBWProperty
 *
 *  @return NSArray
 */
+ (NSArray *)zbwOP_propertyList;


/**
 ORM 属性与json字段 映射关系。key为属性名称；value为json字段名称
 属性指定了json字段名称，这使用指定名称。否则，使用属性名称映射。
 
 @return 属性-json字段映射表。默认为nil，使用属性名称完全匹配。
 */
+ (NSDictionary *)zbwOP_orm;

@end

/**
 *  属性
 */
@interface ZBWProperty : NSObject
// 属性名称
@property (nonatomic, copy) NSString *name;
// orm 映射。json字段名称
@property (nonatomic, retain) NSString *jsonFeildName;
// 属性类型
@property (nonatomic, assign) ZBWOPType valueType;
@property (nonatomic, copy) NSString *typeName;
@property (nonatomic, assign) Class objectClass;
@property (nonatomic, retain) NSArray *objectProtocols;
@property (nonatomic, assign) BOOL isReadonly;
@property (nonatomic, assign) BOOL isWeak;
@property (nonatomic)         SEL getter;
@property (nonatomic)         SEL setter;

- (id)initWithName:(NSString *)name typeString:(NSString *)typeString;

- (instancetype)clone;

@end



