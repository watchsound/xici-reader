//
//  CategoryViewController.m
//  西祠利器
//
//  Created by Hanning Ni on 11/24/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "CategoryViewController.h"
#import "XiciCategory.h"
#import "CategoryThumbnailViewController.h"
#import "CategoryThumbnailRegularViewController.h"
#import "AppDelegate.h"
#import "ForumDAO.h"
#import "XiciHomePageParser.h"


@interface CategoryViewController (){
    int curSearchPageNum;
    BOOL duringSearchLoading;
    BOOL mayHaveMoreData;
}

@property (retain) NSMutableArray*  viewControllerList;

@property (retain) CategoryThumbnailViewController* headlineViewController;
@end

@implementation CategoryViewController

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
    self.indicatorView.hidden = TRUE;
    self.searchField.delegate = self;
    // Do any additional setup after loading the view from its nib.
   
    self.headlineViewController = [[CategoryThumbnailViewController alloc]  initWithNibName:@"CategoryThumbnailViewController" bundle:nil];
    [self.headlineViewHolder addSubview:self.headlineViewController.view];
    self.headlineViewController.categoryLabel.text = @"今日头条";
    self.headlineViewController.sourceLabel.hidden = FALSE;
    
    self.viewControllerList = [[NSMutableArray alloc] initWithCapacity:8];
    NSArray* viewHoldList = [NSArray arrayWithObjects:self.view1Holder,
                             self.view2Holder, self.view3Holder, self.view4Holder,
                             self.view5Holder, self.view6Holder, self.view7Holder, nil];
    for(int i = 0; i < [self.forumList count] && i < [viewHoldList count] ; i ++ ){
        Forum* c  = [self.forumList objectAtIndex:i];
        UIView* holder = [viewHoldList objectAtIndex:i];
         CategoryThumbnailRegularViewController* ctrvc = [[CategoryThumbnailRegularViewController alloc]  initWithNibName:@"CategoryThumbnailRegularViewController" bundle:nil];
        [self.viewControllerList addObject:ctrvc];
       
        [holder addSubview:ctrvc.view];
         [ctrvc setupUI:c];
    }
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        
        horizontalMotionEffect.minimumRelativeValue = @(-50);
        
        horizontalMotionEffect.maximumRelativeValue = @(50);
        
        [self.bgone addMotionEffect:horizontalMotionEffect];
        [self.bgtwo addMotionEffect:horizontalMotionEffect];
    }
    [self startBackgroundAnimation];
}

-(void)startBackgroundAnimation{
    self.bgone.alpha = 0.2;
    self.bgtwo.alpha = 1;
    [UIView animateWithDuration:5 animations:^{
        self.bgone.alpha = 1;
        self.bgtwo.alpha = 0.2;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:5 animations:^{
            self.bgone.alpha = 0.2;
            self.bgtwo.alpha = 1;
        } completion:^(BOOL finished) {
            [self startBackgroundAnimation];
        }];
    }];
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
-(IBAction)rightButtonClicked:(id)sender{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mainViewController gotoPreviousPage];
   
}

-(IBAction)collectClicked:(id)sender{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mainViewController showCollectedPostPage];
}

-(IBAction)footButtonClicked:(id)sender{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mainViewController showFootPage];
}

-(IBAction)settingButtonClicked:(id)sender{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mainViewController showSettingPage];

}

-(IBAction)refreshButtonClicked:(id)sender{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ( [textField.text length] == 0 )
        return NO;
    
    if ( textField == self.searchField ){
        self.indicatorView.hidden = FALSE;
        [self.indicatorView startAnimating];
        curSearchPageNum = 0;
        duringSearchLoading = TRUE;
        mayHaveMoreData = TRUE;
        NSString* queryUrl = [NSString stringWithFormat:@"http://www.xici.net/s/?k=%@&page=%i&t=1", textField.text , curSearchPageNum];
       [[HttpService sharedHttpService]   downloadWithUrl:queryUrl  key:queryUrl parameters:nil  isPost:FALSE requestKey:queryUrl    delegate:self];
    }
    return TRUE;
}


- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    if ( popoverController == self.searchPopoverController ){
        self.searchPopoverController = nil;
         duringSearchLoading = FALSE;
         mayHaveMoreData = TRUE;
         curSearchPageNum = 0;
    }
}

#pragma  -- HtmlDownloaderOpDelegate <NSObject>

-(void)finishDownloadHtml:(HtmlDownloaderOp *)downloader{
    self.indicatorView.hidden = TRUE ;
    [self.indicatorView stopAnimating];
    
    if ( downloader.result ){
        [self.searchField resignFirstResponder];
        duringSearchLoading = FALSE;
        NSMutableArray* result =  [[XiciHomePageParser sharedHomePageParser] parseSearchResult:downloader.result];
        if ([result count] != 0 ){
            if(  curSearchPageNum == 0 ){
                ForumSearchResultViewController* controller =  [[ForumSearchResultViewController alloc]  initWithNibName:@"ForumSearchResultViewController" bundle:nil];
                controller.reloadMoreDelegate = self;
                self.searchPopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
                controller.searchPopoverController = self.searchPopoverController;
                [controller showData:result];
                [self.searchPopoverController presentPopoverFromRect:self.searchField.frame
                                       inView:self.view
                                        permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            } else {
                if ( self.searchPopoverController ){
                    ForumSearchResultViewController* controller = (ForumSearchResultViewController*) self.searchPopoverController.contentViewController;
                    [controller showData:result];
                }
            }
        } else {
            mayHaveMoreData = FALSE;
        }
    } else {
        mayHaveMoreData = FALSE;
    }
}
#pragma ForumSearchResultViewControllerDelegate <NSObject>

-(void)tryLoadMoreData{
    if ( duringSearchLoading || !mayHaveMoreData)
        return;
    curSearchPageNum ++;
    duringSearchLoading = TRUE;
    NSString* queryUrl = [NSString stringWithFormat:@"http://www.xici.net/s/?k=%@&page=%i&t=1", self.searchField.text , curSearchPageNum];
    [[HttpService sharedHttpService]   downloadWithUrl:queryUrl  key:queryUrl parameters:nil  isPost:FALSE requestKey:queryUrl    delegate:self];
}

@end
