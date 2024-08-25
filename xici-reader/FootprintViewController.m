//
//  FootprintViewController.m
//  西祠利器
//
//  Created by Hanning Ni on 12/2/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "FootprintViewController.h"
#import "FootDetail2View.h"
#import "Forum.h"
#import "User.h"
#import "ForumDAO.h"
#import "XiciHomePageParser.h"
#import "AuthorCell.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "AFCollectionViewFlowLargeLayout.h"

@interface FootprintViewController (){
    int curSearchPageNum;
}

@property (retain) NSMutableArray* forumList;
@property (retain) NSMutableArray* userList;
@property (retain) NSMutableDictionary* userToForumList;
@property (retain) User* currentSelectedUser;

@end

@implementation FootprintViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
  
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFootReloadNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivekImagePageDownload:)
                                                 name:  kFootReloadNotificationKey
                                               object:nil];
   
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFootReloadNotificationKey object:nil];
    
    [super viewWillDisappear:animated];
}

- (void) receivekImagePageDownload:(NSNotification *) notification
{
    
    if (  [[notification name] isEqualToString:kFootReloadNotificationKey ]){
        [self.collectionView reloadData];
    }
}

-(IBAction)refreshClicked:(id)sender{
    NSMutableArray* newList = [[ForumDAO sharedForumDAO] getFans];
    for (User* user in newList){
        BOOL newUser = TRUE;
        for (User * euser in self.userList ){
            if ( [user.userId isEqualToString:euser.userId] ){
                newUser = FALSE;
                break;
            }
        }
        if (newUser )
           [ self.userList addObject:user];
    }     
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.indicator1.hidden = TRUE;
    self.indicator2.hidden = TRUE;
    self.userToForumList = [[NSMutableDictionary alloc] initWithCapacity:4];
    self.forumList = [[NSMutableArray alloc] initWithCapacity:8];
    self.userList =  [[ForumDAO sharedForumDAO] getFans];
    // Configure layout
    self.flowLayout = [[AFCollectionViewFlowLargeLayout alloc] init];
   // [self.flowLayout setItemSize:CGSizeMake(100, 100)];
   // [self.flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
  //  self.flowLayout.minimumInteritemSpacing = 0.0f;
    
   [self.collectionView registerClass:[FootDetail2View class] forCellWithReuseIdentifier:@"FootDetail2View"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"AuthorCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"AuthorCell"];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    [self.collectionView setCollectionViewLayout:self.flowLayout];
    self.collectionView.bounces = YES;
    [self.collectionView setShowsHorizontalScrollIndicator:NO];
    [self.collectionView setShowsVerticalScrollIndicator:NO];
    
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

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.forumList count];
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition{
    Forum* f = [self.forumList objectAtIndex:indexPath.row];
    NSString* url = [f toForumUrl];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mainViewController gotoForumOrDiscussion:url];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FootDetail2View *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FootDetail2View" forIndexPath:indexPath];
    if ( cell == nil ){
        
            NSArray *objs = [[NSBundle mainBundle] loadNibNamed:@"FootDetail2View" owner:nil options:nil];
            for (id currentObject in objs) {
                if ([currentObject isKindOfClass:[FootDetail2View class]]) {
                    cell = (FootDetail2View *)currentObject;
                    break;
                }
            }
        
    }
    Forum *f = [self.forumList objectAtIndex:indexPath.row];
    
    [cell setup:f  numOfUser:[self numOfFootsInForum:f] delegate:self];
    
   // cell.label.text = [NSString stringWithFormat:@"%d",indexPath.item];
    return cell;
}


- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)addForum:(Forum*)forum{
    for(Forum* f in self.forumList){
        if ( [f.forumId isEqualToString:forum.forumId] )
            return FALSE;
    }
    forum.thumbnailUrl= [Forum toForumIconUrl:forum.forumId];
    
    [self.forumList addObject:forum];
    [self.collectionView reloadData];
    return TRUE;
}


