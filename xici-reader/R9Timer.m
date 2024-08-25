//
//  R9Timer.m
//  r9
//
//  Created by Xianglong Ni on 1/17/13.
//  Copyright (c) 2013 Hanning. All rights reserved.
//

#import "R9Timer.h"

@interface R9Timer()
 
@end


@implementation R9Timer



+ (instancetype)sharedR9Timer
{
    static dispatch_once_t onceToken;
    static R9Timer * dbConnectionManager;
    dispatch_once(&onceToken, ^{
        dbConnectionManager = [[[self class] alloc] init];
        [dbConnectionManager oneTimeInit];
    });
    return dbConnectionManager;
}

- (void)oneTimeInit {     
    NSTimeZone *zone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
     dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yy/MM/dd hh:mm"];
    [dateFormatter setTimeZone:zone];
    dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"yy/MM/dd"];
    [dateFormatter2 setTimeZone:zone];

}
 

- (NSString *)formatSimpleTimeWithSeconds:(NSTimeInterval)miliseconds{
    if ( miliseconds < 100 )
        return @"-";
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:miliseconds];
    return [dateFormatter2 stringFromDate:date];
}
- (NSString *)formatTimeWithSeconds:(NSTimeInterval)miliseconds
{
    if ( miliseconds < 100 )
        return @"-";
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:miliseconds];
    return [dateFormatter stringFromDate:date];
}
- (NSString *)formatTime:(NSDate*)date
{
    if ( date == nil )
        return @"-";
     return [dateFormatter stringFromDate:date];
}
- (NSString *)formatTime2:(NSDate*)date
{
    if ( date == nil )
        return @"-";
    return [dateFormatter2 stringFromDate:date];
}

@end
