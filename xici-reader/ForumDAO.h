//
//  ForumDAO.h
//  西祠利器
//
//  Created by Hanning Ni on 11/22/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Forum.h"
#import "User.h"
#import "Discussion.h"
#import "DiscussionReply.h"

@interface ForumDAO : NSObject

+ (instancetype)sharedForumDAO;

-(void)saveImage:(NSString*)containerId imageId:(NSString*)imageId image:(NSData*)image;
-(NSData*)getImage:(NSString*)imageId;
-(NSMutableArray*)getImageByContainerId:(NSString*)containId;

-(void)saveForum:(Forum*)forum;
-(Forum*)getForum:(NSString*)forumId;
-(NSMutableArray*)getForumByCategory:(NSString*)category isTopCategory:(BOOL)topCategory rangeStart:(int)startIndex size:(int)size;

-(void)subscribeForum:(Forum*)forum subscribe:(BOOL)subscribe;
-(NSMutableArray*)getSubscribedForums;


-(int)getSubscribedForumNum;

-(void)saveUser:(User*)user;
-(void)updateUser:(User*)user;
-(User*)getUserByName:(NSString*)name;
-(User*)getUserById:(NSString*)name;
-(NSMutableArray*)getFriends;
-(NSMutableArray*)getFans;

-(void)saveDiscussion:(Discussion*)discussion;
-(Discussion*)getDisscussion:(NSString*)discussionId;
-(void)deleteDisscussion:(NSString*)discussionId;

-(void)saveDiscussionReply:(DiscussionReply*)discussion;
-(NSMutableArray*)getDiscussionReply:(NSString*)discussionId;
-(NSMutableArray*)getDisscussions ;


@end