-(IBAction)backClicked:(id)sender{
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.userList == nil ? 0 : [self.userList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"AuthorCell";
    AuthorCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    User* user = [self.userList objectAtIndex:indexPath.row];
    [cell setupUser:user];
    
    return cell;
}

-(void)addFootForUser:(User*)user{
      [self.collectionView reloadData];
}

-(void)removeFootForUser:(User*)user{
      [self.collectionView reloadData];
}

-(int)numOfFootsInForum:(Forum*)forum{
    int count = 0;
    for(User* user in self.userList ){
        if ( user.isSelectedInUI ){
            for( Forum* f in [self.userToForumList objectForKey:user.userId]){
                if ( [f.forumId isEqualToString: forum.forumId]){
                    count ++;
                    break;
                }
            }
        }
    }
    return count;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User* user = [self.userList objectAtIndex:indexPath.row];
    AuthorCell *cell =(AuthorCell*) [self.tableView cellForRowAtIndexPath:indexPath];
    [cell toggleSelection];
    
    if ( !user.isSelectedInUI ){
        [self removeFootForUser:user];
        return;
    }
    
    self.currentSelectedUser = user;
    if ( [self.userToForumList objectForKey:user.userId] )
        return;
    
    curSearchPageNum = 0;
    NSString* queryUrl = [NSString stringWithFormat:@"http://www.xici.net/s/?k=%@&page=%i&t=2", user.userName , curSearchPageNum];
    [[HttpService sharedHttpService]   downloadWithUrl:queryUrl  key:queryUrl parameters:nil  isPost:FALSE requestKey:queryUrl    delegate:self];
    
    self.indicator1.hidden = FALSE ;
    [self.indicator1 startAnimating];
    self.indicator2.hidden = FALSE ;
    [self.indicator2 startAnimating];
}

#pragma  -- HtmlDownloaderOpDelegate <NSObject>

-(void)finishDownloadHtml:(HtmlDownloaderOp *)downloader{
    self.indicator1.hidden = TRUE ;
    [self.indicator1 stopAnimating];
    self.indicator2.hidden = TRUE ;
    [self.indicator2 stopAnimating];
    
    if ( downloader.result ){
       
        NSMutableArray* result =  [[XiciHomePageParser sharedHomePageParser] parseUserVisitedForum:downloader.result];
        NSMutableArray* newResult = [[NSMutableArray alloc] initWithCapacity:4];
        if ([result count] != 0 ){
            for(Forum* f in result){
               BOOL isNew =  [self addForum:f];
                if (isNew)
                    [newResult addObject:f];
            }
            [self.userToForumList setObject:result forKey:self.currentSelectedUser.userId];
        }
        if ( [newResult count] > 0 ){
            NSMutableArray* list = [[NSMutableArray alloc] initWithCapacity:16];
            
            for(int i = 0; i < [newResult count]; i++){
                Forum* f = [newResult objectAtIndex:i];
                Forum* flocal = [[ForumDAO sharedForumDAO] getForum:f.forumId];
                if ( flocal ){
                    
                } else {
                    if ( !f.forumIcon ){
                        ForumImage* image = [[ForumImage alloc] init];
                       // image.forum = f;
                        image.imageSourceType = CacheOnly;
                       
                        image.imageSourceLink = [Forum toForumIconUrl:f.forumId];
                        image.imageUid = [ForumImage sourceLinkToUid: image.imageSourceLink ];
                        image.title = f.forumTitle; 
                        [list addObject:image];
                    }
                }
            }
            if ( [list count] > 0 ){
                DownloadNotificationObj* notif = [[DownloadNotificationObj alloc] init];
                notif.notificationKey = kFootReloadNotificationKey;
                
                
                ImageBatchRequest* request = [[ImageBatchRequest alloc] initWithForumImageList:list notifcationObj:notif];
                
                [[HttpService sharedHttpService]  downloadImageBatch:request];
            }

        }
        
    }
    [self.collectionView reloadData];
}

#pragma  ImageDownloaderDelegate
- (void)imageDidLoad:(NSString*)imageUID :(UIImage*)image{
    [self.collectionView reloadData];
}

@end
