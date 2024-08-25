//
//  ImageDownloaderOp.m
//  RadioOnDemand
//
//  Created by Hanning Ni on 10/6/13.
//  Copyright (c) 2013 TribuneDigitalVenture. All rights reserved.
//

#import "ImageDownloaderOp.h"

@interface ImageDownloaderOp ()
@property (nonatomic,  readwrite, strong) ForumImage *forumImage;
@property (nonatomic,  readwrite, strong) NSString*  batchId;
@end


@implementation ImageDownloaderOp

@synthesize delegate = _delegate;
@synthesize forumImage = _forumImage;
@synthesize batchId = _batchId;

#pragma mark -
#pragma mark - Life Cycle

- (id)initWithForumImage:(ForumImage *)forumImage  delegate:(id<ImageDownloaderOpDelegate>) theDelegate{
    
    if (self = [super init]) {
        self.delegate = theDelegate;
        self.forumImage = forumImage;
    }
    return self;
}

- (id)initWithForumImage:(ForumImage *)forumImage batchId:(NSString*)batchId delegate:(id<ImageDownloaderOpDelegate>) theDelegate{
    
    if (self = [super init]) {
        self.delegate = theDelegate;
        self.forumImage = forumImage;
        self.batchId = batchId;
    }
    return self;
}

-( NSString* )identifier{
    return self.forumImage.imageUid;
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
        
        if (self.isCancelled || self.forumImage.imageSourceLink == nil || self.forumImage.imageSourceLink.length == 0 )
            return;
        
        
        
        NSURL * url = [NSURL URLWithString:self.forumImage.imageSourceLink];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:   @"GET"  ];
        
        [request setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
        
        if ( [self.forumImage.imageSourceLink rangeOfString:@"http://bzpic.xici.net/"].location != NSNotFound ){
            [request setValue:@"bzpic.xici.net" forHTTPHeaderField:@"Host"];
        } else  if ( [self.forumImage.imageSourceLink rangeOfString:@"http://store.xici800.com/"].location != NSNotFound ){
                [request setValue:@"store.xici800.com" forHTTPHeaderField:@"Host"];
        } else  if ( [self.forumImage.imageSourceLink rangeOfString:@"http://xiciimgs.xici800.com/"].location != NSNotFound ){
            [request setValue:@"xiciimgs.xici800.com" forHTTPHeaderField:@"Host"];
        } else {
            [request setValue:@"pics.xici.net" forHTTPHeaderField:@"Host"];
        }
        
        
        
        
        [request setValue:@"ISO-8859-1,utf-8;q=0.7,*;q=0.3" forHTTPHeaderField:@"Accept-Charset"];
        [request setValue:@"gzip,deflate,sdch" forHTTPHeaderField:@"Accept-Encoding"];
        [request setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
        [request setValue:@"en-US,en;q=0.8" forHTTPHeaderField:@"Accept-Language"];
        [request setValue:@"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.97 Safari/537.22" forHTTPHeaderField:@"User-Agent"];
        
        NSError *error;
        
        [request setTimeoutInterval:20];
        NSURLResponse *response = nil;
     //   [[NSHTTPCookieStorage sharedHTTPCookieStorage ]cookiesForURL:url];
        NSData *imageData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
     //   NSArray* cookies =   [[NSHTTPCookieStorage sharedHTTPCookieStorage ]cookiesForURL:url];
        if(error)
        {
             NSLog(@"getimage failed %@", error);
        }
//        return data;
//        
//        NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:self.forumImage.imageSourceLink]];
//        
        if (self.isCancelled) {
             return;
        }
        if (imageData) {
          //  ForumThumbnail = 0,
           // AuthorThumbnail = 1,
            self.forumImage.imageData = imageData;
            
            if ( self.forumImage.imageSourceType == ForumThumbnail && self.forumImage.forum != nil )
                self.forumImage.forum.forumIcon = imageData;
            if ( self.forumImage.imageSourceType == AuthorThumbnail && self.forumImage.user != nil )
                self.forumImage.user.userIcon = imageData;
            if ( self.forumImage.imageSourceType == CacheOnly && self.forumImage.discussion != nil )
                self.forumImage.discussion.defaultImageData = imageData;
        }
                 
        if (self.isCancelled)
            return;
       
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(finishDownload:) withObject:self waitUntilDone:NO];
        
    }
}

@end
