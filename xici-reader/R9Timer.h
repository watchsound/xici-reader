//
//  R9Timer.h
//  r9
//
//  Created by Xianglong Ni on 1/17/13.
//  Copyright (c) 2013 Hanning. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface R9Timer : NSObject{
    
    NSDateFormatter* dateFormatter ;
     NSDateFormatter* dateFormatter2 ;
}

+ (instancetype)sharedR9Timer;

- (NSString *)formatTimeWithSeconds:(NSTimeInterval)miliseconds;
- (NSString *)formatSimpleTimeWithSeconds:(NSTimeInterval)miliseconds;
- (NSString *)formatTime:(NSDate*)date;
- (NSString *)formatTime2:(NSDate*)date;
@end
