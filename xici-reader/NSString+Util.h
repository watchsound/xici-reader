//
//  NSString+Util.h
//  西祠利器
//
//  Created by Hanning Ni on 11/22/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TextWithLoc.h"
#import "GTMNSString+HTML.h"

@interface NSString (Util)

-(TextWithLoc*)getText:(NSString*)startTag  endTag:(NSString*)endTag startLoc:(int)startLoc   includeTag:(BOOL)includeTag;

- (NSString *)stringByConvertingHTMLToPlainText ;

@end
