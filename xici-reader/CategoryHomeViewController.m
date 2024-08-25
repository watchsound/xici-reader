//
//  CategoryHomeViewController.m
//  西祠利器
//
//  Created by Hanning Ni on 12/1/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "CategoryHomeViewController.h"
#import "Discussion.h"
#import "ForumListCell.h"
#import "ReflectionView.h"
#import "ForumImage.h"
#import "Constants.h"
#import "TopMapImgItem.h"
#import "DownloadNotificationObj.h"
#import "ImageBatchRequest.h"
#import "HttpService.h"
#import "ForumDAO.h"
#import "LocalService.h"
#import "AppDelegate.h"

#define  kNewsBackgroundImageTag  34234
@interface CategoryHomeViewController (){
    int imageHolderAnimationPos;
}

@property (retain) NSMutableArray* discussionWithImg;
@property (retain) NSMutableArray* allDiscussions;
@property (retain) NSMutableArray* hotForumList;
@property (retain) NSMutableArray* disscussionNoImg;

@property (retain) NSTimer* replaceImageHolderTimer;

@end

@implementation CategoryHomeViewController

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
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        
        horizontalMotionEffect.minimumRelativeValue = @(-50);
        
        horizontalMotionEffect.maximumRelativeValue = @(50);
        
        [self.bgone addMotionEffect:horizontalMotionEffect];
        [self.bgtwo addMotionEffect:horizontalMotionEffect];
    }
  
}




-(void)startBackgroundAnimation{
    if ( [self.view superview] == nil  )
        return;
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


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if ( self.carousel ){
        self.carousel.delegate = self;
        self.carousel.dataSource = self;
        self.carousel.type =  iCarouselTypeCoverFlow2;
        [self.carousel reloadData];
        [self.carousel startAutoAnimation];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCateogryHomeDetailForumReloadNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivekReloadDownload:)
                                                 name:  kCateogryHomeDetailForumReloadNotificationKey
                                               object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCateogryHomeDetailDiscussionReloadNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivekReloadDownload:)
                                                 name:  kCateogryHomeDetailDiscussionReloadNotificationKey
                                               object:nil];
    
    [self startreplaceImageHolderTimer];
    [self startBackgroundAnimation];
}

- (void)viewWillDisappear:(BOOL)animated{
    if ( self.carousel ){
        self.carousel.dataSource = nil;
        self.carousel.delegate = nil;
        [self.carousel stopAutoAnimation];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCateogryHomeDetailForumReloadNotificationKey object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCateogryHomeDetailDiscussionReloadNotificationKey object:nil];
    
    if ( self.replaceImageHolderTimer != nil ){
        [self.replaceImageHolderTimer invalidate];
        self.replaceImageHolderTimer = nil;
    }
    
    [super viewWillDisappear:animated];
}

