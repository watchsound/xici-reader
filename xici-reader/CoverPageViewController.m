//
//  CoverPageViewController.m
//  西祠利器
//
//  Created by Hanning Ni on 11/21/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "CoverPageViewController.h"
#import "XiciHomePageParser.h"
#import "TopMapImgItem.h"
#import "LocalService.h"
#import "ForumImage.h"
#import "DownloadNotificationObj.h"
#import "ImageBatchRequest.h"
#import "HttpService.h"
#import "DDSocialLoginDialog.h"
#import "XiciDriver.h"
#import "ForumProperties.h"
#import "AppDelegate.h"

@interface CoverPageViewController (){
     UIDeviceOrientation _deviceOrientation;
}

@property (retain) NSMutableArray* coverImageList;
@property (retain) NSMutableArray* imageList;

@end

@implementation CoverPageViewController

@synthesize kbImageView;
@synthesize  imageList;

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
   
   
    [[XiciHomePageParser sharedHomePageParser] loadXiciHomePage];
     NSMutableArray* images  = [[XiciHomePageParser sharedHomePageParser] extractTopMapImageItemsForHomePage];
    self.coverImageList    = [[NSMutableArray alloc] initWithCapacity:8];
    for( TopMapImgItem* item in  images){
        ForumImage* image = [[ForumImage alloc] init];
        image.imageUid = item.imageUid;
        image.imageSourceLink = item.imageSourceLink;
        image.title = item.headline;
        image.imageUid = item.imageUid;
        image.imageSourceType = CacheOnly;
        [self.coverImageList addObject: image];
    }
    DownloadNotificationObj* notif = [[DownloadNotificationObj alloc] init];
    notif.notificationKey = kImageBatchForCoverPage;
    
    ImageBatchRequest* request = [[ImageBatchRequest alloc] initWithForumImageList:self.coverImageList notifcationObj:notif];
    
    [[HttpService sharedHttpService]  downloadImageBatch:request];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kImageBatchForCoverPage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveImageBatchForCoverPage:)
                                                 name:kImageBatchForCoverPage
                                               object:nil];
   
}

- (void)viewWillAppear:(BOOL)animated{
     [super viewWillAppear:animated];
    _deviceOrientation = [UIDevice currentDevice].orientation;
     [[NSNotificationCenter defaultCenter] removeObserver:self name:kImageBatchForCoverPage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveImageBatchForCoverPage:)
                                                 name:kImageBatchForCoverPage
                                               object:nil];

     kbImageView.delegate = self;
     [self showKBImageAnimation];
}
- (void)viewWillDisappear:(BOOL)animated{
     kbImageView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kImageBatchForCoverPage object:nil];
    [super viewWillDisappear:animated];
}


-(void)addObservers
{
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    
//    [[NSNotificationCenter defaultCenter]
//     addObserver:self
//     selector:@selector(deviceOrientationDidChange:)
//     name:@"UIDeviceOrientationDidChangeNotification"
//     object:nil];
    
    
    
    
    
}
-(void)deviceOrientationDidChange:(NSNotification*)notification
{
	_deviceOrientation = [UIDevice currentDevice].orientation;
    BOOL isLandscape =  _deviceOrientation != UIDeviceOrientationPortrait &&
    _deviceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    if ( self.imageList != nil && [self.imageList count] > 0 ){
        [kbImageView animateWithImages:imageList
                    transitionDuration:5
                                  loop:YES
                           isLandscape:isLandscape];
    }
}


- (void) receiveImageBatchForCoverPage:(NSNotification *) notification
{
    
    if ([[notification name] isEqualToString:kImageBatchForCoverPage]){
        [self showKBImageAnimation];
    }
    
}


-(void)showKBImageAnimation{
    if ( self.imageList == nil )
        self.imageList = [[NSMutableArray alloc] initWithCapacity:4];
    else
        [self.imageList removeAllObjects];
    for(ForumImage* item in self.coverImageList){
        NSData* data = [[LocalService sharedLocalService] getImageFromCache:item.imageUid];
        if (data == nil)
            continue;
        UIImage* image = [UIImage imageWithData:data];
        if ( image != nil )
            [imageList addObject: image];
    }
    
    if ( [imageList count] == 0)
        return;
    if ( [imageList count] == 1 ){
        [imageList addObject:[imageList objectAtIndex:0]];
    }
    
    //shift images
  //  UIImage* firstImage = [imageList objectAtIndex:0];
 //   [imageList removeObjectAtIndex:0];
  //  [imageList addObject:firstImage];
    BOOL isLandscape =  _deviceOrientation != UIDeviceOrientationPortrait &&
    _deviceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    [kbImageView animateWithImages:imageList
                transitionDuration:5
                              loop:YES
                       isLandscape:isLandscape];
}


#pragma - KenBurnsViewDelegate 
- (void)didShowImageAtIndex:(NSUInteger)index{
    if ( index >= [ self.coverImageList count] )
        return;
    ForumImage* item = [self.coverImageList objectAtIndex:index];
    self.titleLabel.text = item.title;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)leftButtonClicked:(id)sender{
     AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mainViewController gotoNextPage];
}

-(IBAction)loginButtonClicked:(id)sender{
     NSString* username =   [[ForumProperties sharedForumProperties] getUsername];
    DDSocialLoginDialog *loginDialog = [[DDSocialLoginDialog alloc] initWithDelegate:self theme:DDSocialDialogThemeTwitter username:username];
    loginDialog.delegate = self;
    
    [loginDialog show];
}

#pragma mark DDSocialLoginDialogDelegate (Required)
- (void)socialDialogDidSucceed:(DDSocialLoginDialog *)socialLoginDialog {
	NSString *username = socialLoginDialog.username;
	NSString *password = socialLoginDialog.password;
	[[ForumProperties sharedForumProperties] setUsername:username];
     [[ForumProperties sharedForumProperties] setPassword:password];
    BOOL success = [[XiciDriver sharedXiciDriver] loginXici:username :password];
    if ( success  ){
       
    } else {
         [[ForumProperties sharedForumProperties] setPassword:@""];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"用户名:%@ 登陆失败～  ", username ] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}

@end
