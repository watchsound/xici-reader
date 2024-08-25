//
//  Util.h
//  西祠利器
//
//  Created by Hanning Ni on 11/22/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

+ (NSString *)generateShortUUID;

+(BOOL)isEmptyString:(NSObject*)str minSize:(int)minSize;
+ (NSDictionary *)parseQueryString:(NSString *)query;

@end
