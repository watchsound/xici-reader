//
//  FootDetail2View.m
//  西祠利器
//
//  Created by Hanning Ni on 12/2/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "FootDetail2View.h"
#include <stdlib.h>
#import "R9ImageCacheManager.h"
#import "ForumDAO.h"
#import "LocalService.h"

@implementation FootDetail2View


- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    
    self.forumImage = [[UIImageView alloc] initWithFrame:CGRectInset(CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame)), 5, 5)];
    self.forumImage.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:self.forumImage];
    
    self.backgroundColor = [UIColor whiteColor];
    
    return self;
}

-(void)prepareForReuse
{
    [self setImage:nil];
}

-(void)setImage:(UIImage *)image
{
    self.forumImage.image = image;
}


- (void)setup:(Forum*)aforum numOfUser:(int)numOfUser delegate:(id<ImageDownloaderDelegate>)aimageDelegate;
{
   // [super wakeFromNib];
   // self.userList = [[NSMutableArray alloc] initWithCapacity:2];
//    UIView* view = [self viewWithTag:12345] ;
//    while (view != nil){
//        [view removeFromSuperview];
//        view = [self viewWithTag:12345] ;
//    };
    for(UIView*  view in [self subviews]){
        [view removeFromSuperview];
    }
    if (! self.forumImage ){
        self.forumImage = [[UIImageView alloc] initWithFrame:self.frame];
    }
    [self addSubview:self.forumImage];
    self.forumImage.hidden =  numOfUser == 0;
    
    self.forum = aforum;
    self.imageDelegate = aimageDelegate;
    
    for(int i = 0; i <numOfUser; i++){
        [self addUser];
    }
    
    self.forum.thumbnailUrl = [Forum toForumIconUrl:self.forum.forumId];
     NSData * data = [[LocalService sharedLocalService] getImageFromCache:[ForumImage sourceLinkToUid:self.forum.thumbnailUrl]];
    if ( data )
        self.forumImage.image = [UIImage imageWithData:data];
    
    if ( !self.forumImage.image ) {
         Forum* f = [[ForumDAO sharedForumDAO] getForum:self.forum.forumId];
        if ( f  && f.forumIcon ){
            self.forumImage.image = [UIImage imageWithData:f.forumIcon];
        } else {
          //  [[R9ImageCacheManager sharedImageService] fetchImage:aforum.thumbnailUrl delegate:self.imageDelegate];
        }
    }
    
    if ( self.forumImage.image ){
        if ( sublayer ){
            [sublayer removeFromSuperlayer];
        }
        sublayer = [CALayer layer];
        sublayer.backgroundColor = [UIColor blueColor].CGColor;
        sublayer.shadowOffset = CGSizeMake(0, 3);
        sublayer.shadowRadius = 5.0;
        sublayer.shadowColor = [UIColor blackColor].CGColor;
        sublayer.shadowOpacity = 0.8;
        sublayer.frame = self.frame;
        
        sublayer.contents = (id) self.forumImage.image.CGImage;
        sublayer.borderColor = [UIColor blackColor].CGColor;
        sublayer.borderWidth = 2.0;
        
        [self.layer addSublayer:sublayer];
    }
}



-(void)addUser {
   // [self.userList addObject:user];
    int random =  arc4random() % 100;
    float randomValue =  random / 100.0;
    
    float x = self.frame.size.width * randomValue;
    if ( x > self.frame.size.width * 8 / 10 )
        x = self.frame.size.width * 8 / 10;
    random =  arc4random() % 100;
    randomValue =  random / 100.0;
    
    float y = self.frame.size.height * randomValue;
    if ( y > self.frame.size.height * 8 / 10 )
        y = self.frame.size.height * 8 / 10;
    
    random =  arc4random() % 100;
    randomValue =  random / 100.0;
    
    UIImage *image = [UIImage imageNamed:@"footprint.png"];
    UIImageView *imageView = [ [ UIImageView alloc ] initWithFrame:CGRectMake(x, y, image.size.width, image.size.height) ];
    imageView.image = image;
    imageView.tag = 12345;
    CGAffineTransform rotate = CGAffineTransformMakeRotation( 1.0 / 180.0 * 3.14 * randomValue);
    [imageView setTransform:rotate];
    [self  addSubview:imageView];
   
}

//-(void)removeUser:(User*)user{
//    for (int i = [self.userList count] -1; i >=0; i -- ){
//        if ([self.userList objectAtIndex:i] == user) {
//            [self.userList removeObjectAtIndex:i];
//            UIView* view = [self viewWithTag:12345];
//            [view removeFromSuperview];
//        }
//    }
//}



@end