- (void) receivekReloadDownload:(NSNotification *) notification
{
    
    if (  [[notification name] isEqualToString:kCateogryHomeDetailForumReloadNotificationKey ]){
       [self.tableViewtop reloadData];
    }
    if (  [[notification name] isEqualToString:kCateogryHomeDetailDiscussionReloadNotificationKey ]){
        [self.tableView reloadData];
        [self.carousel reloadData];
         self.carousel.type =  iCarouselTypeCoverFlow2;
        [self.carousel startAutoAnimation];
        [self populateImageHolder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)startreplaceImageHolderTimer  {
    if ( self.replaceImageHolderTimer != nil ){
        [self.replaceImageHolderTimer invalidate];
        self.replaceImageHolderTimer = nil;
    }
  
    self.replaceImageHolderTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(populateImageHolder) userInfo:nil repeats:TRUE];
    
}

-(void)populateImageHolder{
    if (! self.discussionWithImg || ! self.categoryHome)
        return;
    int count = [self.discussionWithImg count];
    if ( count == 0 )
        return;
    
    [UIView animateWithDuration:0.8 animations:^{
        self.imageView1.alpha = 0.2;
         self.imageView2.alpha = 0.2;
         self.imageView3.alpha = 0.2;
         self.imageView4.alpha = 0.2;
         self.imageView5.alpha = 0.2;
         self.imageView6.alpha = 0.2;
    } completion:^(BOOL finished) {
        imageHolderAnimationPos =  (imageHolderAnimationPos + 1) % count;
        
        Discussion* d = [self.discussionWithImg objectAtIndex:imageHolderAnimationPos];
        if (  d.defaultImageData )
            self.imageView1.image = [UIImage imageWithData:d.defaultImageData];
        
        if ( d.content ) {
            self.title1.text =   [d.title stringByAppendingString:d.content];
        } else {
            self.title1.text = d.title;
        }
        
        imageHolderAnimationPos =  (imageHolderAnimationPos + 1) % count;
        d = [self.discussionWithImg objectAtIndex:imageHolderAnimationPos];
        if (  d.defaultImageData )
            self.imageView2.image = [UIImage imageWithData:d.defaultImageData];
        
        if ( d.content ) {
            self.title2.text =   [d.title stringByAppendingString:d.content];
        } else {
            self.title2.text = d.title;
        }
        imageHolderAnimationPos =  (imageHolderAnimationPos + 1) % count;
        d = [self.discussionWithImg objectAtIndex:imageHolderAnimationPos];
        if (  d.defaultImageData )
            self.imageView3.image = [UIImage imageWithData:d.defaultImageData];
        
        if ( d.content ) {
            self.title3.text =   [d.title stringByAppendingString:d.content];
        } else {
            self.title3.text = d.title;
        }
        imageHolderAnimationPos =  (imageHolderAnimationPos + 1) % count;
        d = [self.discussionWithImg objectAtIndex:imageHolderAnimationPos];
        if (  d.defaultImageData )
            self.imageView4.image = [UIImage imageWithData:d.defaultImageData];
        
        if ( d.content ) {
            self.title4.text =   [d.title stringByAppendingString:d.content];
        } else {
            self.title4.text = d.title;
        }
        
        imageHolderAnimationPos =  (imageHolderAnimationPos + 1) % count;
        d = [self.discussionWithImg objectAtIndex:imageHolderAnimationPos];
        if (  d.defaultImageData )
            self.imageView5.image = [UIImage imageWithData:d.defaultImageData];
        
        if ( d.content ) {
            self.title5.text =   [d.title stringByAppendingString:d.content];
        } else {
            self.title5.text = d.title;
        }
        
        imageHolderAnimationPos =  (imageHolderAnimationPos + 1) % count;
        d = [self.discussionWithImg objectAtIndex:imageHolderAnimationPos];
        if (  d.defaultImageData )
            self.imageView6.image = [UIImage imageWithData:d.defaultImageData];
        
        if ( d.content ) {
            self.title6.text =   [d.title stringByAppendingString:d.content];
        } else {
            self.title6.text = d.title;
        }
        
        [UIView animateWithDuration:0.8 animations:^{
            self.imageView1.alpha = 1;
            self.imageView2.alpha = 1;
            self.imageView3.alpha = 1;
            self.imageView4.alpha = 1;
            self.imageView5.alpha = 1;
            self.imageView6.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }];
    
   }

-(void)setupUI:(CategoryHome*)home{
    self.categoryHome = home;
    
    self.discussionWithImg = [[NSMutableArray alloc] initWithCapacity:4];
    self.hotForumList = [[NSMutableArray alloc] initWithCapacity:4];
    self.allDiscussions = [[NSMutableArray alloc] initWithCapacity:4];
    self.disscussionNoImg = [[NSMutableArray alloc] initWithCapacity:4];
    
    if  ( home.hotfly && [home.hotfly count] > 0){
        if ( [[home.hotfly objectAtIndex:0] isKindOfClass: [Forum class]]){
            [ self.hotForumList addObjectsFromArray:home.hotfly];
            
        }
        if ( [[home.hotfly objectAtIndex:0] isKindOfClass: [Discussion class]]){
            Discussion* d = (Discussion*) [home.hotfly objectAtIndex:0];
            if ( d.defaultImageUrl != nil)
               [ self.discussionWithImg addObjectsFromArray:home.hotfly];
            else
              [ self.disscussionNoImg addObjectsFromArray:home.hotfly];
        }
    }
    
    if  ( home.hotboard && [home.hotboard count] > 0){
        if ( [[home.hotboard objectAtIndex:0] isKindOfClass: [Forum class]]){
            [ self.hotForumList addObjectsFromArray:home.hotboard];
        }
        if ( [[home.hotboard objectAtIndex:0] isKindOfClass: [Discussion class]]){
            Discussion* d = (Discussion*) [home.hotboard objectAtIndex:0];
            if ( d.defaultImageUrl != nil)
                [ self.discussionWithImg addObjectsFromArray:home.hotboard];
            else
                [ self.disscussionNoImg addObjectsFromArray:home.hotboard];
        }
    }
    
    if  ( home.hotpic && [home.hotpic count] > 0){
        if ( [[home.hotpic objectAtIndex:0] isKindOfClass: [Forum class]]){
            [ self.hotForumList addObjectsFromArray:home.hotpic];
        }
        if ( [[home.hotpic objectAtIndex:0] isKindOfClass: [Discussion class]]){
            Discussion* d = (Discussion*) [home.hotpic objectAtIndex:0];
            if ( d.defaultImageUrl != nil)
                [ self.discussionWithImg addObjectsFromArray:home.hotpic];
            else
                [ self.disscussionNoImg addObjectsFromArray:home.hotpic];
        }
    }
    if  ( home.hotsort && [home.hotsort count] > 0){
        if ( [[home.hotsort objectAtIndex:0] isKindOfClass: [Forum class]]){
            [ self.hotForumList addObjectsFromArray:home.hotsort];
        }
        if ( [[home.hotsort objectAtIndex:0] isKindOfClass: [Discussion class]]){
            Discussion* d = (Discussion*) [home.hotsort objectAtIndex:0];
            if ( d.defaultImageUrl != nil)
                [ self.discussionWithImg addObjectsFromArray:home.hotsort];
            else
                [ self.disscussionNoImg addObjectsFromArray:home.hotsort];
        }
    }
    if  ( home.others && [home.others count] > 0){
        if ( [[home.others objectAtIndex:0] isKindOfClass: [Forum class]]){
            [ self.hotForumList addObjectsFromArray:home.others];
        }
        if ( [[home.others objectAtIndex:0] isKindOfClass: [Discussion class]]){
            Discussion* d = (Discussion*) [home.others objectAtIndex:0];
            if ( d.defaultImageUrl != nil)
                [ self.discussionWithImg addObjectsFromArray:home.others];
            else
                [ self.disscussionNoImg addObjectsFromArray:home.others];
        }
    }
    
    if ( home.topMapImageList )
        for( TopMapImgItem* item in  home.topMapImageList){
            Discussion* discussion = [[Discussion alloc] init];
            discussion.discussionId = item.articleSourceLink;
            discussion.defaultImageUrl = item.imageSourceLink;
            discussion.title = item.headline;
            [self.discussionWithImg addObject: discussion];
        }
    
    [self.allDiscussions addObjectsFromArray: self.discussionWithImg];
    [self.allDiscussions addObjectsFromArray: self.disscussionNoImg];
    
    
    
    NSMutableArray*  discussionImages =  [[NSMutableArray alloc] initWithCapacity:8];
        for( Discussion* item in  self.discussionWithImg){
            NSString* uid = [ForumImage sourceLinkToUid:item.defaultImageUrl];
            NSData*  data = [[LocalService sharedLocalService] getImageFromCache: uid];
            if ( data ){
                item.defaultImageData = data;
                continue;
            }
            ForumImage* image = [[ForumImage alloc] init];
            image.imageUid = uid;
            image.imageSourceLink = item.defaultImageUrl;
            image.title = item.title;
            image.imageSourceType = CacheOnly;;
            image.discussion = item;
            [discussionImages addObject: image];
        }
    
    DownloadNotificationObj* notif = [[DownloadNotificationObj alloc] init];
    notif.notificationKey = kCateogryHomeDetailDiscussionReloadNotificationKey;
    
    ImageBatchRequest* request = [[ImageBatchRequest alloc] initWithForumImageList: discussionImages notifcationObj:notif];
    
    [[HttpService sharedHttpService]  downloadImageBatch:request];
    
    
    
    NSMutableArray* list = [[NSMutableArray alloc] initWithCapacity:16];
    
    for(int i = 0; i < [self.hotForumList count]; i++){
        Forum* f = [self.hotForumList objectAtIndex:i];
        Forum* flocal = [[ForumDAO sharedForumDAO] getForum:f.forumId];
        if ( flocal ){
            [self.hotForumList replaceObjectAtIndex:i withObject:flocal];
        } else {
            if ( !f.forumIcon ){
                ForumImage* image = [[ForumImage alloc] init];
                image.forum = f;
                image.imageSourceType = ForumThumbnail;
                image.imageUid = f.forumId;
                image.imageSourceLink = [Forum toForumIconUrl:f.forumId];
                image.title = f.forumTitle;
                
                [list addObject:image];
            }
        }
    }
    if ( [list count] > 0 ){
        DownloadNotificationObj* notif = [[DownloadNotificationObj alloc] init];
        notif.notificationKey = kCateogryHomeDetailForumReloadNotificationKey;
        
        
        ImageBatchRequest* request = [[ImageBatchRequest alloc] initWithForumImageList:list notifcationObj:notif];
        
        [[HttpService sharedHttpService]  downloadImageBatch:request];
    }

      [self.tableViewtop reloadData];
      [self.tableView reloadData];
      [self populateImageHolder];
      self.carousel.type =  iCarouselTypeCoverFlow2;
      [self.carousel reloadData];
    [self.carousel startAutoAnimation];
}


-(IBAction)container1Clicked:(id)sender{
    
}
-(IBAction)container2Clicked:(id)sender{
    
}

-(IBAction)container3Clicked:(id)sender{
    
}

-(IBAction)container4Clicked:(id)sender{
    
}

-(IBAction)container5Clicked:(id)sender{
    
}

-(IBAction)container6Clicked:(id)sender{
    
}



-(IBAction)footstepClicked:(id)sender{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mainViewController showFootPage];
}

-(IBAction)collectionClicked:(id)sender{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mainViewController showCollectedPostPage];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( tableView == self.tableView)
        return self.allDiscussions == nil ? 0 : [self.allDiscussions count];
    else
        return self.hotForumList == nil ? 0 : [self.hotForumList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"SubscribeForumRow";
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
    if ( tableView == self.tableView){
         Discussion * discussion = [self.allDiscussions objectAtIndex:indexPath.row];
         [cell setupTopDiscussionResultRow:discussion];
    } else {
        
        Forum* forum = [self.hotForumList objectAtIndex:indexPath.row];
        
        [cell setupTopForumResultRow:forum];
    }
    
    
    return cell;
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

#pragma mark -  ForumListCellDelegate
- (void)subscribeToForum:(Forum*)forum{
    //    int index =    [self.forumList indexOfObject:forum];
    //    if ( index < 0 )
    //        return;
    //    NSIndexPath* indexPath = [NSIndexPath indexPathWithIndex:index];
    //     [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}




#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    
    ForumListCell *cell =(ForumListCell *)  [tableView cellForRowAtIndexPath:indexPath];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString* url = cell.forum == nil ? [cell.discussion getDiscussionUrl] : [cell.forum toForumUrl];
    [appDelegate.mainViewController gotoForumOrDiscussion:url];
}


#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    
    return [self.discussionWithImg count] ;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(ReflectionView *)view
{
    //  NSLog(@"carousel index = %i", index);
    UIImageView* cardBackground = nil;
    //   UILabel*  titleLabel = nil;
	if (view == nil)
	{
        //set up reflection view
		view = [[ReflectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 280.0f, 245.0f)];
        
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
    Discussion* newsImage  = [self.discussionWithImg objectAtIndex:index];
    cardBackground.image = [UIImage imageWithData:newsImage.defaultImageData];
    if ( cardBackground.image == nil )
        NSLog(@"!!!");
    self.mainTitleLabel.text = newsImage.title;
    //update reflection
    //this step is expensive, so if you don't need
    //unique reflections for each item, don't do this
    //and you'll get much smoother peformance
    [view update];
	
	return view;
}




@end
