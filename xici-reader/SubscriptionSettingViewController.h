//
//  SubscriptionSettingViewController.h
//  西祠利器
//
//  Created by Hanning Ni on 11/30/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Forum.h"
#import "ForumSubEditView.h"

@interface SubscriptionSettingViewController : UIViewController<ForumSubEditViewDelegate>

@property (retain) IBOutlet UIImageView*  userIcon;
@property (retain) IBOutlet UILabel*      userName;
@property (retain) IBOutlet UIView*       subContainer;
@property (retain) IBOutlet UIButton*     editButton;


-(IBAction)collectionClicked:(id)sender;
-(IBAction)friendClicked:(id)sender;
-(IBAction)editClicked:(id)sender;


-(void)setupSubscriptionUI;
-(void)deleteSubscribedForum:(Forum*)forum;

@end
