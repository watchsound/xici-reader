//
//  ForumWebViewController.m
//  西祠利器
//
//  Created by Hanning Ni on 12/1/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "ForumWebViewController.h"
#import "Forum.h"
#import "Discussion.h"
#import "AppDelegate.h"
#import "iToast.h"
#import "LocalService.h"
#import "ForumDAO.h"
#import "ImageBatchRequest.h"
#import "HttpService.h"
#import "Constants.h"

@interface ForumWebViewController ()

@property (retain) NSString*  currentUrl;
@property (retain) Forum* forum;
@property (retain) Discussion* discussion;

@end

@implementation ForumWebViewController

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
    self.webview.webDelegate = self;
    if ( self.currentUrl){
        [self.webview tryLoadUrl:self.currentUrl];
        [self updateControlUI];
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

-(IBAction)addCommentClicked:(id)sender{
    
}
-(IBAction)addPostClicked:(id)sender{
    
}
-(IBAction)saveClicked:(id)sender{
    BOOL isForum = [self isForum];
    BOOL isDiscussion = [self isDiscussion];
    if ( isForum ){
        Forum* f = [[Forum alloc] init];
        f.forumId =  self.currentUrl;
        f.forumTitle =  [self.webview getForumTitle];
        ForumImage* image = [[ForumImage alloc] init];
        image.forum = f;
        image.imageSourceType = ForumThumbnail;
        image.imageUid = f.forumId;
        image.imageSourceLink = [Forum toForumIconUrl:f.forumId];
        image.title = f.forumTitle;
        NSMutableArray* list = [[NSMutableArray alloc] initWithCapacity:2];
        [list addObject:image];
        DownloadNotificationObj* notif = [[DownloadNotificationObj alloc] init];
        notif.notificationKey = @"nowhere";
        
        
        ImageBatchRequest* request = [[ImageBatchRequest alloc] initWithForumImageList:list notifcationObj:notif];
        
        [[HttpService sharedHttpService]  downloadImageBatch:request];
        
        [[iToast makeText:@"～～收录成功～～" ] show];

    } else if (isDiscussion){
         User* user = [self.webview getPostAuthorInfo];
         [[LocalService sharedLocalService] saveOnlyNewUser:user];
        
        Discussion * discussion = [[Discussion alloc] init];
        discussion.discussionId = self.currentUrl;
        discussion.title  = [self.webview getDiscussionTitle];
        discussion.timestamp = [[NSDate date] timeIntervalSince1970];
        
        [[ForumDAO sharedForumDAO] saveDiscussion:discussion];
         [[iToast makeText:@"～～收录成功～～" ] show];
    }
}

-(IBAction)followClicked:(id)sender{
      BOOL isDiscussion = [self isDiscussion];
    if ( isDiscussion ){
        User* user = [self.webview getPostAuthorInfo];
        user.isFriend  = TRUE;
        user.isFan = TRUE;
        if ( user != nil ){
            [[LocalService sharedLocalService] saveUser:user];
               [[iToast makeText:@"～～成功关注该西祠用户～～" ] show];
            ForumImage* image = [[ForumImage alloc] init];
            image.user = user;
            image.imageSourceType = AuthorThumbnail;
              image.imageSourceLink = [User toUserIconUrl:user.userId];
            image.imageUid =  image.imageSourceLink;
            
            NSMutableArray* list = [[NSMutableArray alloc] initWithCapacity:2];
            [list addObject:image];
            DownloadNotificationObj* notif = [[DownloadNotificationObj alloc] init];
            notif.notificationKey = @"nowhere";
             
            ImageBatchRequest* request = [[ImageBatchRequest alloc] initWithForumImageList:list notifcationObj:notif];
            
            [[HttpService sharedHttpService]  downloadImageBatch:request];
        }
    }
}

-(IBAction)backClicked:(id)sender{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mainViewController gotoPreviousPage];
}
-(IBAction)leftClicked:(id)sender{
    [self.webview goBack];
}
-(IBAction)rightClicked:(id)sender{
    [self.webview goForward];
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
    self.loadingIndicator.hidden = FALSE;
    [self.loadingIndicator startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.loadingIndicator stopAnimating];
    self.loadingIndicator.hidden = TRUE;
    [self updateControlUI];
    self.currentUrl = [self.webview getCurrentPageURLStr];
 
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self.loadingIndicator stopAnimating];
    self.loadingIndicator.hidden = TRUE;
    [self updateControlUI];
}

#pragma  --end UIWebViewDelegate <NSObject>

-(BOOL)isForum{
    return  self.currentUrl && [self.currentUrl rangeOfString:@"http://www.xici.net/b"].location != NSNotFound ;
}

-(BOOL)isDiscussion{
    return  self.currentUrl && [self.currentUrl rangeOfString:@"http://www.xici.net/d"].location != NSNotFound ;
}

-(void)updateControlUI{
    BOOL isForum = [self isForum];
    BOOL isDiscussion = [self isDiscussion];
    if ( isForum ){
        self.addCommentsLabel.hidden = TRUE;
        self.addCommentsImage.hidden = TRUE;
        self.addPostImage.hidden = FALSE;
        self.addPostLabel.hidden = FALSE;
        self.saveLabel.hidden = FALSE;
        self.saveImage.hidden = FALSE;
        
        self.followLabel.hidden = TRUE;
        self.followImage.hidden = TRUE;
        
    }
    else if ( isDiscussion ){
        self.addCommentsLabel.hidden = FALSE;
        self.addCommentsImage.hidden = FALSE;
        self.addPostImage.hidden = TRUE;
        self.addPostLabel.hidden = TRUE;
        self.saveLabel.hidden = FALSE;
        self.saveImage.hidden = FALSE;
        
        self.followLabel.hidden = FALSE;
        self.followImage.hidden = FALSE;
    }
    else {
        self.addCommentsLabel.hidden = TRUE;
        self.addCommentsImage.hidden = TRUE;
        self.addPostImage.hidden = TRUE;
        self.addPostLabel.hidden = TRUE;
        self.saveLabel.hidden = TRUE;
        self.saveImage.hidden = TRUE;
        
        self.followLabel.hidden = TRUE;
        self.followImage.hidden = TRUE;
    }
}

-(void)showForumOrPost:(NSString*)url{
    self.currentUrl = url;
    [self.webview tryLoadUrl:url];
    [self updateControlUI];
}

@end
