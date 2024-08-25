//
//  CategoryViewController.h
//  西祠利器
//
//  Created by Hanning Ni on 11/24/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForumSearchResultViewController.h"
#import "HttpService.h"
#import "HtmlDownloaderOp.h"
#import "SettingNagivationViewController.h"


@interface CategoryViewController : UIViewController<UITextFieldDelegate, HtmlDownloaderOpDelegate, ForumSearchResultViewControllerDelegate, UIPopoverControllerDelegate>

@property (retain) IBOutlet UILabel*  userName;
@property (retain) IBOutlet UIButton*  refreshButton;
@property (retain) IBOutlet UIButton*  settingButton;
@property (retain) IBOutlet UITextField*  searchField;
@property (retain) IBOutlet UIImageView* userImage;
@property (retain) IBOutlet UIView*  headlineViewHolder;
@property (retain) IBOutlet UIView*  view1Holder;
@property (retain) IBOutlet UIView*  view2Holder;
@property (retain) IBOutlet UIView*  view3Holder;
@property (retain) IBOutlet UIView*  view4Holder;
@property (retain) IBOutlet UIView*  view5Holder;
@property (retain) IBOutlet UIView*  view6Holder;
@property (retain) IBOutlet UIView*  view7Holder;
@property (retain) UIPopoverController* searchPopoverController;
@property (retain) IBOutlet UIActivityIndicatorView*  indicatorView;


@property (nonatomic, strong) IBOutlet UIImageView* bgone;
@property (nonatomic, strong) IBOutlet UIImageView* bgtwo;

@property (retain) NSMutableArray* forumList;

-(IBAction)settingButtonClicked:(id)sender;
-(IBAction)refreshButtonClicked:(id)sender;

-(IBAction)leftButtonClicked:(id)sender;
-(IBAction)rightButtonClicked:(id)sender;
-(IBAction)footButtonClicked:(id)sender;

-(IBAction)collectClicked:(id)sender;

@end
