//
//  FootDetail2View.h
//  西祠利器
//
//  Created by Hanning Ni on 12/2/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Forum.h"
#import "User.h"
#import "R9ImageCacheManager.h"

@interface FootDetail2View : UICollectionViewCell {
      __unsafe_unretained  id<ImageDownloaderDelegate> imageDelegate;
      CALayer *sublayer ;
}

@property (retain)   UIImageView* forumImage;
@property (retain) Forum* forum;
//@property (retain) NSMutableArray* userList;
@property (assign) id<ImageDownloaderDelegate> imageDelegate;


-(void)addUser;
//-(void)addUser:(User*)user;
//-(void)removeUser:(User*)user;


- (void)setup:(Forum*)forum numOfUser:(int)numOfUser delegate:(id<ImageDownloaderDelegate>)aimageDelegate;

@end