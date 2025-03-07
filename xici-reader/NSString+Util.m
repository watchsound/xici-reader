//
//  NSString+Util.m
//  西祠利器
//
//  Created by Hanning Ni on 11/22/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "NSString+Util.h"

@implementation NSString (Util)

-(TextWithLoc*)getText:(NSString*)startTag  endTag:(NSString*)endTag startLoc:(int)startLoc   includeTag:(BOOL)includeTag{
    NSRange range = NSMakeRange(startLoc, self.length - startLoc);
    range  =  [self  rangeOfString:startTag options:NSCaseInsensitiveSearch range:range];
    if ( range.location != NSNotFound ){
          NSRange range2 = NSMakeRange(range.location + range.length  , self.length - range.location - range.length);
          range2  =  [self  rangeOfString:endTag options:NSCaseInsensitiveSearch range:range2];
        if ( range2.location != NSNotFound ){
             TextWithLoc* textWithLoc = [[TextWithLoc alloc] init];
             if ( includeTag )
                 textWithLoc.range = NSMakeRange(range.location,   range2.location - range.location + range2.length);
             else
                 textWithLoc.range = NSMakeRange(range.location + range.length,   range2.location - range.location - range.length );
             textWithLoc.content = [self substringWithRange:textWithLoc.range];
            return textWithLoc;
        }
    }
    return nil;
}

- (NSString *)stringByConvertingHTMLToPlainText {
    
	// Pool
	//NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	// Character sets
	NSCharacterSet *stopCharacters = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"< \t\n\r%C%C%C%C", 0x0085, 0x000C, 0x2028, 0x2029]];
	NSCharacterSet *newLineAndWhitespaceCharacters = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@" \t\n\r%C%C%C%C", 0x0085, 0x000C, 0x2028, 0x2029]];
	NSCharacterSet *tagNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
    
	// Scan and find all tags
	NSMutableString *result = [[NSMutableString alloc] initWithCapacity:self.length];
	NSScanner *scanner = [[NSScanner alloc] initWithString:self];
	[scanner setCharactersToBeSkipped:nil];
	[scanner setCaseSensitive:YES];
	NSString *str = nil, *tagName = nil;
	BOOL dontReplaceTagWithSpace = NO;
	do {
        
		// Scan up to the start of a tag or whitespace
		if ([scanner scanUpToCharactersFromSet:stopCharacters intoString:&str]) {
			[result appendString:str];
			str = nil; // reset
		}
        
		// Check if we've stopped at a tag/comment or whitespace
		if ([scanner scanString:@"<" intoString:NULL]) {
            
			// Stopped at a comment or tag
			if ([scanner scanString:@"!--" intoString:NULL]) {
                
				// Comment
				[scanner scanUpToString:@"-->" intoString:NULL];
				[scanner scanString:@"-->" intoString:NULL];
                
			} else {
                
				// Tag - remove and replace with space unless it's
				// a closing inline tag then dont replace with a space
				if ([scanner scanString:@"/" intoString:NULL]) {
                    
					// Closing tag - replace with space unless it's inline
					tagName = nil; dontReplaceTagWithSpace = NO;
					if ([scanner scanCharactersFromSet:tagNameCharacters intoString:&tagName]) {
						tagName = [tagName lowercaseString];
						dontReplaceTagWithSpace = ([tagName isEqualToString:@"a"] ||
												   [tagName isEqualToString:@"b"] ||
												   [tagName isEqualToString:@"i"] ||
												   [tagName isEqualToString:@"q"] ||
												   [tagName isEqualToString:@"span"] ||
												   [tagName isEqualToString:@"em"] ||
												   [tagName isEqualToString:@"strong"] ||
												   [tagName isEqualToString:@"cite"] ||
												   [tagName isEqualToString:@"abbr"] ||
												   [tagName isEqualToString:@"acronym"] ||
												   [tagName isEqualToString:@"label"]);
					}
                    
					// Replace tag with string unless it was an inline
					if (!dontReplaceTagWithSpace && result.length > 0 && ![scanner isAtEnd]) [result appendString:@" "];
                    
				}
                
				// Scan past tag
				[scanner scanUpToString:@">" intoString:NULL];
				[scanner scanString:@">" intoString:NULL];
                
			}
            
		} else {
            
			// Stopped at whitespace - replace all whitespace and newlines with a space
			if ([scanner scanCharactersFromSet:newLineAndWhitespaceCharacters intoString:NULL]) {
				if (result.length > 0 && ![scanner isAtEnd]) [result appendString:@" "]; // Dont append space to beginning or end of result
			}
            
		}
        
	} while (![scanner isAtEnd]);
    
	// Cleanup
	scanner = nil;
    
	// Decode HTML entities and return
	return  [ result stringByDecodingHTMLEntities]  ;
    
    
}

