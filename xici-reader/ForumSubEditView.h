//
//  ForumSubEditViewController.h
//  西祠利器
//
//  Created by Hanning Ni on 11/30/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Forum.h"


@protocol ForumSubEditViewDelegate <NSObject>

 -(void)deleteSubscribedForum:(Forum*)forum;

@end

@interface ForumSubEditView : UIView

@property (retain) IBOutlet UIImageView* forumImage;
@property (retain) IBOutlet UIImageView* deleteImage;
@property (retain) IBOutlet UILabel*     titleLabel;
@property (retain) Forum* forum;

@property (assign) id <ForumSubEditViewDelegate>   deleteDelegate;

-(IBAction)deleteClicked:(id)sender;

-(void)setUpForum:(Forum*)forum delegate:(id <ForumSubEditViewDelegate>)deleteDelegate;
-(void)setEditMode:(BOOL)isEditing;

@end
