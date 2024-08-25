//
//  DiscussionReply.h
//  西祠利器
//
//  Created by Hanning Ni on 11/22/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiscussionReply : NSObject

@property (assign) int discussionReplyId;
@property (retain) NSString* discussionId;
@property (assign) int discussionOrderNum;
@property (retain) NSString* userName;
@property (retain) NSString* content;
@property (assign) NSTimeInterval timestamp;

@end
