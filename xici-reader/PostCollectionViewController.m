//
//  PostCollectionViewController.m
//  西祠利器
//
//  Created by Hanning Ni on 12/1/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "PostCollectionViewController.h"
#import "AppDelegate.h"
#import "PostCollectionCell.h"
#import "Discussion.h"
#import "ForumDAO.h"
#import "R9Timer.h"

@interface PostCollectionViewController ()

@property (retain) NSMutableArray* collectedPostList;

@end

@implementation PostCollectionViewController

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
    // [self.tableview registerNib:[UINib nibWithNibName:@"PostCollectionCell" bundle:nil] forCellReuseIdentifier:@"PostCollectionCell"];
    self.webview.webDelegate = self;
   
     self.loadingIndicator1.hidden = TRUE;
    self.loadingIndicator2.hidden = TRUE;
    
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

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ( self.collectedPostList == nil )
       self.collectedPostList = [[ForumDAO sharedForumDAO] getDisscussions];
    else {
        [self.collectedPostList removeAllObjects];
        [self.collectedPostList addObjectsFromArray: [[ForumDAO sharedForumDAO] getDisscussions]];
    }
    [self.tableview reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)backClicked:(id)sender{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mainViewController popViewController];
}

#pragma  -- UIWebViewDelegate <NSObject>

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if (UIWebViewNavigationTypeOther == navigationType)
    {
        if ( [[[request URL] scheme] isEqualToString:@"anywherereader"] ){
            if ( [[[request URL]  absoluteString] rangeOfString:@"show.me.the.money" options:NSCaseInsensitiveSearch].location == NSNotFound ) {
                [[NSUserDefaults standardUserDefaults] setBool: YES  forKey:@"notShowAnywhereFAQ"];
            } else {
                [[NSUserDefaults standardUserDefaults] setBool: NO  forKey:@"notShowAnywhereFAQ"];
            }
            return NO;
        }
    }
    return YES;
    //  NSMutableURLRequest *request = (NSMutableURLRequest *)req;
    
    //    BOOL useMacAgent = [[NSUserDefaults standardUserDefaults] boolForKey:@"notDefaultIphoneWebAgent"];
    //
    //    if (useMacAgent && [request respondsToSelector:@selector(setValue:forHTTPHeaderField:)]) {
    //        NSString* userAgent = @"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_7; da-dk) AppleWebKit/533.21.1 (KHTML, like Gecko) Version/5.0.5 Safari/533.21.1";
    //        //   userAgent = @"Desktop";
    //        [request setValue:userAgent forHTTPHeaderField:@"User_Agent"];
    //        [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    //        [request setValue:userAgent forHTTPHeaderField:@"UserAgent"];
    //    }
}


- (void)webViewDidStartLoad:(UIWebView *)webView{
    self.loadingIndicator1.hidden = FALSE;
    [self.loadingIndicator1 startAnimating];
    self.loadingIndicator2.hidden = FALSE;
    [self.loadingIndicator2 startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.loadingIndicator1 stopAnimating];
    self.loadingIndicator1.hidden = TRUE;
    [self.loadingIndicator2 stopAnimating];
    self.loadingIndicator2.hidden = TRUE;
   // [self updateControlUI];
   // self.currentUrl = [self.webview getCurrentPageURLStr];
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self.loadingIndicator1 stopAnimating];
    self.loadingIndicator1.hidden = TRUE;
    [self.loadingIndicator2 stopAnimating];
    self.loadingIndicator2.hidden = TRUE;
    //[self updateControlUI];
}

#pragma  --end UIWebViewDelegate <NSObject>



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.collectedPostList == nil ? 0 : [self.collectedPostList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"PostCollectionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell){
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		cell.textLabel.font = [UIFont systemFontOfSize:13];
  	}
    Discussion* discussion = [self.collectedPostList objectAtIndex:indexPath.row];
    if ( !discussion.user  && discussion.userId){
        discussion.user = [[ForumDAO sharedForumDAO] getUserById:discussion.userId];
    }
    cell.textLabel.text = discussion.title;
    NSString* subtitle = discussion.user == nil ? @"" : discussion.user.userName;
    subtitle =  [subtitle stringByAppendingFormat:@"  收录于［%@ ］",  [[R9Timer sharedR9Timer] formatSimpleTimeWithSeconds: discussion.timestamp] ];
    cell.detailTextLabel.text = subtitle;

    
//    PostCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        NSArray *objs = [[NSBundle mainBundle] loadNibNamed:@"PostCollectionCell" owner:nil options:nil];
//        for (id currentObject in objs) {
//            if ([currentObject isKindOfClass:[PostCollectionCell class]]) {
//                cell = (PostCollectionCell *)currentObject;
//                break;
//            }
//        }
//    }
   
//    cell.topicLabel.text = discussion.title;
//    cell.authorLabel.text = discussion.user == nil ? @"" : discussion.user.userName;
//    cell.timeLabel.text = [[R9Timer sharedR9Timer] formatSimpleTimeWithSeconds: discussion.timestamp];
    
    return cell;
}


 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
      return YES;
 }
 


 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
      Discussion* dis = [self.collectedPostList objectAtIndex:indexPath.row];
     [[ForumDAO sharedForumDAO] deleteDisscussion:dis.discussionId];
     [self.collectedPostList removeObjectAtIndex:indexPath.row];
     
     [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }


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
    Discussion* dis = [self.collectedPostList objectAtIndex:indexPath.row];
    NSString* url = [dis getDiscussionUrl];
    [self.webview tryLoadUrl:url]; 
}

@end
