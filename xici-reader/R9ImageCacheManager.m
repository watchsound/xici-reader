//
//  R9ImageCacheManager.m
//  r9
//
//  Created by Xianglong Ni on 1/22/13.
//  Copyright (c) 2013 Hanning. All rights reserved.
//

#import "R9ImageCacheManager.h"

#import "ForumImage.h"


@interface R9ImageCacheManager () 
@end

@implementation R9ImageCacheManager


+ (instancetype)sharedImageService
{
    static dispatch_once_t onceToken;
    static R9ImageCacheManager * imageService;
    dispatch_once(&onceToken, ^{
        imageService = [[[self class] alloc] init];
        [imageService oneTimeInit];
    });
    return imageService;
}

- (void)oneTimeInit {
    nscache = [[NSCache alloc] init];
    [nscache setCountLimit:100];
} 

- (UIImage*)getImageFromLocalCache:(NSString*)imageUID{
     NSString*  localID = [ForumImage sourceLinkToUid:imageUID];
     return [nscache objectForKey:localID];
}

- (UIImage*)fetchImage:(NSString*)imageUID delegate:(id<ImageDownloaderDelegate>)delegate{
    NSString*  localID = [ForumImage sourceLinkToUid:imageUID];
    UIImage* image =  [nscache objectForKey:localID];
    if ( image ){
        return image;
    }
    NSString* imageUrl = imageUID;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        
        NSError *error;
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:imageUrl]];
        UIImage* image = [[UIImage alloc] initWithData: imageData];
        if ( error != nil || image == nil){
            NSLog(@"image download issue for %@", imageUID);
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                 [nscache setObject:image forKey:localID];
                [delegate imageDidLoad:imageUID  :image];
            });
        }
    });
    
    return nil;
}


@end
