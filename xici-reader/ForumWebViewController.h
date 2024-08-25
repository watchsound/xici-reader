//
//  ForumWebViewController.h
//  西祠利器
//
//  Created by Hanning Ni on 12/1/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnywhereWebView.h"

@interface ForumWebViewController : UIViewController<UIWebViewDelegate>

@property (retain) IBOutlet AnywhereWebview* webview;

@property (retain) IBOutlet UIImageView* addCommentsImage;
@property (retain) IBOutlet UILabel*     addCommentsLabel;


@property (retain) IBOutlet UIImageView* addPostImage;
@property (retain) IBOutlet UILabel*     addPostLabel;

@property (retain) IBOutlet UIImageView* saveImage;
@property (retain) IBOutlet UILabel*     saveLabel;

@property (retain) IBOutlet UIImageView* followImage;
@property (retain) IBOutlet UILabel*     followLabel;

@property (retain) IBOutlet UIActivityIndicatorView*  loadingIndicator;


@property (nonatomic, strong) IBOutlet UIImageView* bgone;
@property (nonatomic, strong) IBOutlet UIImageView* bgtwo;

-(IBAction)addCommentClicked:(id)sender;
-(IBAction)addPostClicked:(id)sender;
-(IBAction)saveClicked:(id)sender;
-(IBAction)followClicked:(id)sender;


-(IBAction)backClicked:(id)sender;

-(IBAction)leftClicked:(id)sender;
-(IBAction)rightClicked:(id)sender;

-(void)showForumOrPost:(NSString*)url;

@end
