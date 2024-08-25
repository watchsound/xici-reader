/*
 Copyright (c) 2010, Stig Brautaset.
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

   Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

   Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

   Neither the name of the the author nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "R9SBJsonStreamParserState.h"
#import "R9SBJsonStreamParser.h"

#define SINGLETON \
+ (id)sharedInstance { \
    static id state = nil; \
    if (!state) state = [[self alloc] init]; \
    return state; \
}

@implementation R9SBJsonStreamParserState

+ (id)sharedInstance { return nil; }

- (BOOL)parser:(R9SBJsonStreamParser*)parser shouldAcceptToken:(R9SBJson_token_t)token {
	return NO;
}

- (R9SBJsonStreamParserStatus)parserShouldReturn:(R9SBJsonStreamParser*)parser {
	return R9SBJsonStreamParserWaitingForData;
}

- (void)parser:(R9SBJsonStreamParser*)parser shouldTransitionTo:(R9SBJson_token_t)tok {}

- (BOOL)needKey {
	return NO;
}

- (NSString*)name {
	return @"<aaiie!>";
}

- (BOOL)isError {
    return NO;
}

@end

#pragma mark -

@implementation R9SBJsonStreamParserStateStart

SINGLETON

- (BOOL)parser:(R9SBJsonStreamParser*)parser shouldAcceptToken:(R9SBJson_token_t)token {
	return token == R9SBJson_token_array_start || token == R9SBJson_token_object_start;
}

- (void)parser:(R9SBJsonStreamParser*)parser shouldTransitionTo:(R9SBJson_token_t)tok {

	R9SBJsonStreamParserState *state = nil;
	switch (tok) {
		case R9SBJson_token_array_start:
			state = [R9SBJsonStreamParserStateArrayStart sharedInstance];
			break;

		case R9SBJson_token_object_start:
			state = [R9SBJsonStreamParserStateObjectStart sharedInstance];
			break;

		case R9SBJson_token_array_end:
		case R9SBJson_token_object_end:
			if (parser.supportMultipleDocuments)
				state = parser.state;
			else
				state = [R9SBJsonStreamParserStateComplete sharedInstance];
			break;

		case R9SBJson_token_eof:
			return;

		default:
			state = [R9SBJsonStreamParserStateError sharedInstance];
			break;
	}


	parser.state = state;
}

- (NSString*)name { return @"before outer-most array or object"; }

@end

#pragma mark -

@implementation R9SBJsonStreamParserStateComplete

SINGLETON

- (NSString*)name { return @"after outer-most array or object"; }

- (R9SBJsonStreamParserStatus)parserShouldReturn:(R9SBJsonStreamParser*)parser {
	return R9SBJsonStreamParserComplete;
}

@end

#pragma mark -

@implementation R9SBJsonStreamParserStateError

SINGLETON

- (NSString*)name { return @"in error"; }

- (R9SBJsonStreamParserStatus)parserShouldReturn:(R9SBJsonStreamParser*)parser {
	return R9SBJsonStreamParserError;
}

- (BOOL)isError {
    return YES;
}

@end

#pragma mark -

@implementation R9SBJsonStreamParserStateObjectStart

SINGLETON

- (NSString*)name { return @"at beginning of object"; }

- (BOOL)parser:(R9SBJsonStreamParser*)parser shouldAcceptToken:(R9SBJson_token_t)token {
	switch (token) {
		case R9SBJson_token_object_end:
		case R9SBJson_token_string:
			return YES;
			break;
		default:
			return NO;
			break;
	}
}

- (void)parser:(R9SBJsonStreamParser*)parser shouldTransitionTo:(R9SBJson_token_t)tok {
	parser.state = [R9SBJsonStreamParserStateObjectGotKey sharedInstance];
}

- (BOOL)needKey {
	return YES;
}

@end

#pragma mark -

@implementation R9SBJsonStreamParserStateObjectGotKey

SINGLETON

- (NSString*)name { return @"after object key"; }

- (BOOL)parser:(R9SBJsonStreamParser*)parser shouldAcceptToken:(R9SBJson_token_t)token {
	return token == R9SBJson_token_keyval_separator;
}

- (void)parser:(R9SBJsonStreamParser*)parser shouldTransitionTo:(R9SBJson_token_t)tok {
	parser.state = [R9SBJsonStreamParserStateObjectSeparator sharedInstance];
}

@end

#pragma mark -

@implementation R9SBJsonStreamParserStateObjectSeparator

SINGLETON

- (NSString*)name { return @"as object value"; }

- (BOOL)parser:(R9SBJsonStreamParser*)parser shouldAcceptToken:(R9SBJson_token_t)token {
	switch (token) {
		case R9SBJson_token_object_start:
		case R9SBJson_token_array_start:
		case R9SBJson_token_true:
		case R9SBJson_token_false:
		case R9SBJson_token_null:
		case R9SBJson_token_number:
		case R9SBJson_token_string:
			return YES;
			break;

		default:
			return NO;
			break;
	}
}

- (void)parser:(R9SBJsonStreamParser*)parser shouldTransitionTo:(R9SBJson_token_t)tok {
	parser.state = [R9SBJsonStreamParserStateObjectGotValue sharedInstance];
}

@end

#pragma mark -

@implementation R9SBJsonStreamParserStateObjectGotValue

SINGLETON

- (NSString*)name { return @"after object value"; }

- (BOOL)parser:(R9SBJsonStreamParser*)parser shouldAcceptToken:(R9SBJson_token_t)token {
	switch (token) {
		case R9SBJson_token_object_end:
		case R9SBJson_token_separator:
			return YES;
			break;
		default:
			return NO;
			break;
	}
}

- (void)parser:(R9SBJsonStreamParser*)parser shouldTransitionTo:(R9SBJson_token_t)tok {
	parser.state = [R9SBJsonStreamParserStateObjectNeedKey sharedInstance];
}


@end

#pragma mark -

@implementation R9SBJsonStreamParserStateObjectNeedKey

SINGLETON

- (NSString*)name { return @"in place of object key"; }

- (BOOL)parser:(R9SBJsonStreamParser*)parser shouldAcceptToken:(R9SBJson_token_t)token {
    return R9SBJson_token_string == token;
}

- (void)parser:(R9SBJsonStreamParser*)parser shouldTransitionTo:(R9SBJson_token_t)tok {
	parser.state = [R9SBJsonStreamParserStateObjectGotKey sharedInstance];
}

- (BOOL)needKey {
	return YES;
}

@end

#pragma mark -

@implementation R9SBJsonStreamParserStateArrayStart

SINGLETON

- (NSString*)name { return @"at array start"; }

- (BOOL)parser:(R9SBJsonStreamParser*)parser shouldAcceptToken:(R9SBJson_token_t)token {
	switch (token) {
		case R9SBJson_token_object_end:
		case R9SBJson_token_keyval_separator:
		case R9SBJson_token_separator:
			return NO;
			break;

		default:
			return YES;
			break;
	}
}

- (void)parser:(R9SBJsonStreamParser*)parser shouldTransitionTo:(R9SBJson_token_t)tok {
	parser.state = [R9SBJsonStreamParserStateArrayGotValue sharedInstance];
}

@end

#pragma mark -

@implementation R9SBJsonStreamParserStateArrayGotValue

SINGLETON

- (NSString*)name { return @"after array value"; }


- (BOOL)parser:(R9SBJsonStreamParser*)parser shouldAcceptToken:(R9SBJson_token_t)token {
	return token == R9SBJson_token_array_end || token == R9SBJson_token_separator;
}

- (void)parser:(R9SBJsonStreamParser*)parser shouldTransitionTo:(R9SBJson_token_t)tok {
	if (tok == R9SBJson_token_separator)
		parser.state = [R9SBJsonStreamParserStateArrayNeedValue sharedInstance];
}

@end

#pragma mark -

@implementation R9SBJsonStreamParserStateArrayNeedValue

SINGLETON

- (NSString*)name { return @"as array value"; }


- (BOOL)parser:(R9SBJsonStreamParser*)parser shouldAcceptToken:(R9SBJson_token_t)token {
	switch (token) {
		case R9SBJson_token_array_end:
		case R9SBJson_token_keyval_separator:
		case R9SBJson_token_object_end:
		case R9SBJson_token_separator:
			return NO;
			break;

		default:
			return YES;
			break;
	}
}

- (void)parser:(R9SBJsonStreamParser*)parser shouldTransitionTo:(R9SBJson_token_t)tok {
	parser.state = [R9SBJsonStreamParserStateArrayGotValue sharedInstance];
}

@end

