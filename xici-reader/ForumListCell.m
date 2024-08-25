//
//  ForumListCell.m
//  西祠利器
//
//  Created by Hanning Ni on 11/30/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "ForumListCell.h"
#import "ForumDAO.h"
#import "DownloadNotificationObj.h"
#import "ImageBatchRequest.h"
#import "HttpService.h"
#import "Constants.h"
#import "LocalService.h"
#import "Discussion.h"

@implementation ForumListCell

@synthesize  subscribeDelegate ;
@synthesize  forum = _forum;
@synthesize  discussion = _discussion;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setupForumResultRow:(Forum*)forum delegate:(id<ForumListCellDelegate>)asubscribeDelegate{
    self.indicatorView.hidden = TRUE;
    self.subscribeDelegate = asubscribeDelegate;
    self.forum = forum;
    self.xicinail.hidden = forum.subscribed;
    self.titleLabel.text = self.forum.forumTitle;
    self.subtitleLabel.text = self.forum.summary;
    if ( forum.forumIcon ) {
       self.thumbnail.image = [UIImage imageWithData:  forum.forumIcon];
    } else {
//        DownloadNotificationObj* notif = [[DownloadNotificationObj alloc] init];
//        notif.notificationKey = kSettingReloadNotificationKey;
//        
//        ForumImage* image = [[ForumImage alloc] init];
//        image.forum = forum;
//        image.imageSourceType = ForumThumbnail;
//        image.imageUid = forum.forumId;
//        image.imageSourceLink = [Forum toForumIconUrl:forum.forumId];
//        image.title = forum.forumTitle;
//        NSMutableArray* list = [[NSMutableArray alloc] initWithCapacity:2];
//        [list addObject:image];
//        ImageBatchRequest* request = [[ImageBatchRequest alloc] initWithForumImageList:list notifcationObj:notif];
//        
//        [[HttpService sharedHttpService]  downloadImageBatch:request];
    }
}

-(void)setupTopDiscussionResultRow:(Discussion*)discussion{
    self.discussion = discussion;
    self.indicatorView.hidden = TRUE;
    self.xicinail.hidden = TRUE;
    self.titleLabel.text = self.discussion.title;
    self.subtitleLabel.text = self.discussion.content;
    if ( discussion.defaultImageData )
        self.thumbnail.image = [UIImage imageWithData: discussion.defaultImageData];
}

-(void)setupTopForumResultRow:(Forum*)forum {
    self.forum = forum;
    self.indicatorView.hidden = TRUE;
    self.xicinail.hidden = TRUE;
    self.titleLabel.text = self.forum.forumTitle;
    self.subtitleLabel.text = self.forum.summary;
    if ( forum.forumIcon )
        self.thumbnail.image = [UIImage imageWithData:  forum.forumIcon];
}

-(IBAction)subscribeClicked:(id)sender{
    if ( self.xicinail.hidden )
        return;
    self.forum.subscribed = TRUE;
    [[LocalService sharedLocalService] subscribeForum: self.forum subscribe:TRUE];
    self.infoLabel.alpha = 0;
    self.infoLabel.hidden = FALSE;
    [UIView animateWithDuration:1 animations:^{
        self.xicinail.alpha = 0;
        self.infoLabel.alpha = 1;
    } completion:^(BOOL finished) {
        self.xicinail.hidden = TRUE;
        [UIView animateWithDuration:1 animations:^{
             self.infoLabel.alpha = 0;
        } completion:^(BOOL finished) {
            self.infoLabel.hidden = TRUE;
            //if ( self.subscribeDelegate ){
                 //[self.subscribeDelegate subscribeToForum:self.forum];
           // }
         }];
    }];
    
}

@end
