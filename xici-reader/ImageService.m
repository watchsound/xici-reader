//
//  ImageService.m
//  西祠利器
//
//  Created by Hanning Ni on 11/22/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "ImageService.h"

@implementation ImageService

+ (instancetype)sharedImageService
{
    static dispatch_once_t onceToken;
    static ImageService * imageService;
    dispatch_once(&onceToken, ^{
        imageService = [[[self class] alloc] init];
    });
    return imageService;
}

-(UIImage*)resizeImage:(UIImage*)oldImage width:(int)width{
    UIImage *newImage;
    int height = oldImage.size.height * width/ oldImage.size.width;
    UIGraphicsBeginImageContext(CGSizeMake(width,height));
    [oldImage drawInRect:CGRectMake(0, 0,width,height)];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage*)resizeImage:(UIImage*)oldImage width:(int)width height:(int)height{
    float ratioForOldImage = oldImage.size.width / oldImage.size.height;
    float ratioForNewImage = width * 1.0 / height;
    if( ratioForOldImage > ratioForNewImage ){
        float  newHeight = oldImage.size.height;
        float  newWidth = newHeight * ratioForNewImage;
        UIImage* image = [self cropImage:oldImage width:newWidth height:newHeight];
        return [self resizeImage:image width:width];
    } else {
        float  newWidth =  oldImage.size.width;
        float  newHeight = newWidth / ratioForNewImage;
        UIImage* image = [self cropImage:oldImage width:newWidth height:newHeight];
        return [self resizeImage:image width:width];
    }
}

//
-(UIImage*)cropImage:(UIImage*)oldImage width:(int)width height:(int)height{
    // Get size of current image
    CGSize size = [oldImage size];
    if ( size.width < width && size.height < height)
        return oldImage;
    
    // Create rectangle that represents a cropped image
    // from the middle of the existing image
    CGFloat x =  ( size.width - width ) /2;
    CGFloat y =  ( size.height - height ) / 2;
    if ( x < 0 ) x = 0;
    if ( y < 0 ) y = 0;
    CGFloat w =  size.width > width ? width : size.width;
    CGFloat h =  size.height > height ? height : size.height;
    
    CGRect rect = CGRectMake(x, y, w, h);
    
    // Create bitmap image from original image data,
    // using rectangle to specify desired crop area
    CGImageRef imageRef = CGImageCreateWithImageInRect([oldImage CGImage], rect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return img;
}



-(UIImage*) makeBlurImageFromView:(UIView*)view degree:(float)degree{
    UIImage* image = [self makeImageFromView:view];
    return [self blur:image degree:degree];
}

-(UIImage*) makeImageFromView:(UIView*)view {
    
    UIGraphicsBeginImageContext( view.bounds.size);
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return viewImage;
}


// you could use CIGaussianBlur from Core Image (requires iOS 6).
- (UIImage*) blur:(UIImage*)theImage  degree:(float)degree
{
    // create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:degree] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    return [UIImage imageWithCGImage:cgImage];
    
}

 

@end
