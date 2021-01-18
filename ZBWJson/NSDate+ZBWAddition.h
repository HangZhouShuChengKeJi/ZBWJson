//
//  NSDate+ZBWAddition.h
//  Template
//
//  Created by Bowen on 16/7/11.
//  Copyright © 2016年 Bowen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ZBWAddition_FormatString)

+ (NSDateFormatter *)zbw_getDateFormatter;

- (NSString*)zbw_stringWithFormat:(NSString*)fmt;
+ (NSDate*)zbw_dateFromString:(NSString*)str withFormat:(NSString*)fmt;
+ (NSDate *)zbw_dateFromString:(NSString *)str withFormat:(NSString *)fmt locale:(NSLocale *)locale;

@end

