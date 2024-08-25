//
//  ForumImage.m
//  西祠利器
//
//  Created by Hanning Ni on 11/22/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "ForumImage.h"

@implementation ForumImage 

@synthesize  imageUid;
@synthesize  imageSourceLink;
@synthesize  sourceUid;
@synthesize  imageData;
@synthesize  title;
@synthesize  imageSourceType;

@synthesize forum;
@synthesize user;

+(NSString*)sourceLinkToUid:(NSString*)imageSourceLink{
    imageSourceLink = [imageSourceLink stringByReplacingOccurrencesOfString:@":" withString:@"_" ];
    return [imageSourceLink stringByReplacingOccurrencesOfString:@"/" withString:@"_" ];
    
}


@end
