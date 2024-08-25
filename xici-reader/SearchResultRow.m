//
//  SearchResultRow.m
//  西祠利器
//
//  Created by Hanning Ni on 11/29/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "SearchResultRow.h"
#import <math.h>

@implementation SearchResultRow

@synthesize  thumbnailView;
@synthesize  tagListLabel;
@synthesize  descriptionLabel;
@synthesize  titleLabel;
@synthesize  popularLabel;
@synthesize  activityLabel;
@synthesize  forum = _forum;
@synthesize  imageDelegate  ;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setupSearchResultRow:(Forum*)forum delegate:(id<ImageDownloaderDelegate>)_imageDelegate{
    self.imageDelegate = _imageDelegate;
    self.forum = forum;
    self.tagListLabel.text = forum.tagList;
    self.titleLabel.text = forum.forumTitle;
    self.descriptionLabel.text = forum.summary;
    self.popularLabel.color = [UIColor greenColor];
    self.popularLabel.degree = log10( forum.popularity );
    self.activityLabel.color = [UIColor redColor];
    self.activityLabel.degree = log10( forum.activity );
    
    self.forum.thumbnailUrl = [Forum toForumIconUrl:self.forum.forumId];
    
    self.thumbnailView.image = [[R9ImageCacheManager sharedImageService] getImageFromLocalCache:forum.thumbnailUrl];
    
    if ( !self.thumbnailView.image )
        [[R9ImageCacheManager sharedImageService] fetchImage:forum.thumbnailUrl delegate:self.imageDelegate];
}

@end
