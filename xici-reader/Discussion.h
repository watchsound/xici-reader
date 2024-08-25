//
//  Discussion.h
//  西祠利器
//
//  Created by Hanning Ni on 11/22/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Discussion : NSObject {
     NSString* _discussionId;
     NSString* _forumId;
}

@property (copy) NSString* discussionId;
@property (copy) NSString* forumId;
@property (copy) NSString* userId;
@property (retain) NSString* content;
@property (assign) NSTimeInterval timestamp;

@property (assign) NSTimeInterval lastUpdate;
@property (assign) int totalReply;
@property (retain) NSString* title;

@property (retain) NSString* defaultImageUrl;

@property (retain) NSMutableArray* imageList;
@property (retain) NSMutableArray* replyList;

@property (retain) NSData* defaultImageData;

@property (retain) User* user;
 
-(NSString*)getDiscussionUrl;

@end
