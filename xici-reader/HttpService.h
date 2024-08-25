//
//  HttpService.h
//  西祠利器
//
//  Created by Hanning Ni on 11/22/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageDownloaderOp.h"
#import "ImageBatchRequest.h"
#import "HtmlDownloaderOp.h"

@protocol HttpAsyncRequestDelegate <NSObject>

- (void) onSuccess:(NSData*)result requestKey:(NSString*)requestKey;
- (void) onFailure:(NSError*)result requestKey:(NSString*)requestKey;

@end

@interface HttpService : NSObject<ImageDownloaderOpDelegate>


+ (instancetype)sharedHttpService;

-(NSData*)getHtmlData:(NSString*)url;

//- (void)sendHttpAsyncRequest:(id<HttpAsyncRequestDelegate>)delegate withUrl:(NSString*)url
//                  parameters:(NSData *)dict isPost:(BOOL)isPost requestKey:(NSString*)requestKey needWaitingIndicator:(BOOL)needWaitingIndicator;


- (void)downloadImage:(ForumImage*)image;
- (void)downloadImageBatch:(ImageBatchRequest*)imageBatch;
-(void)downloadWithUrl:(NSString*)url  key:(NSString*)key  parameters:(NSData *)dict isPost:(BOOL)isPost requestKey:(NSString*)requestKey    delegate:(id<HtmlDownloaderOpDelegate>) theDelegate;

#pragma ImageDownloaderOpDelegate <NSObject>
- (void)finishDownload:(ImageDownloaderOp *)downloader;

@end
