//
//  Util.m
//  西祠利器
//
//  Created by Hanning Ni on 11/22/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "Util.h"
#import "Constants.h"

@implementation Util


+ (NSString *)generateShortUUID
{
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	
	CFStringRef fullStr = CFUUIDCreateString(NULL, uuid);
	NSString *result = (__bridge_transfer NSString *)CFStringCreateWithSubstring(NULL, fullStr, CFRangeMake(0, 6));
	
	CFRelease(fullStr);
	CFRelease(uuid);
	
	return result;
}

+(BOOL)isEmptyString:(NSObject*)str minSize:(int)minSize{
    if ( !str )
        return TRUE;
    
    if ( ![str isKindOfClass:[NSString class]] )
        return TRUE;
    if ([(NSString*)str length] < minSize )
        return TRUE;
    if ([(NSString*)str isEqualToString:@" "])
        return TRUE;
    return FALSE;
}

+ (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    for (NSString *pair in pairs) {
        if( [pair  rangeOfString:@"=" options:NSCaseInsensitiveSearch].location != NSNotFound ){
            NSArray *elements = [pair componentsSeparatedByString:@"="];
            NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:kENC];
            NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:kENC];
            
            [dict setObject:val forKey:key];
        }
        else {
            [dict setObject:pair forKey:pair];
        }
    }
    return dict;
}

@end

