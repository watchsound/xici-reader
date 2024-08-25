//
//  ForumProperties.h
//  西祠利器
//
//  Created by Hanning Ni on 11/25/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ForumProperties : NSObject


+ (instancetype)sharedForumProperties;


-(NSString*)getUsername;
-(void)setUsername:(NSString*)name;
 

-(NSString*)getPassword;
-(void)setPassword:(NSString*)password;

@end