- (NSString *)stringByDecodingHTMLEntities {
    // Can return self so create new string if we're a mutable string
    return [NSString stringWithString:[self gtm_stringByUnescapingFromHTML]];
}


- (NSString *)stringByEncodingHTMLEntities {
    // Can return self so create new string if we're a mutable string
    return [NSString stringWithString:[self gtm_stringByEscapingForAsciiHTML]];
}

- (NSString *)stringByEncodingHTMLEntities:(BOOL)isUnicode {
    // Can return self so create new string if we're a mutable string
    return [NSString stringWithString:(isUnicode ? [self gtm_stringByEscapingForHTML] : [self gtm_stringByEscapingForAsciiHTML])];
}

- (NSString *)stringWithNewLinesAsBRs {
    
	// Pool
    //	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	// Strange New lines:
	//	Next Line, U+0085
	//	Form Feed, U+000C
	//	Line Separator, U+2028
	//	Paragraph Separator, U+2029
    
	// Scanner
	NSScanner *scanner = [[NSScanner alloc] initWithString:self];
	[scanner setCharactersToBeSkipped:nil];
	NSMutableString *result = [[NSMutableString alloc] init];
	NSString *temp;
	NSCharacterSet *newLineCharacters = [NSCharacterSet characterSetWithCharactersInString:
										 [NSString stringWithFormat:@"\n\r%C%C%C%C", 0x0085, 0x000C, 0x2028, 0x2029]];
	// Scan
	do {
        
		// Get non new line characters
		temp = nil;
		[scanner scanUpToCharactersFromSet:newLineCharacters intoString:&temp];
		if (temp) [result appendString:temp];
		temp = nil;
        
		// Add <br /> s
		if ([scanner scanString:@"\r\n" intoString:nil]) {
            
			// Combine \r\n into just 1 <br />
			[result appendString:@"<br />"];
            
		} else if ([scanner scanCharactersFromSet:newLineCharacters intoString:&temp]) {
            
			// Scan other new line characters and add <br /> s
			if (temp) {
				for (NSUInteger i = 0; i < temp.length; i++) {
					[result appendString:@"<br />"];
				}
			}
            
		}
        
	} while (![scanner isAtEnd]);
    
    return [ NSString stringWithString:result];
	// Cleanup & return
	//[scanner release];
	//NSString *retString = [[NSString stringWithString:result] retain];
	//[result release];
    
	// Drain
	//[pool drain];
    
	// Return
	//return [retString autorelease];
    
}

