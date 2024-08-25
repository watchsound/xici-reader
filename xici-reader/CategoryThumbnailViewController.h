//
//  CategoryThumbnailViewController.h
//  西祠利器
//
//  Created by Hanning Ni on 11/24/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JBKenBurnsView.h"


@interface CategoryThumbnailViewController : UIViewController<JBKenBurnsViewDelegate>

@property (retain) IBOutlet UILabel* sourceLabel;
@property (retain) IBOutlet UILabel* titleLabel;
@property (retain) IBOutlet UILabel* title2Label;
@property (retain) IBOutlet UILabel* categoryLabel;
@property (retain) IBOutlet UIImageView * coverImage;
@property (retain) IBOutlet UIActivityIndicatorView*  indicatorView;
@property (retain) IBOutlet JBKenBurnsView* kbImageView;



@end
