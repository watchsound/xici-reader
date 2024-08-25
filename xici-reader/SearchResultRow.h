//
//  SearchResultRow.h
//  西祠利器
//
//  Created by Hanning Ni on 11/29/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DegreeIndicatorView.h"
#import "Forum.h"
#import "R9ImageCacheManager.h"

@interface SearchResultRow : UITableViewCell{
      __unsafe_unretained  id<ImageDownloaderDelegate> imageDelegate;
}

@property (retain) IBOutlet UIImageView*  thumbnailView;
@property (retain) IBOutlet UILabel* tagListLabel;
@property (retain) IBOutlet UILabel* descriptionLabel;
@property (retain) IBOutlet UILabel* titleLabel;
@property (retain) IBOutlet DegreeIndicatorView* popularLabel;
@property (retain) IBOutlet DegreeIndicatorView* activityLabel;
@property (assign) id<ImageDownloaderDelegate> imageDelegate;

@property (retain) Forum* forum;

-(void)setupSearchResultRow:(Forum*)forum delegate:(id<ImageDownloaderDelegate>)imageDelegate;


@end
