//
//  R9ImageCacheManager.h
//  r9
//
//  Created by Xianglong Ni on 1/22/13.
//  Copyright (c) 2013 Hanning. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ImageDownloaderDelegate;

@interface R9ImageCacheManager : NSObject{
    NSCache* nscache;
}

+ (instancetype)sharedImageService;

- (UIImage*)getImageFromLocalCache:(NSString*)imageUID;
- (UIImage*)fetchImage:(NSString*)imageUID delegate:(id<ImageDownloaderDelegate>)delegate;


@end

@protocol ImageDownloaderDelegate

- (void)imageDidLoad:(NSString*)imageUID :(UIImage*)image;

@end
