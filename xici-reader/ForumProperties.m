//
//  ForumProperties.m
//  西祠利器
//
//  Created by Hanning Ni on 11/25/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "ForumProperties.h"

@implementation ForumProperties

+ (instancetype)sharedForumProperties
{
    static dispatch_once_t onceToken;
    static ForumProperties * forumProperties;
    dispatch_once(&onceToken, ^{
        forumProperties = [[[self class] alloc] init];
    });
    return forumProperties;
}


-(NSString*)getUsername{
    return   [[NSUserDefaults standardUserDefaults] stringForKey:@"setUsername"];
}
-(void)setUsername:(NSString*)name{
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"setUsername"];
}

-(NSString*)getPassword{
    return   [[NSUserDefaults standardUserDefaults] stringForKey:@"setPassword"];
}
-(void)setPassword:(NSString*)password{
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"setPassword"];
}

@end
