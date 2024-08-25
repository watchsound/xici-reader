//
//  AnywhereWebview.h
//  AnywhereReader
//
//  Created by du on 3/18/12.
//  Copyright (c) 2012 Watch Sound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface AnywhereWebview : UIWebView<UIAlertViewDelegate,UIWebViewDelegate>{
    id<UIWebViewDelegate> webDelegate;
}
@property (retain)  id<UIWebViewDelegate>webDelegate;

- (NSString*)getTitleForCurrentPage;
- (NSString*)getSelectionForCurrentPage;
- (NSString*)getTextContentForCurrentPage;

-(NSString*)getVideoURL;
-(NSString*)getURLForYouTubeVideo;
-(NSString*)getTitleForYourTubeVideo;
-(NSString*)getTitleFromChannel;
-(NSString*)getHtmlCode;

-(NSString*)getCurrentPageURLStr;
-(NSString*)getForumTitle;
-(NSString*)getForumDescription;
-(NSString*)getDiscussionTitle;

-(User*)getPostAuthorInfo;

-(void)adjustSize;


-(void)tryLoadUrl:(NSString*)url;

@end
