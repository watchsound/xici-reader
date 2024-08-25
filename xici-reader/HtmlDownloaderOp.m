//
//  HtmlDownloaderOp.m
//  西祠利器
//
//  Created by Hanning Ni on 11/28/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "HtmlDownloaderOp.h"

@interface HtmlDownloaderOp ()

@property (nonatomic, readwrite, strong) NSData*   result;
@property (nonatomic, readwrite, strong) NSString *url;
@property (nonatomic, readwrite, strong) NSString *key;
@property (nonatomic, readwrite, strong) NSString *requestKey;
@property (nonatomic, readwrite, strong) NSData *dict;
@property (assign) BOOL isPost;


@end



@implementation HtmlDownloaderOp


@synthesize delegate = _delegate;
@synthesize url = _url;
@synthesize requestKey = _requestKey;
@synthesize dict = _dict;
@synthesize isPost = _isPost;
@synthesize result = _result;
@synthesize key = _key;

#pragma mark -
#pragma mark - Life Cycle

- (id)initWithUrl:(NSString*)url key:(NSString*)key  parameters:(NSData *)dict isPost:(BOOL)isPost requestKey:(NSString*)requestKey
         delegate:(id<HtmlDownloaderOpDelegate>) theDelegate{
    
    if (self = [super init]) {
        
        self.delegate = theDelegate;
        self.url   = url;
        self.dict = dict;
        self.key = key;
        self.isPost = isPost;
        self.requestKey = requestKey;
        
    }
    return self;
}


-( NSString* )identifier{
    return self.requestKey;
}

- (BOOL)isEqual:(id)object{
    if ([object respondsToSelector:@selector(identifier)]) {
        return   [[object identifier] isEqualToString:[self identifier]];
    }
    return FALSE;
}

- (NSUInteger)hash{
    return  [self.identifier hash];
}



#pragma mark -
#pragma mark - Downloading image

// 3
- (void)main {
    
    // 4
    @autoreleasepool {
        
        NSString*  realUrl = [self.url copy];
        NSRange range = [realUrl rangeOfString:@"http"];
        if ( range.location == NSNotFound || range.location != 0 ){
            if ( [realUrl rangeOfString:@"b"].length == NSNotFound  ){
                realUrl = [@"b" stringByAppendingString:realUrl];
            }
            realUrl = [@"http://www.xici.net/" stringByAppendingString:realUrl];
        }
         NSStringEncoding enc =  CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        realUrl = [realUrl stringByAddingPercentEscapesUsingEncoding:enc];
        
        NSLog(@" fetch json full url = %@", realUrl );
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:realUrl]];
        if ( self.dict ){
            NSData *body =  self.dict ;
            [request setHTTPBody:body];
            NSString* requestDataLengthString = [[NSString alloc] initWithFormat:@"%li", (long)[body length]];
            [request setHTTPMethod:   @"POST"  ];
            [request setValue:requestDataLengthString forHTTPHeaderField:@"Content-Length"];
            
        } else {
            [request setHTTPMethod: (self.isPost ? @"POST" : @"GET" )];
            //  [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        }
        [request setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
        [request setValue:@"www.xici.net" forHTTPHeaderField:@"Host"];
        [request setValue:@"ISO-8859-1,utf-8;q=0.7,*;q=0.3" forHTTPHeaderField:@"Accept-Charset"];
        [request setValue:@"gzip,deflate,sdch" forHTTPHeaderField:@"Accept-Encoding"];
        [request setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
        [request setValue:@"en-US,en;q=0.8" forHTTPHeaderField:@"Accept-Language"];
        [request setValue:@"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.97 Safari/537.22" forHTTPHeaderField:@"User-Agent"];
        
        [request setHTTPShouldHandleCookies:YES];
        
        
            NSError *error;
            
            [request setTimeoutInterval:20];
            NSURLResponse *response = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
                 //
        if (self.isCancelled) {
            return;
        }
        if (data) {
            self.result = data;
        }
       
        
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(finishDownloadHtml:) withObject:self waitUntilDone:NO];
        
    }
}

@end