- (NSString *)stringByRemovingNewLinesAndWhitespace {
    
	// Pool
	//NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	// Strange New lines:
	//	Next Line, U+0085
	//	Form Feed, U+000C
	//	Line Separator, U+2028
	//	Paragraph Separator, U+2029
    
	// Scanner
	NSScanner *scanner = [[NSScanner alloc] initWithString:self];
	[scanner setCharactersToBeSkipped:nil];
	NSMutableString *result = [[NSMutableString alloc] init];
	NSString *temp;
	NSCharacterSet *newLineAndWhitespaceCharacters = [NSCharacterSet characterSetWithCharactersInString:
													  [NSString stringWithFormat:@" \t\n\r%C%C%C%C", 0x0085, 0x000C, 0x2028, 0x2029]];
	// Scan
	while (![scanner isAtEnd]) {
        
		// Get non new line or whitespace characters
		temp = nil;
		[scanner scanUpToCharactersFromSet:newLineAndWhitespaceCharacters intoString:&temp];
		if (temp) [result appendString:temp];
        
		// Replace with a space
		if ([scanner scanCharactersFromSet:newLineAndWhitespaceCharacters intoString:NULL]) {
			if (result.length > 0 && ![scanner isAtEnd]) // Dont append space to beginning or end of result
				[result appendString:@" "];
		}
        
	}
    return [NSString stringWithString:result] ;
    //	// Cleanup
    //	[scanner release];
    //
    //	// Return
    //	NSString *retString = [[NSString stringWithString:result] retain];
    //	[result release];
    //
    //	// Drain
    //	[pool drain];
    //
    //	// Return
    //	return [retString autorelease];
    
}

- (NSString *)stringByLinkifyingURLs {
    if (!NSClassFromString(@"NSRegularExpression")) return self;
    //	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *pattern = @"(?<!=\")\\b((http|https):\\/\\/[\\w\\-_]+(\\.[\\w\\-_]+)+([\\w\\-\\.,@?^=%%&amp;:/~\\+#]*[\\w\\-\\@?^=%%&amp;/~\\+#])?)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    return   [ regex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length])
                                         withTemplate:@"<a href=\"$1\" class=\"linkified\">$1</a>"]  ;
    //[pool drain];
    //return [modifiedString autorelease];
}

- (NSString *)stringByStrippingTags {
    
	// Pool
	//NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	// Find first & and short-cut if we can
	NSUInteger ampIndex = [self rangeOfString:@"<" options:NSLiteralSearch].location;
	if (ampIndex == NSNotFound) {
		return [NSString stringWithString:self]; // return copy of string as no tags found
	}
    
	// Scan and find all tags
	NSScanner *scanner = [NSScanner scannerWithString:self];
	[scanner setCharactersToBeSkipped:nil];
	NSMutableSet *tags = [[NSMutableSet alloc] init];
	NSString *tag;
	do {
        
		// Scan up to <
		tag = nil;
		[scanner scanUpToString:@"<" intoString:NULL];
		[scanner scanUpToString:@">" intoString:&tag];
        
		// Add to set
		if (tag) {
			NSString *t = [[NSString alloc] initWithFormat:@"%@>", tag];
			[tags addObject:t];
            //	[t release];
		}
        
	} while (![scanner isAtEnd]);
    
	// Strings
	NSMutableString *result = [[NSMutableString alloc] initWithString:self];
	NSString *finalString;
    
	// Replace tags
	NSString *replacement;
	for (NSString *t in tags) {
        
		// Replace tag with space unless it's an inline element
		replacement = @" ";
		if ([t isEqualToString:@"<a>"] ||
			[t isEqualToString:@"</a>"] ||
			[t isEqualToString:@"<span>"] ||
			[t isEqualToString:@"</span>"] ||
			[t isEqualToString:@"<strong>"] ||
			[t isEqualToString:@"</strong>"] ||
			[t isEqualToString:@"<em>"] ||
			[t isEqualToString:@"</em>"]) {
			replacement = @"";
		}
        
		// Replace
		[result replaceOccurrencesOfString:t
								withString:replacement
								   options:NSLiteralSearch
									 range:NSMakeRange(0, result.length)];
	}
    
	// Remove multi-spaces and line breaks
    return [result stringByRemovingNewLinesAndWhitespace];
    //	finalString = [[result stringByRemovingNewLinesAndWhitespace] retain];
    
    //	// Cleanup
    //	[result release];
    //	[tags release];
    //
    //	// Drain
    //	[pool drain];
    //    
    //	// Return
    //    return [finalString autorelease];
    
}

 
@end
