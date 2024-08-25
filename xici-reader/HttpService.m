//
//  HttpService.m
//  西祠利器
//
//  Created by Hanning Ni on 11/22/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "HttpService.h"
#import "ForumImage.h"
#import "ImageDownloaderOp.h"
#import "ImageBatchRequest.h"
#import "LocalService.h"

@interface HttpService()

@property (nonatomic, strong) NSOperationQueue *downloadImageQueue;
@property (nonatomic, strong) NSOperationQueue *downloadHtmlQueue;
@property (nonatomic, strong) NSMutableArray* batchRequestList;

@end

@implementation HttpService

+ (instancetype)sharedHttpService
{
    static dispatch_once_t onceToken;
    static HttpService * httpService;
    dispatch_once(&onceToken, ^{
        httpService = [[[self class] alloc] init];
    });
    return httpService;
}

-(id)init{
    if ( self = [super init] ){
        self.downloadImageQueue = [[NSOperationQueue alloc] init];
        self.batchRequestList = [[NSMutableArray alloc] initWithCapacity:4];
        self.downloadHtmlQueue = [[NSOperationQueue alloc] init];
        self.downloadHtmlQueue.maxConcurrentOperationCount = 1;

    }
    return self;
}

- (void)downloadImage:(ForumImage*)image{
     if ( [[LocalService sharedLocalService] getImage:image.imageUid ] != nil )
         return;
    //  if ( [[NewsDAO getInstance] hasMediaContentFromDatabase:newsImage.imageName] )
    //    return;
    ImageDownloaderOp* op = [[ImageDownloaderOp alloc] initWithForumImage:image   delegate:self];
    [op setQueuePriority:NSOperationQueuePriorityNormal];
    if (! [[[self downloadImageQueue] operations] containsObject:op] )
        [[self downloadImageQueue] addOperation:op];
}

-(void)downloadWithUrl:(NSString*)url  key:(NSString*)key  parameters:(NSData *)dict isPost:(BOOL)isPost requestKey:(NSString*)requestKey    delegate:(id<HtmlDownloaderOpDelegate>) theDelegate{
  //  if ( [[NewsDAO getInstance] hasMediaContentFromDatabase:newsImage.imageName] )
    //    return;
    HtmlDownloaderOp* op = [[HtmlDownloaderOp alloc] initWithUrl: url key:key parameters: dict isPost: isPost requestKey: requestKey    delegate: theDelegate];
    [op setQueuePriority:NSOperationQueuePriorityNormal];
    if (! [[[self downloadHtmlQueue] operations] containsObject:op] )
        [[self downloadHtmlQueue] addOperation:op];
}

- (void)downloadImageBatch:(ImageBatchRequest*)imageBatch{
    //  if ( [[NewsDAO getInstance] hasMediaContentFromDatabase:newsImage.imageName] )
    //    return;
    [self.batchRequestList addObject: imageBatch];
    for ( ForumImage * image in imageBatch.forumImageList ) {
        NSData* result =  [[LocalService sharedLocalService] getImage:image.imageUid ];
        
        ImageDownloaderOp* op = [[ImageDownloaderOp alloc] initWithForumImage:image   batchId:[imageBatch getBatchId]  delegate:self];
        if ( result != nil ){
            op.forumImage.imageData = result;
           [self updateBatchResult:op];
        } else {
           [op setQueuePriority:NSOperationQueuePriorityNormal];
            if (! [[[self downloadImageQueue] operations] containsObject:op] )
                [[self downloadImageQueue] addOperation:op];
        }
        
    }
   
}


#pragma ImageDownloaderOpDelegate <NSObject>
- (void)finishDownload:(ImageDownloaderOp *)downloader{
    if ( downloader.forumImage.imageData != nil ){
//         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
//            
//        });
        
        [[LocalService sharedLocalService] saveImage: downloader.forumImage];
      
    }
    [self updateBatchResult:downloader];
}


-(void)updateBatchResult:(ImageDownloaderOp*)downloader{
    if ( downloader.batchId == nil )
        return;
    @synchronized(self.batchRequestList){
        ImageBatchRequest* finishedRequest = nil;
        for(ImageBatchRequest* batchRequest in self.batchRequestList){
            if ( [[batchRequest getBatchId] isEqualToString:downloader.batchId] ){
                BOOL finish = [batchRequest updateResult];
                if ( finish ){
                    finishedRequest = batchRequest;
                    break;
                }
            }
        }
        if ( finishedRequest != nil ){
            [self.batchRequestList removeObject:finishedRequest];
        }
    }
}


