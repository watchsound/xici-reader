//
//  ImageService.h
//  西祠利器
//
//  Created by Hanning Ni on 11/22/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageService : NSObject

+ (instancetype)sharedImageService;


-(UIImage*) makeImageFromView:(UIView*)view;

-(UIImage*)resizeImage:(UIImage*)oldImage width:(int)width;
-(UIImage*)resizeImage:(UIImage*)oldImage width:(int)width height:(int)height;
-(UIImage*)cropImage:(UIImage*)oldImage width:(int)width height:(int)height;

-(UIImage*) makeBlurImageFromView:(UIView*)view degree:(float)degree;
-(UIImage*) blur:(UIImage*)theImage  degree:(float)degree;
 

@end
