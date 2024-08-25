//
//  Discussion.m
//  西祠利器
//
//  Created by Hanning Ni on 11/22/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "Discussion.h"

@implementation Discussion

@dynamic   discussionId;
@dynamic  forumId;
@synthesize  userId;
@synthesize  content;
@synthesize  timestamp;
@synthesize  imageList;
@synthesize  replyList;
@synthesize  defaultImageUrl;

@synthesize lastUpdate;
@synthesize totalReply;
@synthesize title;
@synthesize  user;

-(id)init{
    if ( self = [super init] ){
        imageList = [[NSMutableArray alloc] initWithCapacity:2];
        replyList = [[NSMutableArray alloc] initWithCapacity:2];
    }
    return self;
}

-(NSString*)discussionId{
    return _discussionId;
}

-(void)setDiscussionId:(NSString*) discussionId{
    if ( [discussionId rangeOfString:@"d"].location == 0 )
        discussionId = [discussionId stringByReplacingOccurrencesOfString:@"d" withString:@""];
    if ( [discussionId rangeOfString:@"/d"].location == 0 )
        discussionId = [discussionId stringByReplacingOccurrencesOfString:@"/d" withString:@""];
    discussionId =  [discussionId stringByReplacingOccurrencesOfString:@"http://www.xici.net/d" withString:@""];
    
    NSRange  range  = [discussionId rangeOfString:@".htm"];
    if ( range.location != NSNotFound ){
        discussionId = [discussionId substringToIndex: range.location];
    }
    
    _discussionId = [discussionId copy];
}

-(NSString*)forumId{
    return _forumId;
}

-(void)setForumId:(NSString *)forumId{
    if ( [forumId isKindOfClass:[NSNumber class]]){
        _forumId = [[forumId description] copy];
    } else {
        forumId = [forumId stringByReplacingOccurrencesOfString:@"b" withString:@""];
        _forumId = [forumId copy];
    }
}

-(NSString*)getDiscussionUrl{
    return  [NSString stringWithFormat:@"/d%@.htm", self.discussionId];
}
@end
