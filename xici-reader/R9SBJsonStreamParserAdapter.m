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

#import "R9SBJsonStreamParserAdapter.h"

@interface R9SBJsonStreamParserAdapter ()

- (void)pop;
- (void)parser:(R9SBJsonStreamParser*)parser found:(id)obj;

@end



@implementation R9SBJsonStreamParserAdapter

@synthesize delegate;
@synthesize levelsToSkip;

#pragma mark Housekeeping

- (id)init {
	self = [super init];
	if (self) {
		keyStack = [[NSMutableArray alloc] initWithCapacity:32];
		stack = [[NSMutableArray alloc] initWithCapacity:32];
		
		currentType = R9SBJsonStreamParserAdapterNone;
	}
	return self;
}	


#pragma mark Private methods

- (void)pop {
	[stack removeLastObject];
	array = nil;
	dict = nil;
	currentType = R9SBJsonStreamParserAdapterNone;
	
	id value = [stack lastObject];
	
	if ([value isKindOfClass:[NSArray class]]) {
		array = value;
		currentType = R9SBJsonStreamParserAdapterArray;
	} else if ([value isKindOfClass:[NSDictionary class]]) {
		dict = value;
		currentType = R9SBJsonStreamParserAdapterObject;
	}
}

- (void)parser:(R9SBJsonStreamParser*)parser found:(id)obj {
	NSParameterAssert(obj);
	
	switch (currentType) {
		case R9SBJsonStreamParserAdapterArray:
			[array addObject:obj];
			break;

		case R9SBJsonStreamParserAdapterObject:
			NSParameterAssert(keyStack.count);
			[dict setObject:obj forKey:[keyStack lastObject]];
			[keyStack removeLastObject];
			break;
			
		case R9SBJsonStreamParserAdapterNone:
			if ([obj isKindOfClass:[NSArray class]]) {
				[delegate parser:parser foundArray:obj];
			} else {
				[delegate parser:parser foundObject:obj];
			}				
			break;

		default:
			break;
	}
}


#pragma mark Delegate methods

- (void)parserFoundObjectStart:(R9SBJsonStreamParser*)parser {
	if (++depth > self.levelsToSkip) {
		dict = [NSMutableDictionary new];
		[stack addObject:dict];
		currentType = R9SBJsonStreamParserAdapterObject;
	}
}

- (void)parser:(R9SBJsonStreamParser*)parser foundObjectKey:(NSString*)key_ {
	[keyStack addObject:key_];
}

- (void)parserFoundObjectEnd:(R9SBJsonStreamParser*)parser {
	if (depth-- > self.levelsToSkip) {
		id value = dict;
		[self pop];
		[self parser:parser found:value];
	}
}

- (void)parserFoundArrayStart:(R9SBJsonStreamParser*)parser {
	if (++depth > self.levelsToSkip) {
		array = [NSMutableArray new];
		[stack addObject:array];
		currentType = R9SBJsonStreamParserAdapterArray;
	}
}

- (void)parserFoundArrayEnd:(R9SBJsonStreamParser*)parser {
	if (depth-- > self.levelsToSkip) {
		id value = array;
		[self pop];
		[self parser:parser found:value];
	}
}

- (void)parser:(R9SBJsonStreamParser*)parser foundBoolean:(BOOL)x {
	[self parser:parser found:[NSNumber numberWithBool:x]];
}

- (void)parserFoundNull:(R9SBJsonStreamParser*)parser {
	[self parser:parser found:[NSNull null]];
}

- (void)parser:(R9SBJsonStreamParser*)parser foundNumber:(NSNumber*)num {
	[self parser:parser found:num];
}

- (void)parser:(R9SBJsonStreamParser*)parser foundString:(NSString*)string {
	[self parser:parser found:string];
}

@end
