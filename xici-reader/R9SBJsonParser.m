/*
 Copyright (C) 2009,2010 Stig Brautaset. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
   to endorse or promote products derived from this software without specific
   prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "R9SBJsonParser.h"
#import "R9SBJsonStreamParser.h"
#import "R9SBJsonStreamParserAdapter.h"
#import "R9SBJsonStreamParserAccumulator.h"
#import "Constants.h"

@implementation R9SBJsonParser

@synthesize maxDepth;
@synthesize error;

- (id)init {
    self = [super init];
    if (self)
        self.maxDepth = 32u;
    return self;
}


#pragma mark Methods

- (id)objectWithData:(NSData *)data {

    if (!data) {
        self.error = @"Input was 'nil'";
        return nil;
    }

	R9SBJsonStreamParserAccumulator *accumulator = [[R9SBJsonStreamParserAccumulator alloc] init];
    
    R9SBJsonStreamParserAdapter *adapter = [[R9SBJsonStreamParserAdapter alloc] init];
    adapter.delegate = accumulator;
	
	R9SBJsonStreamParser *parser = [[R9SBJsonStreamParser alloc] init];
	parser.maxDepth = self.maxDepth;
	parser.delegate = adapter;
	
	switch ([parser parse:data]) {
		case R9SBJsonStreamParserComplete:
            return accumulator.value;
			break;
			
		case R9SBJsonStreamParserWaitingForData:
		    self.error = @"Unexpected end of input";
			break;

		case R9SBJsonStreamParserError:
		    self.error = parser.error;
			break;
	}
	
	return nil;
}

- (id)objectWithString:(NSString *)repr {
	return [self objectWithData:[repr dataUsingEncoding:kENC]];
}

- (id)objectWithString:(NSString*)repr error:(NSError**)error_ {
	id tmp = [self objectWithString:repr];
    if (tmp)
        return tmp;
    
    if (error_) {
		NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:error, NSLocalizedDescriptionKey, nil];
        *error_ = [NSError errorWithDomain:@"org.brautaset.R9SBJsonParser.ErrorDomain" code:0 userInfo:ui];
	}
	
    return nil;
}

@end
