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

#import "R9SBJsonStreamWriterState.h"
#import "R9SBJsonStreamWriter.h"

#define SINGLETON \
+ (id)sharedInstance { \
    static id state; \
    if (!state) state = [[self alloc] init]; \
    return state; \
}


@implementation R9SBJsonStreamWriterState
+ (id)sharedInstance { return nil; }
- (BOOL)isInvalidState:(R9SBJsonStreamWriter*)writer { return NO; }
- (void)appendSeparator:(R9SBJsonStreamWriter*)writer {}
- (BOOL)expectingKey:(R9SBJsonStreamWriter*)writer { return NO; }
- (void)transitionState:(R9SBJsonStreamWriter *)writer {}
- (void)appendWhitespace:(R9SBJsonStreamWriter*)writer {
	[writer appendBytes:"\n" length:1];
	for (NSUInteger i = 0; i < writer.stateStack.count; i++)
	    [writer appendBytes:"  " length:2];
}
@end

@implementation R9SBJsonStreamWriterStateObjectStart

SINGLETON

- (void)transitionState:(R9SBJsonStreamWriter *)writer {
	writer.state = [R9SBJsonStreamWriterStateObjectValue sharedInstance];
}
- (BOOL)expectingKey:(R9SBJsonStreamWriter *)writer {
	writer.error = @"JSON object key must be string";
	return YES;
}
@end

@implementation R9SBJsonStreamWriterStateObjectKey

SINGLETON

- (void)appendSeparator:(R9SBJsonStreamWriter *)writer {
	[writer appendBytes:"," length:1];
}
@end

@implementation R9SBJsonStreamWriterStateObjectValue

SINGLETON

- (void)appendSeparator:(R9SBJsonStreamWriter *)writer {
	[writer appendBytes:":" length:1];
}
- (void)transitionState:(R9SBJsonStreamWriter *)writer {
    writer.state = [R9SBJsonStreamWriterStateObjectKey sharedInstance];
}
- (void)appendWhitespace:(R9SBJsonStreamWriter *)writer {
	[writer appendBytes:" " length:1];
}
@end

@implementation R9SBJsonStreamWriterStateArrayStart

SINGLETON

- (void)transitionState:(R9SBJsonStreamWriter *)writer {
    writer.state = [R9SBJsonStreamWriterStateArrayValue sharedInstance];
}
@end

@implementation R9SBJsonStreamWriterStateArrayValue

SINGLETON

- (void)appendSeparator:(R9SBJsonStreamWriter *)writer {
	[writer appendBytes:"," length:1];
}
@end

@implementation R9SBJsonStreamWriterStateStart

SINGLETON


- (void)transitionState:(R9SBJsonStreamWriter *)writer {
    writer.state = [R9SBJsonStreamWriterStateComplete sharedInstance];
}
- (void)appendSeparator:(R9SBJsonStreamWriter *)writer {
}
@end

@implementation R9SBJsonStreamWriterStateComplete

SINGLETON

- (BOOL)isInvalidState:(R9SBJsonStreamWriter*)writer {
	writer.error = @"Stream is closed";
	return YES;
}
@end

@implementation R9SBJsonStreamWriterStateError

SINGLETON

@end

