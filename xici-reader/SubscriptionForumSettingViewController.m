//
//  SubscriptionForumSettingViewController.m
//  西祠利器
//
//  Created by Hanning Ni on 11/30/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "SubscriptionForumSettingViewController.h"
#import "Forum.h"
#import "ForumListCell.h"
#import "ForumImage.h"
#import "ForumDAO.h"
#import "ImageBatchRequest.h"
#import "HttpService.h"
#import "Constants.h"

@interface SubscriptionForumSettingViewController ()

@end

@implementation SubscriptionForumSettingViewController

@synthesize  forumList = _forumList;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshUI{
    [self.tableView reloadData];
}

-(void)setupForumList:(NSMutableArray*)forumList topForum:(Forum*)forum home:(CategoryHome*)home{
   
    self.topForum = forum;
    self.categoryHome = home;
    int count = [forumList count];
    if ( count > 0){
        ForumImage* newImage  = [forumList objectAtIndex:0];
        self.oneImageView.image = [UIImage  imageWithData:  newImage.imageData];
    }
    if ( count > 1){
        ForumImage* newImage  = [forumList objectAtIndex:1];
        self.twoImageView.image = [UIImage  imageWithData:  newImage.imageData];
    }
    if ( count > 2){
        ForumImage* newImage  = [forumList objectAtIndex:2];
        self.threeImageView.image = [UIImage  imageWithData:  newImage.imageData];
    }
    if ( count > 3){
        ForumImage* newImage  = [forumList objectAtIndex:3];
        self.fourImageView.image = [UIImage  imageWithData:  newImage.imageData];
    }
    if ( count > 4){
        ForumImage* newImage  = [forumList objectAtIndex:4];
        self.fiveImageView.image = [UIImage  imageWithData:  newImage.imageData];
    }
    
    self.forumList = [[NSMutableArray alloc] initWithCapacity:8];
    if  ( home.hotboard && [home.hotboard count] > 0){
        if ( [[home.hotboard objectAtIndex:0] isKindOfClass: [Forum class]]){
           [ self.forumList addObjectsFromArray:home.hotboard];
        }
    }
    if  ( home.hotfly && [home.hotfly count] > 0){
        if ( [[home.hotfly objectAtIndex:0] isKindOfClass: [Forum class]]){
            [ self.forumList addObjectsFromArray:home.hotfly];
        }
    }
    if  ( home.hotpic && [home.hotpic count] > 0){
        if ( [[home.hotpic objectAtIndex:0] isKindOfClass: [Forum class]]){
            [ self.forumList addObjectsFromArray:home.hotpic];
        }
    }
    if  ( home.hotsort && [home.hotsort count] > 0){
        if ( [[home.hotsort objectAtIndex:0] isKindOfClass: [Forum class]]){
            [ self.forumList addObjectsFromArray:home.hotsort];
        }
    }
    if  ( home.others && [home.others count] > 0){
        if ( [[home.others objectAtIndex:0] isKindOfClass: [Forum class]]){
            [ self.forumList addObjectsFromArray:home.others];
        }
    }
    self.titleLabel.text = forum.category;
    NSMutableArray* list = [[NSMutableArray alloc] initWithCapacity:16];
    
    for(int i = 0; i < [self.forumList count]; i++){
        Forum* f = [self.forumList objectAtIndex:i];
        Forum* flocal = [[ForumDAO sharedForumDAO] getForum:f.forumId];
        if ( flocal ){
            [self.forumList replaceObjectAtIndex:i withObject:flocal];
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
        notif.notificationKey = kSettingReloadNotificationKey;
    
   
        ImageBatchRequest* request = [[ImageBatchRequest alloc] initWithForumImageList:list notifcationObj:notif];
    
        [[HttpService sharedHttpService]  downloadImageBatch:request];
    }

    
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.forumList == nil ? 0 : [self.forumList count];
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
    Forum* forum = [self.forumList objectAtIndex:indexPath.row];
    
    [cell setupForumResultRow:forum delegate:self];
    
    
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
    [cell subscribeClicked:nil];
    
}



@end
