//
//  NSDate+ZBWAddition.m
//  Template
//
//  Created by Bowen on 16/7/11.
//  Copyright © 2016年 Bowen. All rights reserved.
//

#import "NSDate+ZBWAddition.h"

const NSString *NSDate_ZBWAddition_NSDateFormatter_Key = @"NSDate_ZBWAddition_NSDateFormatter_Key";

@implementation NSDate (NSDate_ZBWAddition)

+ (NSDateFormatter *)zbw_getDateFormatter {
    NSMutableDictionary *dic = [NSThread currentThread].threadDictionary;
    NSDateFormatter *formatter = dic[NSDate_ZBWAddition_NSDateFormatter_Key];
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale systemLocale];
        formatter.calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierISO8601];
        dic[NSDate_ZBWAddition_NSDateFormatter_Key] = formatter;
    }
    return formatter;
}

- (NSString*)zbw_stringWithFormat:(NSString*)fmt {
    NSDateFormatter *fmtter = [NSDate zbw_getDateFormatter];
    
    if (fmt == nil || [fmt isEqualToString:@""]) {
        fmt = @"HH:mm:ss";
    }
    
    [fmtter setDateFormat:fmt];
    
    return [fmtter stringFromDate:self];
}

+ (NSDate*)zbw_dateFromString:(NSString*)str withFormat:(NSString*)fmt {
    NSDateFormatter *fmtter = [NSDate zbw_getDateFormatter];
    
    if (fmt == nil || [fmt isEqualToString:@""]) {
        fmt = @"HH:mm:ss";
    }
    
    [fmtter setDateFormat:fmt];
    
    return [fmtter dateFromString:str];
}


+ (NSDate *)zbw_dateFromString:(NSString*)str withFormat:(NSString*)fmt locale:(NSLocale *)locale {
    NSDateFormatter *fmtter = [NSDate zbw_getDateFormatter];
    
    if (fmt == nil || [fmt isEqualToString:@""]) {
        fmt = @"HH:mm:ss";
    }
    
    [fmtter setDateFormat:fmt];
    if (locale != nil) {
        [fmtter setLocale:locale];
    }
    
    return [fmtter dateFromString:str];
}


@end

