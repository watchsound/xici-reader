//
//  ForumImage.h
//  西祠利器
//
//  Created by Hanning Ni on 11/22/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Forum.h"
#import "User.h"
#import "Discussion.h"

typedef enum {
    ForumThumbnail = 0,
    AuthorThumbnail = 1,
    SavedOtherType = 2,
    CacheOnly = 3
} ImageSourceType;


@interface ForumImage : NSObject

@property (retain) NSString* imageUid;
@property (retain) NSString* imageSourceLink;
@property (retain) NSString* sourceUid;
@property (retain) NSString* title;
@property (assign) ImageSourceType  imageSourceType;

@property (retain) NSData*  imageData;


//not good design... change later
@property  (retain)  Forum* forum;
@property  (retain)  Discussion* discussion;
@property  (retain) User* user;


+(NSString*)sourceLinkToUid:(NSString*)imageSourceLink;

@end
