//
//  ForumListCell.h
//  西祠利器
//
//  Created by Hanning Ni on 11/30/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Forum.h"
#import "Discussion.h"

@protocol ForumListCellDelegate

- (void)subscribeToForum:(Forum*)forum;

@end

@interface ForumListCell :  UITableViewCell{
    __unsafe_unretained  id<ForumListCellDelegate> subscribeDelegate;
}


@property (retain) IBOutlet UIImageView* thumbnail;
@property (retain) IBOutlet UIImageView*  xicinail;
@property (retain) IBOutlet UILabel*    titleLabel;
@property (retain) IBOutlet UILabel*    subtitleLabel;
@property (retain) IBOutlet UIButton*   subscribeButton;
@property (retain) IBOutlet UILabel*    infoLabel;
@property (assign) id<ForumListCellDelegate> subscribeDelegate;
@property (retain) IBOutlet UIActivityIndicatorView*  indicatorView;

@property (retain) Forum* forum;
@property (retain) Discussion* discussion;

-(void)setupForumResultRow:(Forum*)forum delegate:(id<ForumListCellDelegate>)subscribeDelegate;
-(void)setupTopForumResultRow:(Forum*)forum;
-(void)setupTopDiscussionResultRow:(Discussion*)discussion;

-(IBAction)subscribeClicked:(id)sender;




@end
