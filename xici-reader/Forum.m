//
//  Forum.m
//  西祠利器
//
//  Created by Hanning Ni on 11/22/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "Forum.h"

@implementation Forum

@dynamic forumId;
 
@synthesize   forumTitle;
@synthesize   category;
@synthesize   subcategory;
@synthesize   forumIcon;
@synthesize   subscribed;
@synthesize   iconLocal;
@synthesize   topForum;
@synthesize  summary;


@synthesize tagList;
@synthesize popularity;
@synthesize activity;
@synthesize thumbnailUrl;

-(NSString*)forumId{
    return _forumId;
}

-(void)setForumId:(NSString *)forumId{
    if ( self.topForum ){
        _forumId = [forumId copy];
        return;
    }
        
     forumId = [forumId stringByReplacingOccurrencesOfString:@"http://www.xici.net/" withString:@""];
     forumId = [forumId stringByReplacingOccurrencesOfString:@"b" withString:@""];
     forumId = [forumId stringByReplacingOccurrencesOfString:@"/" withString:@""];
    _forumId = [forumId copy];
}

-(NSString*)toForumUrl{
      if ( self.topForum )
          return _forumId;
     return  [@"http://www.xici.net/b" stringByAppendingString:_forumId];
}

+(NSString*)toForumIconUrl:(NSString*)forumId{
     return  [NSString stringWithFormat:@"http://xiciimgs.xici800.com/board_%@.jpg",  forumId ];
}



@end
