//
//  ForumSearchResultViewController.m
//  西祠利器
//
//  Created by Hanning Ni on 11/30/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "ForumSearchResultViewController.h"
#import "AppDelegate.h"

@interface ForumSearchResultViewController (){
    BOOL isDirty;
    BOOL isScrolling;
}



@end

@implementation ForumSearchResultViewController

@synthesize resultForumList = _resultForumList;
@synthesize  tableView = _tableView;
 
@synthesize reloadMoreDelegate;

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
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView reloadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showData:(NSMutableArray*)result{
    if ( self.resultForumList == nil ){
        self.resultForumList = result;
    } else {
        [self.resultForumList addObjectsFromArray:result];
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
    return self.resultForumList == nil ?  0 : [self.resultForumList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SearchResultRow";
    SearchResultRow *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *objs = [[NSBundle mainBundle] loadNibNamed:@"SearchResultRow" owner:nil options:nil];
        for (id currentObject in objs) {
            if ([currentObject isKindOfClass:[SearchResultRow class]]) {
                cell = (SearchResultRow *)currentObject;
                break;
            }
        }
    }
    Forum* forum = [self.resultForumList objectAtIndex:indexPath.row];
    
    [cell setupSearchResultRow:forum delegate:self];
    
    if ( indexPath.row  == [self.resultForumList count] - 6 && reloadMoreDelegate ){
        [reloadMoreDelegate tryLoadMoreData];
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


 #pragma mark - Table view delegate
 
 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
     if  ( self.searchPopoverController )
         [self.searchPopoverController dismissPopoverAnimated:FALSE];
     Forum* forum = [self.resultForumList objectAtIndex:indexPath.row];
     NSString* url = [forum toForumUrl];
     AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
     [appDelegate.mainViewController gotoForumOrDiscussion:url];
 }



#pragma mark - ImageDownloaderDelegate

- (void)imageDidLoad:(NSString*)imageUID :(UIImage*)image{
    if ( isScrolling ){
        isDirty = TRUE;
    } else {
        isDirty = FALSE;
        [self.tableView reloadData];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    isScrolling = TRUE;
}// any offset changes

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
     isScrolling = TRUE;
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    isScrolling = FALSE;
    if ( isDirty ){
       isDirty = FALSE;
       [self.tableView reloadData];
    }
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    isScrolling = FALSE;
    if ( isDirty ){
        isDirty = FALSE;
        [self.tableView reloadData];
    }
}


@end
