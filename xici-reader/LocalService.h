//
//  LocalService.h
//  西祠利器
//
//  Created by Hanning Ni on 11/23/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ForumDAO.h"
#import "ForumImage.h"

@interface LocalService : NSObject

+ (instancetype)sharedLocalService;
-(void)populateInitialData;
-(NSMutableArray*)getDefaultCateogryList;

-(void)saveImage:(ForumImage*)forumImage;
-(void)saveImage:(NSString*)containerId imageId:(NSString*)imageId image:(NSData*)image;
-(void)saveImageToCache:(NSString*)imageName  image:(NSData*)image;
-(NSData*)getImage:(NSString*)imageId;
-(NSData*)getImageFromDB:(NSString*)imageId;
-(NSData*)getImageFromCache:(NSString*)imageId;
-(NSData*)getImageFromBundle:(NSString*)imageId;

-(Discussion*)getDisscussion:(NSString*)discussionId;

-(void)subscribeForum:(Forum*)forum subscribe:(BOOL)subscribe;


+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)path;
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;


-(void)saveUser:(User*)user;
-(void)saveOnlyNewUser:(User*)auser;
    
@end
