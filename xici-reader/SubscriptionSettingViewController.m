//
//  SubscriptionSettingViewController.m
//  西祠利器
//
//  Created by Hanning Ni on 11/30/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "SubscriptionSettingViewController.h"
#import "ForumDAO.h"
#import "ForumSubEditView.h"

@interface SubscriptionSettingViewController (){
   
}

@property (retain) NSMutableArray* forumList;

@end

@implementation SubscriptionSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupSubscriptionUI{
    self.forumList = [[ForumDAO sharedForumDAO] getSubscribedForums];
    for(UIView* view in self.subContainer.subviews ){
        [view removeFromSuperview];
    }
    int count = 0;
    
    for(Forum* forum in self.forumList){
        ForumSubEditView* view = [self loadInstanceFromNib];
        int x =  (count % 3) * (view.frame.size.width + 10);
        int y =  (count / 3) * (view.frame.size.height + 10);
        view.frame = CGRectMake(x, y, view.frame.size.width, view.frame.size.height);
        [view setUpForum:forum delegate:self];
        view.tag = count;
        [self.subContainer addSubview:view];
        count = (count +1) ;
    }
    
    self.subContainer.frame = CGRectMake(self.subContainer.frame.origin.x, self.subContainer.frame.origin.y, self.subContainer.frame.size.width, (count /3) * (110 +20) );
    
    self.view.frame = CGRectMake(0,0,  self.view.frame.size.width, self.subContainer.frame.origin.y + self.subContainer.frame.size.height + 50);
}

-(ForumSubEditView*)loadInstanceFromNib
{
    ForumSubEditView *result;
                       
    NSArray* elements = [[NSBundle mainBundle] loadNibNamed:@"ForumSubEditView" owner:nil options:nil];
    
    for (id anObject in elements) {
        if ([anObject isKindOfClass:[ForumSubEditView class]]) {
            result = anObject;
            break;
        }
    }
    
    return result;
}


-(void)deleteSubscribedForum:(Forum*)forum{
    
    
    ForumSubEditView* deleteFrame = nil;
    NSArray* viewList = self.subContainer.subviews;
    for(UIView* view in viewList ){
        ForumSubEditView* fview = (ForumSubEditView*)view;
        if( fview.forum == forum ){
            deleteFrame = fview;
            break;
        }
    }
    if ( !deleteFrame )
        return;
    int index =  [viewList indexOfObject:deleteFrame];
  //
    
   // viewList = self.subContainer.subviews;
    for( int i = index +1; i < [viewList count]; i++ ){
        UIView* view = [viewList objectAtIndex:i];
        [UIView animateWithDuration:0.8 animations:^{
            int x =  ((i-1) % 3) * (view.frame.size.width + 10);
            int y =  ((i-1) / 3) * (view.frame.size.height + 10);
            view.frame = CGRectMake(x, y, view.frame.size.width, view.frame.size.height);
        } completion:^(BOOL finished) {
            
        }];
    }
   [deleteFrame removeFromSuperview];
    [[ForumDAO sharedForumDAO] subscribeForum: forum subscribe:FALSE];
}


-(IBAction)collectionClicked:(id)sender{
    
}
-(IBAction)friendClicked:(id)sender{
    
}

-(IBAction)editClicked:(id)sender{
    self.editButton.selected = !self.editButton.selected;
     for(UIView* view in self.subContainer.subviews ){
         ForumSubEditView* fview = (ForumSubEditView*)view;
         [fview setEditMode: self.editButton.selected];
     }
}

@end
