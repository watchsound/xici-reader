//
//  CategoryThumbnailRegularViewController.h
//  西祠利器
//
//  Created by Hanning Ni on 11/24/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "Forum.h"
#import "HttpService.h"  

@interface CategoryThumbnailRegularViewController : UIViewController<iCarouselDataSource, iCarouselDelegate>


@property (retain) IBOutlet UILabel* titleLabel;
@property (retain) IBOutlet UILabel* categoryLabel;
@property (retain) IBOutlet UIImageView * coverImage;
@property (retain) IBOutlet UIImageView* plusImage;
@property (retain) IBOutlet UIActivityIndicatorView*  indicatorView;
@property (nonatomic, strong)  IBOutlet iCarousel *carousel;
@property (retain) NSMutableArray* highlightedStories;
@property (retain) Forum* forum;


-(IBAction)thumbnailClicked:(id)sender;

-(void)setupUI:(Forum*)forum;

@end
