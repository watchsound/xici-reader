//
//  CategoryThumbnailRegularViewController.m
//  西祠利器
//
//  Created by Hanning Ni on 11/24/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "CategoryThumbnailRegularViewController.h"
#import "ReflectionView.h"
#include <stdlib.h>
#import "ForumImage.h"
#import "NSString+Util.h"
#import "XiciHomePageParser.h"
#import "Discussion.h"
#import "LocalService.h"
#import "TopMapImgItem.h"
#import "AppDelegate.h"

@interface CategoryThumbnailRegularViewController ()

@property (retain) CategoryHome* homeData;
@property (retain) NSString* imageNotificationKey;


@end

#define  kNewsBackgroundImageTag  355
#define  kNewsTitleTag  356

@implementation CategoryThumbnailRegularViewController


@synthesize highlightedStories;
@synthesize forum = _forum;
@synthesize  homeData;
@synthesize  imageNotificationKey;
@synthesize carousel = _carousel;


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
    self.highlightedStories = [[NSMutableArray alloc] initWithCapacity:2];

    [self.indicatorView startAnimating];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ( self.carousel ){
        self.carousel.delegate = self;
        self.carousel.dataSource = self;
      
    }
    if ( self.imageNotificationKey )
         [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivekImageBatchForForumPage:)
                                                 name:self.imageNotificationKey
                                               object:nil];
    
    if (  self.forum ){
        NSString*  key = [self.forum.forumId stringByAppendingString:@"kForumHtmlPage"];
         [[NSNotificationCenter defaultCenter] removeObserver:self name:key object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receivekHtmlPageDownload:)
                                                     name:  key
                                                   object:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    if ( self.carousel ){
        self.carousel.dataSource = nil;
        self.carousel.delegate = nil;
        [self.carousel stopAutoAnimation];
    }
    if (self.imageNotificationKey){
         [[NSNotificationCenter defaultCenter] removeObserver:self name:self.imageNotificationKey object:nil];
    }
     if (  self.forum ){
       
        NSString*  key = [self.forum.forumId stringByAppendingString:@"kForumHtmlPage"];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:key object:nil];
       
    }
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)thumbnailClicked:(id)sender{
    if (  self.homeData ) {
       AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
       [appDelegate.mainViewController gotoCategoryHomePage:self.homeData];
    } else if (  self.forum ){
        NSString* url = [self.forum toForumUrl];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.mainViewController gotoForumOrDiscussion:url];
    }
}

- (void) receivekImageBatchForForumPage:(NSNotification *) notification
{
    
    if (self.imageNotificationKey && [[notification name] isEqualToString:self.imageNotificationKey]){
//        if (!self.carousel ){
//            self.carousel = [[iCarousel alloc] initWithFrame:self.view.frame];
//            [self.view addSubview:self.carousel];
//        }
        [self.indicatorView stopAnimating];
        self.indicatorView.hidden = TRUE;
        int invalideImages  = 0;
        for(ForumImage * fi in self.highlightedStories){
            if ( [fi.imageData length] < 1000 ){
                invalideImages ++;
            }
        }
        if ( invalideImages == [self.highlightedStories count])
            return;
        
        self.carousel.hidden = FALSE;
        self.carousel.type =  arc4random() % 11;
        self.carousel.delegate = self;
        self.carousel.dataSource = self;
    
        [self.carousel reloadData];
        self.coverImage.hidden = TRUE;
       // [self.view bringSubviewToFront:self.carousel];
        [self.carousel  startAutoAnimation];
    }
    
}
- (void) receivekHtmlPageDownload:(NSNotification *) notification
{
    
    if ( self.forum && [[notification name] isEqualToString:[self.forum.forumId stringByAppendingString:@"kForumHtmlPage"]]){
        NSDictionary* result = notification.userInfo;
        if ( result  != nil ){
            CategoryHome* home = [result objectForKey:@"result"];
            if ( home )
                 [self populateUI:home];
        }
       
    }
    
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel{
    return 250;
}

-(void)setupUI:(Forum*)forum{
    self.forum = forum;
    self.imageNotificationKey = [@"kImageBatchForCoverPage" stringByAppendingString:forum.forumTitle];
    self.categoryLabel.text = forum.forumTitle;
    if ( forum.forumId == nil ){
         self.plusImage.image = [UIImage imageNamed:@"plus.png"];
        [self.indicatorView stopAnimating];
        self.indicatorView.hidden = TRUE;
    } else {
        self.coverImage.hidden = FALSE;
      //  if ( forum.iconLocal != nil ){
        //    self.coverImage.image = [UIImage imageNamed:forum.iconLocal];
       // } else {
            self.coverImage.image =  [UIImage imageWithData:forum.forumIcon];
       // }
      
    }
    NSString*  key = [self.forum.forumId stringByAppendingString:@"kForumHtmlPage"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:key object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivekHtmlPageDownload:)
                                                 name:  key
                                               object:nil];
    
    [[XiciHomePageParser sharedHomePageParser] downloadForum:self.forum notificationKey:key];
    
}

