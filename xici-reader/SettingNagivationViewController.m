//
//  SettingNagivationViewController.m
//  西祠利器
//
//  Created by Hanning Ni on 11/30/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "SettingNagivationViewController.h"
#import "LocalService.h"
#import "SubscriptionSettingViewController.h"
#import "SubscriptionForumSettingViewController.h"
#import "XiciHomePageParser.h"
#import "CategoryHome.h"
#import "TopMapImgItem.h"
#import "DownloadNotificationObj.h"
#import "ImageBatchRequest.h"
#import "HttpService.h"
#import "Constants.h"




@interface SettingNagivationViewController ()

@property (retain) NSMutableArray*  categoryList;
@property (retain) SubscriptionSettingViewController* subEditingController;
@property (retain) SubscriptionForumSettingViewController* subscriptionForumSettingViewController;
@property (retain) NSMutableArray* highlightedStories;
@property (retain) CategoryHome* categoryHome;
@property  (retain) Forum* selectedTopForum;
@end

@implementation SettingNagivationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.categoryList = [[LocalService sharedLocalService] getDefaultCateogryList];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:kSettingHtmlNotificationKey object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receivekHtmlPageDownload:)
                                                     name:  kSettingHtmlNotificationKey
                                                   object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSettingImageNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivekImageDownload:)
                                                 name:  kSettingImageNotificationKey
                                               object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSettingReloadNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivekReloadDownload:)
                                                 name:  kSettingReloadNotificationKey
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSettingHtmlNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSettingImageNotificationKey object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:kSettingReloadNotificationKey object:nil];
    
    [super viewWillDisappear:animated];
}

- (void) receivekHtmlPageDownload:(NSNotification *) notification
{
    
    if (  [[notification name] isEqualToString:kSettingHtmlNotificationKey ]){
        NSDictionary* result = notification.userInfo;
        if ( result  != nil ){
            CategoryHome* home = [result objectForKey:@"result"];
            if ( home )
                [self populateUI:home];
        }
    }
}
- (void) receivekImageDownload:(NSNotification *) notification
{
    
    if (  [[notification name] isEqualToString:kSettingImageNotificationKey ]){
        [self showForumListPane];
    }
}
- (void) receivekReloadDownload:(NSNotification *) notification
{
    
    if (  [[notification name] isEqualToString:kSettingReloadNotificationKey ]){
        [self refreshForumListPane];
    }
}


-(void)populateUI:(CategoryHome*)home{
    self.categoryHome = home;
    if (! self.highlightedStories )
        self.highlightedStories    = [[NSMutableArray alloc] initWithCapacity:8];
    else
        [self.highlightedStories removeAllObjects];
    // if ( home.category == nil ){
    //   return;
    // }
    if ( home.hotfly )
        for( Discussion* item in  home.hotfly){
            ForumImage* image = [[ForumImage alloc] init];
            image.imageUid = [ForumImage sourceLinkToUid:item.defaultImageUrl];
            image.imageSourceLink = item.defaultImageUrl;
            image.title = item.title;
            image.imageSourceType = CacheOnly;;
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
    notif.notificationKey = kSettingImageNotificationKey;
    
    ImageBatchRequest* request = [[ImageBatchRequest alloc] initWithForumImageList:self.highlightedStories notifcationObj:notif];
    
    [[HttpService sharedHttpService]  downloadImageBatch:request];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     if ( section == 0 )
         return 1;
    else
        return [self.categoryList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 85;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180, 85)];
    UILabel* content = [[UILabel  alloc] initWithFrame:CGRectMake(0, 45, 180, 40)];
    content.text = section == 0 ? @"HI" : @"  寻找跟多资讯~~";
    content.textColor = [UIColor grayColor];
    [header addSubview:content];
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    if ( indexPath.section == 0 ){
       static NSString *CellIdentifier = @"TopSettingCategory";
       UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
      if (cell == nil) {
           cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
       }
        cell.backgroundColor = [UIColor redColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.text = @"俺的西祠";
         return cell;
    } else {
        static NSString *CellIdentifier = @"TopSettingCategory2";
        ForumListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *objs = [[NSBundle mainBundle] loadNibNamed:@"ForumListCell" owner:nil options:nil];
            for (id currentObject in objs) {
                if ([currentObject isKindOfClass:[ForumListCell class]]) {
                    cell = (ForumListCell *)currentObject;
                    break;
                }
            }
        }
        
        Forum* forum = [self.categoryList objectAtIndex:indexPath.row];
        [cell setupTopForumResultRow:forum ];
         return cell;
    }
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

-(void)showMySettingPane{
    
    if ( ! self.subEditingController ){
        self.subEditingController =  [[SubscriptionSettingViewController alloc]  initWithNibName:@"SubscriptionSettingViewController" bundle:nil];
    
    }
    if ( [self.subEditingController.view superview] != nil )
        return;
    
    for(UIView* view in [self.detailContainer subviews]){
        [view removeFromSuperview];
    }
    [self.detailContainer addSubview:self.subEditingController.view];
    self.detailContainer.contentSize = self.subEditingController.view.frame.size;
    
    [self.subEditingController setupSubscriptionUI];
}

-(void)refreshForumListPane{
    if (  [self.subscriptionForumSettingViewController.view superview] != nil ){
        [self.subscriptionForumSettingViewController refreshUI];
    }
}

-(void)showForumListPane {
    if ( ! self.subscriptionForumSettingViewController ){
        self.subscriptionForumSettingViewController =  [[SubscriptionForumSettingViewController alloc]  initWithNibName:@"SubscriptionForumSettingViewController" bundle:nil];
        
    }
    if (  [self.subscriptionForumSettingViewController.view superview] == nil ){
      for(UIView* view in [self.detailContainer subviews]){
           [view removeFromSuperview];
      }
      [self.detailContainer addSubview:self.subscriptionForumSettingViewController.view];
       self.detailContainer.contentSize = self.subscriptionForumSettingViewController.view.frame.size;
    }
    if ( self.subscriptionForumSettingViewController.topForum != self.selectedTopForum){
        
        [self.subscriptionForumSettingViewController setupForumList:self.highlightedStories topForum: self.selectedTopForum home:self.categoryHome  ];
    }
}

 #pragma mark - Table view delegate
 
 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
     if ( indexPath.section == 0 ){
         [self showMySettingPane];
     } else {
         self.selectedTopForum  = [self.categoryList objectAtIndex:indexPath.row];
         [[XiciHomePageParser sharedHomePageParser] downloadForum:self.selectedTopForum notificationKey:kSettingHtmlNotificationKey];
     }
     
 }



@end
