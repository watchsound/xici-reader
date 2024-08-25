//
//  User.m
//  西祠利器
//
//  Created by Hanning Ni on 11/22/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "User.h"

@implementation User


@dynamic  userId;
@synthesize  userName;
@synthesize  userIcon;
@synthesize sex;
@synthesize isFriend;
@synthesize isFan;

-(NSString*)userId{
    return _userId;
}

-(void)setUserId:(NSString *)userId{
    userId = [userId stringByReplacingOccurrencesOfString:@"/" withString:@""];
    userId = [userId stringByReplacingOccurrencesOfString:@"u" withString:@""];
    _userId  = [userId copy];
}

//

+(NSString*)toUserIconUrl:(NSString*)userId{
     return  [NSString stringWithFormat:@"http://icons.xici.net/u%@/files/photo_l.pic",  userId ];
}


@end