-(NSData*)getHtmlData:(NSString*)urlStr{
    NSURL * url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
      [request setHTTPMethod:   @"GET"  ];
    
     [request setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
     [request setValue:@"www.xici.net" forHTTPHeaderField:@"Host"];
     [request setValue:@"ISO-8859-1,utf-8;q=0.7,*;q=0.3" forHTTPHeaderField:@"Accept-Charset"];
     [request setValue:@"gzip,deflate,sdch" forHTTPHeaderField:@"Accept-Encoding"];
     [request setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
     [request setValue:@"en-US,en;q=0.8" forHTTPHeaderField:@"Accept-Language"];
     [request setValue:@"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.97 Safari/537.22" forHTTPHeaderField:@"User-Agent"];
    
    
//    post.addHeader("Accept",
//                   "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");
//    post.addHeader("Host", "www.xici.net");
//    post.addHeader("Accept-Charset",
//                   "ISO-8859-1,utf-8;q=0.7,*;q=0.3");
//    post.addHeader("Accept-Encoding", "gzip,deflate,sdch");
//    post.addHeader("Connection", "keep-alive");
//    post.addHeader("Accept-Language", "en-US,en;q=0.8");
//    
//    post.addHeader(
//                   "User-Agent",
//                   "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.97 Safari/537.22");

    
    
    NSError *error;
    
    [request setTimeoutInterval:20];
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
       NSArray* cookies =   [[NSHTTPCookieStorage sharedHTTPCookieStorage ]cookiesForURL:url];
    if(error)
     {
      NSLog(@"getHtmlData failed %@", error);
     }
    return data;
    
//    NSError *err = nil;
//    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_2312_80);
//    NSString *html = [NSString stringWithContentsOfURL:url encoding:enc error:&err];
//    
//    if(err)
//    {
//        NSLog(@"getHtmlData failed %@", err);
//    }
//    
//    return html;
}



//- (void)sendHttpAsyncRequest:(id<HttpAsyncRequestDelegate>)delegate withUrl:(NSString*)url
//   parameters:(NSData *)dict isPost:(BOOL)isPost requestKey:(NSString*)requestKey needWaitingIndicator:(BOOL)needWaitingIndicator{
//    NSRange range = [url rangeOfString:@"http"];
//    if ( range.location == NSNotFound || range.location != 0 )
//        url = [@"http://www.xici.net/" stringByAppendingString:url];
//    
//    NSLog(@" fetch json full url = %@", url );
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
//    if ( dict ){
//        NSData *body =  dict ;
//        [request setHTTPBody:body];
//        NSString* requestDataLengthString = [[NSString alloc] initWithFormat:@"%li", (long)[body length]];
//        [request setHTTPMethod:   @"POST"  ];
//        [request setValue:requestDataLengthString forHTTPHeaderField:@"Content-Length"];
//        
//    //    [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
//    //    [request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
//        
//    } else {
//        [request setHTTPMethod: (isPost ? @"POST" : @"GET" )];
//      //  [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
//    }
//    [request setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
//    [request setValue:@"www.xici.net" forHTTPHeaderField:@"Host"];
//    [request setValue:@"ISO-8859-1,utf-8;q=0.7,*;q=0.3" forHTTPHeaderField:@"Accept-Charset"];
//    [request setValue:@"gzip,deflate,sdch" forHTTPHeaderField:@"Accept-Encoding"];
//    [request setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
//    [request setValue:@"en-US,en;q=0.8" forHTTPHeaderField:@"Accept-Language"];
//    [request setValue:@"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.97 Safari/537.22" forHTTPHeaderField:@"User-Agent"];
//    
//    [request setHTTPShouldHandleCookies:YES];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
//        
//        NSError *error;
//        
//        [request setTimeoutInterval:20];
//        NSURLResponse *response = nil;
//        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//        
//        if ( ! delegate )
//            return ;
//        if ( error != nil){
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@" sendHttpAsyncRequest failed  %@", error);
//                [delegate onFailure:error requestKey: requestKey];
//            });
//        }else {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                @try {
////                    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
////                    NSString* responseString = [[NSString alloc] initWithData:data encoding:enc];
//                   [delegate onSuccess:data requestKey: requestKey];
//                }
//                @catch (NSException *exception) {
//                    NSLog(@" %@", [exception name]);
//                    [delegate onFailure:error requestKey: requestKey];
//                 }
//                
//            });
//        }
//    });
//    
//}


@end
