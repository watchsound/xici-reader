//
//  User.h
//  西祠利器
//
//  Created by Hanning Ni on 11/22/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject{
    NSString* _userId;
}

@property (retain) NSString* userId;
@property (retain) NSString* userName;
@property (assign) BOOL sex;
@property (assign) BOOL isFriend;
@property (assign) BOOL isFan;
@property (retain) NSData* userIcon;



@property (assign) BOOL isSelectedInUI;


+(NSString*)toUserIconUrl:(NSString*)userId;

@end
