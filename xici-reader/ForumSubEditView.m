//
//  ForumSubEditViewController.m
//  西祠利器
//
//  Created by Hanning Ni on 11/30/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "ForumSubEditView.h"

@interface ForumSubEditView (){
    BOOL inEditingMode;
    CALayer *sublayer;
}

@end

@implementation ForumSubEditView

@synthesize deleteDelegate = _deleteDelegate;


-(IBAction)deleteClicked:(id)sender{
    if ( inEditingMode ){
        [_deleteDelegate deleteSubscribedForum:self.forum];
    }
}

-(void)setUpForum:(Forum*)aforum delegate:(id <ForumSubEditViewDelegate>)deleteDelegate{
    self.forum = aforum;
    self.deleteDelegate = deleteDelegate;
    self.forumImage.image = [UIImage imageWithData: self.forum.forumIcon];
    if ( sublayer ){
        [sublayer removeFromSuperlayer];
    }
    sublayer = [CALayer layer];
    sublayer.backgroundColor = [UIColor blueColor].CGColor;
    sublayer.shadowOffset = CGSizeMake(0, 3);
    sublayer.shadowRadius = 5.0;
    sublayer.shadowColor = [UIColor blackColor].CGColor;
    sublayer.shadowOpacity = 0.8;
    sublayer.frame = self.forumImage.frame;
    
    sublayer.contents = (id) [UIImage imageWithData: self.forum.forumIcon].CGImage;
    sublayer.borderColor = [UIColor blackColor].CGColor;
    sublayer.borderWidth = 2.0;
    
    [self.forumImage.layer addSublayer:sublayer];
    self.titleLabel.text = self.forum.forumTitle;
}




-(void)setEditMode:(BOOL)isEditing{
    if ( inEditingMode == isEditing )
        return;
    inEditingMode = isEditing;
    if (inEditingMode){
         self.deleteImage.alpha = 0;
         self.deleteImage.hidden = FALSE;
        [UIView animateWithDuration:0.8 animations:^{
            self.forumImage.frame = CGRectMake(5, 5, self.frame.size.width - 10, self.frame.size.height - 10);
             self.deleteImage.alpha = 1;
        } completion:^(BOOL finished) {
           
        }];
    } else {
        [UIView animateWithDuration:0.8 animations:^{
            self.forumImage.frame =  CGRectMake(0,0, self.frame.size.width, self.frame.size.height);
             self.deleteImage.alpha = 0;
            self.deleteImage.hidden = TRUE;
        } completion:^(BOOL finished) {
           
        }];
    }
}

@end
