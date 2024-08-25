//
//  CategoryHomeViewController.h
//  西祠利器
//
//  Created by Hanning Ni on 12/1/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "CategoryHome.h"

@interface CategoryHomeViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,iCarouselDataSource, iCarouselDelegate>

@property (retain) IBOutlet  iCarousel*  carousel;
@property (retain) IBOutlet  UILabel*  mainTitleLabel;
@property (retain) IBOutlet  UIView*   container1;
@property (retain) IBOutlet  UIImageView*  imageView1;
@property (retain) IBOutlet  UILabel*  title1;

@property (retain) IBOutlet  UIView*   container2;
@property (retain) IBOutlet  UIImageView*  imageView2;
@property (retain) IBOutlet  UILabel*  title2;

@property (retain) IBOutlet  UIView*   container3;
@property (retain) IBOutlet  UIImageView*  imageView3;
@property (retain) IBOutlet  UILabel*  title3;

@property (retain) IBOutlet  UIView*   container4;
@property (retain) IBOutlet  UIImageView*  imageView4;
@property (retain) IBOutlet  UILabel*  title4;

@property (retain) IBOutlet  UIView*   container5;
@property (retain) IBOutlet  UIImageView*  imageView5;
@property (retain) IBOutlet  UILabel*  title5;

@property (retain) IBOutlet  UIView*   container6;
@property (retain) IBOutlet  UIImageView*  imageView6;
@property (retain) IBOutlet  UILabel*  title6;

@property (retain) IBOutlet  UITableView*  tableViewtop;
@property (retain) IBOutlet  UITableView*  tableView;

@property (retain) CategoryHome*  categoryHome;

@property (nonatomic, strong) IBOutlet UIImageView* bgone;
@property (nonatomic, strong) IBOutlet UIImageView* bgtwo;

-(IBAction)container1Clicked:(id)sender;
-(IBAction)container2Clicked:(id)sender;
-(IBAction)container3Clicked:(id)sender;
-(IBAction)container4Clicked:(id)sender;
-(IBAction)container5Clicked:(id)sender;
-(IBAction)container6Clicked:(id)sender;


-(IBAction)footstepClicked:(id)sender;
-(IBAction)collectionClicked:(id)sender;


-(void)setupUI:(CategoryHome*)categoryHome;


@end
