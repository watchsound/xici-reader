/*
 Copyright (c) 2010-2011, Stig Brautaset. All rights reserved.

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

#import "R9SBJsonTokeniser.h"
#import "R9SBJsonUTF8Stream.h"

#define SBStringIsIllegalSurrogateHighCharacter(character) (((character) >= 0xD800UL) && ((character) <= 0xDFFFUL))
#define SBStringIsSurrogateLowCharacter(character) ((character >= 0xDC00UL) && (character <= 0xDFFFUL))
#define SBStringIsSurrogateHighCharacter(character) ((character >= 0xD800UL) && (character <= 0xDBFFUL))

static int const DECIMAL_MAX_PRECISION = 38;
static int const DECIMAL_EXPONENT_MAX = 127;
static short const DECIMAL_EXPONENT_MIN = -128;
static int const LONG_LONG_DIGITS = 20;

static NSCharacterSet *kDecimalDigitCharacterSet;

@implementation R9SBJsonTokeniser

@synthesize error = _error;
@synthesize stream = _stream;

+ (void)initialize {
    kDecimalDigitCharacterSet = [NSCharacterSet decimalDigitCharacterSet];
}

- (id)init {
    self = [super init];
    if (self) {
        _stream = [[R9SBJsonUTF8Stream alloc] init];

    }

    return self;
}


- (void)appendData:(NSData *)data_ {
    [_stream appendData:data_];
}


- (R9SBJson_token_t)match:(const char *)pattern length:(NSUInteger)len retval:(R9SBJson_token_t)token {
    if (![_stream haveRemainingCharacters:len])
        return R9SBJson_token_eof;

    if ([_stream skipCharacters:pattern length:len])
        return token;

    self.error = [NSString stringWithFormat:@"Expected '%s' after initial '%.1s'", pattern, pattern];
    return R9SBJson_token_error;
}

- (BOOL)decodeEscape:(unichar)ch into:(unichar*)decoded {
    switch (ch) {
        case '\\':
        case '/':
        case '"':
            *decoded = ch;
            break;

        case 'b':
            *decoded = '\b';
            break;

        case 'n':
            *decoded = '\n';
            break;

        case 'r':
            *decoded = '\r';
            break;

        case 't':
            *decoded = '\t';
            break;

        case 'f':
            *decoded = '\f';
            break;

        default:
            self.error = @"Illegal escape character";
            return NO;
            break;
    }
    return YES;
}

- (BOOL)decodeHexQuad:(unichar*)quad {
    unichar c, tmp = 0;

    for (int i = 0; i < 4; i++) {
        (void)[_stream getNextUnichar:&c];
        tmp *= 16;
        switch (c) {
            case '0' ... '9':
                tmp += c - '0';
                break;

            case 'a' ... 'f':
                tmp += 10 + c - 'a';
                break;

            case 'A' ... 'F':
                tmp += 10 + c - 'A';
                break;

            default:
                return NO;
        }
    }
    *quad = tmp;
    return YES;
}

- (R9SBJson_token_t)getStringToken:(NSObject**)token {
    NSMutableString *acc = nil;

    for (;;) {
        [_stream skip];
        
        unichar ch;
        {
            NSMutableString *string = nil;
            
            if (![_stream getStringFragment:&string])
                return R9SBJson_token_eof;
            
            if (!string) {
                self.error = @"Broken Unicode encoding";
                return R9SBJson_token_error;
            }
            
            if (![_stream getUnichar:&ch])
                return R9SBJson_token_eof;
            
            if (acc) {
                [acc appendString:string];
                
            } else if (ch == '"') {
                *token = [string copy];
                [_stream skip];
                return R9SBJson_token_string;
                
            } else {
                acc = [string mutableCopy];
            }
        }

        
        switch (ch) {
            case 0 ... 0x1F:
                self.error = [NSString stringWithFormat:@"Unescaped control character [0x%0.2X]", (int)ch];
                return R9SBJson_token_error;
                break;

            case '"':
                *token = acc;
                [_stream skip];
                return R9SBJson_token_string;
                break;

            case '\\':
                if (![_stream getNextUnichar:&ch])
                    return R9SBJson_token_eof;

                if (ch == 'u') {
                    if (![_stream haveRemainingCharacters:5])
                        return R9SBJson_token_eof;

                    unichar hi;
                    if (![self decodeHexQuad:&hi]) {
                        self.error = @"Invalid hex quad";
                        return R9SBJson_token_error;
                    }

                    if (SBStringIsSurrogateHighCharacter(hi)) {
                        unichar lo;

                        if (![_stream haveRemainingCharacters:6])
                            return R9SBJson_token_eof;

                        (void)[_stream getNextUnichar:&ch];
                        (void)[_stream getNextUnichar:&lo];
                        if (ch != '\\' || lo != 'u' || ![self decodeHexQuad:&lo]) {
                            self.error = @"Missing low character in surrogate pair";
                            return R9SBJson_token_error;
                        }

                        if (!SBStringIsSurrogateLowCharacter(lo)) {
                            self.error = @"Invalid low character in surrogate pair";
                            return R9SBJson_token_error;
                        }

                        [acc appendFormat:@"%C%C", hi, lo];
                    } else if (SBStringIsIllegalSurrogateHighCharacter(hi)) {
                        self.error = @"Invalid high character in surrogate pair";
                        return R9SBJson_token_error;
                    } else {
                        [acc appendFormat:@"%C", hi];
                    }


                } else {
                    unichar decoded;
                    if (![self decodeEscape:ch into:&decoded])
                        return R9SBJson_token_error;
                    [acc appendFormat:@"%C", decoded];
                }

                break;

            default: {
                self.error = [NSString stringWithFormat:@"Invalid UTF-8: '%x'", (int)ch];
                return R9SBJson_token_error;
                break;
            }
        }
    }
    return R9SBJson_token_eof;
}

- (R9SBJson_token_t)getNumberToken:(NSObject**)token {

    NSUInteger numberStart = _stream.index;

    unichar ch;
    if (![_stream getUnichar:&ch])
        return R9SBJson_token_eof;

    BOOL isNegative = NO;
    if (ch == '-') {
        isNegative = YES;
        if (![_stream getNextUnichar:&ch])
            return R9SBJson_token_eof;
    }

    unsigned long long mantissa = 0;
    int mantissa_length = 0;
    
    if (ch == '0') {
        mantissa_length++;
        if (![_stream getNextUnichar:&ch])
            return R9SBJson_token_eof;

        if ([kDecimalDigitCharacterSet characterIsMember:ch]) {
            self.error = @"Leading zero is illegal in number";
            return R9SBJson_token_error;
        }
    }

    while ([kDecimalDigitCharacterSet characterIsMember:ch]) {
        mantissa *= 10;
        mantissa += (ch - '0');
        mantissa_length++;

        if (![_stream getNextUnichar:&ch])
            return R9SBJson_token_eof;
    }

    short exponent = 0;
    BOOL isFloat = NO;

    if (ch == '.') {
        isFloat = YES;
        if (![_stream getNextUnichar:&ch])
            return R9SBJson_token_eof;

        while ([kDecimalDigitCharacterSet characterIsMember:ch]) {
            mantissa *= 10;
            mantissa += (ch - '0');
            mantissa_length++;
            exponent--;

            if (![_stream getNextUnichar:&ch])
                return R9SBJson_token_eof;
        }

        if (!exponent) {
            self.error = @"No digits after decimal point";
            return R9SBJson_token_error;
        }
    }

    BOOL hasExponent = NO;
    if (ch == 'e' || ch == 'E') {
        hasExponent = YES;

        if (![_stream getNextUnichar:&ch])
            return R9SBJson_token_eof;

        BOOL expIsNegative = NO;
        if (ch == '-') {
            expIsNegative = YES;
            if (![_stream getNextUnichar:&ch])
                return R9SBJson_token_eof;

        } else if (ch == '+') {
            if (![_stream getNextUnichar:&ch])
                return R9SBJson_token_eof;
        }

        short explicit_exponent = 0;
        short explicit_exponent_length = 0;
        while ([kDecimalDigitCharacterSet characterIsMember:ch]) {
            explicit_exponent *= 10;
            explicit_exponent += (ch - '0');
            explicit_exponent_length++;

            if (![_stream getNextUnichar:&ch])
                return R9SBJson_token_eof;
        }

        if (explicit_exponent_length == 0) {
            self.error = @"No digits in exponent";
            return R9SBJson_token_error;
        }

        if (expIsNegative)
            exponent -= explicit_exponent;
        else
            exponent += explicit_exponent;
    }

    if (!mantissa_length && isNegative) {
        self.error = @"No digits after initial minus";
        return R9SBJson_token_error;

    } else if (mantissa_length > DECIMAL_MAX_PRECISION) {
        self.error = @"Precision is too high";
        return R9SBJson_token_error;

    } else if (exponent > DECIMAL_EXPONENT_MAX || exponent < DECIMAL_EXPONENT_MIN) {
        self.error = @"Exponent out of range";
        return R9SBJson_token_error;
    }

    if (mantissa_length <= LONG_LONG_DIGITS) {
        if (!isFloat && !hasExponent) {
            *token = [NSNumber numberWithLongLong: isNegative ? -mantissa : mantissa];

        } else {
            *token = [NSDecimalNumber decimalNumberWithMantissa:mantissa
                                                       exponent:exponent
                                                     isNegative:isNegative];
        }

    } else {
        NSString *number = [_stream stringWithRange:NSMakeRange(numberStart, _stream.index - numberStart)];
        *token = [NSDecimalNumber decimalNumberWithString:number];

    }

    return R9SBJson_token_number;
}

- (R9SBJson_token_t)getToken:(NSObject **)token {

    [_stream skipWhitespace];

    unichar ch;
    if (![_stream getUnichar:&ch])
        return R9SBJson_token_eof;

    NSUInteger oldIndexLocation = _stream.index;
    R9SBJson_token_t tok;

    switch (ch) {
        case '[':
            tok = R9SBJson_token_array_start;
            [_stream skip];
            break;

        case ']':
            tok = R9SBJson_token_array_end;
            [_stream skip];
            break;

        case '{':
            tok = R9SBJson_token_object_start;
            [_stream skip];
            break;

        case ':':
            tok = R9SBJson_token_keyval_separator;
            [_stream skip];
            break;

        case '}':
            tok = R9SBJson_token_object_end;
            [_stream skip];
            break;

        case ',':
            tok = R9SBJson_token_separator;
            [_stream skip];
            break;

        case 'n':
            tok = [self match:"null" length:4 retval:R9SBJson_token_null];
            break;

        case 't':
            tok = [self match:"true" length:4 retval:R9SBJson_token_true];
            break;

        case 'f':
            tok = [self match:"false" length:5 retval:R9SBJson_token_false];
            break;

        case '"':
            tok = [self getStringToken:token];
            break;

        case '0' ... '9':
        case '-':
            tok = [self getNumberToken:token];
            break;

        case '+':
            self.error = @"Leading + is illegal in number";
            tok = R9SBJson_token_error;
            break;

        default:
            self.error = [NSString stringWithFormat:@"Illegal start of token [%c]", ch];
            tok = R9SBJson_token_error;
            break;
    }

    if (tok == R9SBJson_token_eof) {
        // We ran out of bytes in the middle of a token.
        // We don't know how to restart in mid-flight, so
        // rewind to the start of the token for next attempt.
        // Hopefully we'll have more data then.
        _stream.index = oldIndexLocation;
    }

    return tok;
}


@end
