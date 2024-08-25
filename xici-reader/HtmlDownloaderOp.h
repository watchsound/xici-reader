//
//  HtmlDownloaderOp.h
//  西祠利器
//
//  Created by Hanning Ni on 11/28/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol HtmlDownloaderOpDelegate;

@interface HtmlDownloaderOp : NSOperation {
    
}

@property (nonatomic, assign) id <HtmlDownloaderOpDelegate> delegate;
@property (nonatomic, readonly, strong) NSString *url;
@property (nonatomic, readonly, strong) NSString *requestKey;
@property (nonatomic, readonly, strong) NSData*   result;
@property (nonatomic, readonly, strong) NSString *key;

- (id)initWithUrl:(NSString*)url  key:(NSString*)key   parameters:(NSData *)dict isPost:(BOOL)isPost requestKey:(NSString*)requestKey
        delegate:(id<HtmlDownloaderOpDelegate>) theDelegate;

-( NSString* )identifier;

@end

@protocol HtmlDownloaderOpDelegate <NSObject>

-(void)finishDownloadHtml:(HtmlDownloaderOp *)downloader;

@end