//
//  SubscriptionForumSettingViewController.h
//  西祠利器
//
//  Created by Hanning Ni on 11/30/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForumListCell.h"
#import "Forum.h"
#import "CategoryHome.h"

@interface SubscriptionForumSettingViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ForumListCellDelegate>

@property (retain) IBOutlet UILabel* titleLabel;
@property (retain) IBOutlet UIImageView* oneImageView;
@property (retain) IBOutlet UIImageView* twoImageView;
@property (retain) IBOutlet UIImageView* threeImageView;
@property (retain) IBOutlet UIImageView* fourImageView;
@property (retain) IBOutlet UIImageView* fiveImageView;
@property (retain) IBOutlet UITableView* tableView;

@property (retain) NSMutableArray* forumList;
@property (retain) Forum* topForum;
@property (retain) CategoryHome* categoryHome;

-(void)setupForumList:(NSMutableArray*)forumList topForum:(Forum*)forum home:(CategoryHome*)home;

-(void)refreshUI;

@end
