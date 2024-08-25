//
//  CategoryThumbnailViewController.m
//  西祠利器
//
//  Created by Hanning Ni on 11/24/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "CategoryThumbnailViewController.h"
#import "TopMapImgItem.h"
#import "XiciHomePageParser.h"
#import "LocalService.h"

@interface CategoryThumbnailViewController ()

@property (retain) NSMutableArray* imageList;

@end

@implementation CategoryThumbnailViewController

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
    [self showKBImageAnimation];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   
    self.kbImageView.delegate = self;
    
}

- (void)viewWillDisappear:(BOOL)animated{
    self.kbImageView.delegate = nil;
   [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showKBImageAnimation{
    if ( self.imageList == nil )
        self.imageList = [[NSMutableArray alloc] initWithCapacity:4];
    else
        [self.imageList removeAllObjects];
    for(TopMapImgItem* item in [XiciHomePageParser  sharedHomePageParser].topMapImageList ){
        NSData* data = [[LocalService sharedLocalService] getImageFromCache:item.imageUid];
        if (data == nil)
            continue;
        UIImage* image = [UIImage imageWithData:data];
        if ( image != nil )
            [self.imageList addObject: image];
    }
    
    if ( [self.imageList count] == 0)
        return;
    if ( [self.imageList count] == 1 ){
        [self.imageList addObject:[self.imageList objectAtIndex:0]];
    }
    
    //shift images
    //  UIImage* firstImage = [imageList objectAtIndex:0];
    //   [imageList removeObjectAtIndex:0];
    //  [imageList addObject:firstImage];
    BOOL isLandscape =  [UIDevice currentDevice].orientation != UIDeviceOrientationPortrait &&
    [UIDevice currentDevice].orientation != UIInterfaceOrientationPortraitUpsideDown;
    [self.kbImageView animateWithImages:self.imageList
                transitionDuration:3
                              loop:YES
                       isLandscape:isLandscape];
}

- (void)didShowImageAtIndex:(NSUInteger)index{
   NSMutableArray* list = [XiciHomePageParser  sharedHomePageParser].topMapImageList;
    if ( index >= [list count] )
        return;
    TopMapImgItem* item = [list objectAtIndex:index];
    self.titleLabel.text = item.headline;
}

@end
