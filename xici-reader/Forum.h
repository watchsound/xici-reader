//
//  Forum.h
//  西祠利器
//
//  Created by Hanning Ni on 11/22/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Forum : NSObject {
    NSString* _forumId;
}

 
@property (copy) NSString* forumId;
@property (retain) NSString* forumTitle;
@property (retain) NSString* category;
@property (retain) NSString* subcategory;
@property (retain) NSData* forumIcon;
@property (assign) BOOL subscribed;
@property (retain) NSString* iconLocal;
@property (assign) BOOL topForum;


@property (retain) NSString* tagList;
@property (assign) int  popularity;
@property (assign) int  activity;
@property (retain) NSString* thumbnailUrl;
@property (retain) NSString* summary;

-(NSString*)toForumUrl;
+(NSString*)toForumIconUrl:(NSString*)forumId;

@end