-(void)populateUI:(CategoryHome*)home{
    self.homeData = home;
    self.highlightedStories    = [[NSMutableArray alloc] initWithCapacity:8];
   // if ( home.category == nil ){
     //   return;
   // }
    if ( home.hotfly )
      for( Discussion* item in  home.hotfly){
        ForumImage* image = [[ForumImage alloc] init];
        image.imageUid = [ForumImage sourceLinkToUid:item.defaultImageUrl];
        image.imageSourceLink = item.defaultImageUrl;
        image.title = item.title;
        image.imageSourceType = CacheOnly;
        [self.highlightedStories addObject: image];
      }
    if ( home.topMapImageList )
        for( TopMapImgItem* item in  home.topMapImageList){
                ForumImage* image = [[ForumImage alloc] init];
                image.imageUid = item.imageUid;
                image.imageSourceLink = item.imageSourceLink;
                image.title = item.headline;
                  image.imageSourceType = CacheOnly;
                [self.highlightedStories addObject: image];
         }
    
    if ( [self.highlightedStories count] == 0 )
        return;
    DownloadNotificationObj* notif = [[DownloadNotificationObj alloc] init];
    notif.notificationKey = self.imageNotificationKey;
    
    ImageBatchRequest* request = [[ImageBatchRequest alloc] initWithForumImageList:self.highlightedStories notifcationObj:notif];
    
    [[HttpService sharedHttpService]  downloadImageBatch:request];
}

#pragma mark -
#pragma mark iCarousel methods
- (void)carouselCurrentItemIndexDidChange:(iCarousel *)_carousel{
//
//    
//    UIView* curView = carousel.currentItemView;
//    if ( curView != nil ){
//        UIImageView* imageView  =  (UIImageView *)[curView viewWithTag:kNewsBackgroundImageTag];
//        
//    }
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    
    return [self.highlightedStories count] ;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(ReflectionView *)view
{
  //  NSLog(@"carousel index = %i", index);
    UIImageView* cardBackground = nil;
 //   UILabel*  titleLabel = nil;
	if (view == nil)
	{
        //set up reflection view
		view = [[ReflectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 250.0f, 245.0f)];
        
        //set up content
        cardBackground = [[UIImageView alloc] initWithFrame:view.bounds];
        cardBackground.tag = kNewsBackgroundImageTag;
        [view addSubview:cardBackground];
        
//        titleLabel = [[UILabel alloc] initWithFrame:view.bounds];
//        titleLabel.tag = kNewsTitleTag;
//      
//        [view addSubview:titleLabel];
        
	}
	else
	{
		cardBackground = (UIImageView *)[view viewWithTag:kNewsBackgroundImageTag];
    //    titleLabel = (UILabel *)[view viewWithTag:kNewsTitleTag];
	}
    ForumImage* newsImage  = [self.highlightedStories objectAtIndex:index];
    cardBackground.image = [UIImage imageWithData:newsImage.imageData];
    if ( cardBackground.image == nil )
        NSLog(@"!!!");
    self.titleLabel.text = newsImage.title;
    //update reflection
    //this step is expensive, so if you don't need
    //unique reflections for each item, don't do this
    //and you'll get much smoother peformance
    [view update];
	
	return view;
}





@end
