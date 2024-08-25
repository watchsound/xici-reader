//
//  AnywhereWebview.m
//  AnywhereReader
//
//  Created by du on 3/18/12.
//  Copyright (c) 2012 WatchSound. All rights reserved.
//

#import "AnywhereWebview.h"
#import "Util.h"
#import "TextWithLoc.h"
#import "NSString+Util.h"

@implementation AnywhereWebview

@synthesize webDelegate;

- (id)init {
    self = [super init];
	if ( self ){
        self.delegate = self;
	}
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
	if ( self ){
        self.delegate = self;
	}
    return self;
}


-(id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if ( self ){
        self.delegate = self;
	}
    return self;
}


#pragma mark - UIWebViewDelegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)req navigationType:(UIWebViewNavigationType)navigationType{
 
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    if (webDelegate && [(id)webDelegate respondsToSelector:@selector(webViewDidStartLoad:)])
        [webDelegate webViewDidStartLoad:webView];
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    if (webDelegate && [(id)webDelegate respondsToSelector:@selector(webViewDidFinishLoad:)])
        [webDelegate webViewDidFinishLoad:webView];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    if (webDelegate && [(id)webDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
        [webDelegate webView:webView didFailLoadWithError:error];
}

-(void)adjustSize{
    NSString *offsetHeight = [self stringByEvaluatingJavaScriptFromString:@"document.height"];
    if( offsetHeight != nil ){
        int height = [[NSDecimalNumber decimalNumberWithString:offsetHeight] intValue];
        if ( height > 400)
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                height);
    }
}

- (NSString*)getTitleForCurrentPage{
    return [self stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (NSString*)getSelectionForCurrentPage{
    return [self stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
}

-(NSString*)getForumTitle{
    NSString *  scripting = @"function getForumTitle() {\
    var metas = document.getElementsByTagName('meta');\
     for (i=0; i<metas.length; i++) {\
        if (metas[i].getAttribute(\"name\") == \"keywords\") {\
            return metas[i].getAttribute(\"content\");\
        }\
    }\
    return "";\
     } ";
      [self stringByEvaluatingJavaScriptFromString:scripting];
   return [self stringByEvaluatingJavaScriptFromString:@"getForumTitle();"];
}

-(NSString*)getForumDescription{
    NSString* scripting = @"function getForumDescription() {\
    var metas = document.getElementsByTagName('meta');\
    for (i=0; i<metas.length; i++) {\
    if (metas[i].getAttribute(\"name\") == \"description\") {\
    return metas[i].getAttribute(\"content\");\
    }\
    }\
    return "";\
    } ";
     [self stringByEvaluatingJavaScriptFromString:scripting];
     return [self stringByEvaluatingJavaScriptFromString:@"getForumDescription();"];
}

-(NSString*)getDiscussionTitle{
    return [self getForumDescription];
}

-(User*)getPostAuthorInfo{
    NSString *htmlString = [self stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
    
    User*  user = [[User alloc] init];
    TextWithLoc* field =  [htmlString getText:@"\"UserID\":"  endTag:@"," startLoc:0   includeTag:FALSE];
     if ( field == nil || field.content == nil )
           return nil;
    user.userId = field.content;
    
    field =    [htmlString getText:@"\"UserName\":\""  endTag:@"\"" startLoc:field.range.location + field.range.length +1  includeTag:FALSE];
    
    if ( field == nil || field.content == nil )
        return nil;
    user.userName = field.content;
    
    return user;
}

- (NSString*)getTextContentForCurrentPage{
    //    function stripTextOnlyFromWholePage(html)
    //    {
    //        var tmp = document.createElement("DIV");
    //        tmp.innerHTML = html;
    //        return tmp.textContent||tmp.innerText;
    //    }
    //  return [self stringByEvaluatingJavaScriptFromString:@"document.documentElement.textContent"];
    
    [self stringByEvaluatingJavaScriptFromString:@"function stripTextOnlyFromWholePage(html)"
     "{var tmp = document.createElement(\"DIV\");"
     "tmp.innerHTML = html;"
     " return tmp.textContent||tmp.innerText;}"];
    return [self stringByEvaluatingJavaScriptFromString:@"stripTextOnlyFromWholePage(document.documentElement.innerText);"];
}

-(void)saveWebview:(UIWebView *)webView{
    [webView stringByEvaluatingJavaScriptFromString:@"var script = document.createElement('script');"
     "script.type = 'text/javascript';"
     "script.text = \"function myFunction() { "
     " var images = document.getElementsByTagName('img'); "
     " var imagesrc = '';  "
     " for (var i=0; i<images.length; i++) { "
     "    var url = images[i].src;   "
     "    if (url.length>0) {   "
     "        imagesrc += '|' + url;   "
     "    }  "
     " }  "
     " return imagesrc; "
     "}\";"
     "document.getElementsByTagName('head')[0].appendChild(script);"];
    
    NSString* imgUrls=[webView stringByEvaluatingJavaScriptFromString:@"myFunction();"];
    NSArray* imageUrls = [imgUrls componentsSeparatedByString:@"|"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    
    
    for (int i =1; i < [imageUrls count]; i++){
        NSString* imageUrl = [imageUrls objectAtIndex:i];
        NSArray* imageNamePart = [imageUrl componentsSeparatedByString:@"/"];
        NSString* imageName = [imageNamePart objectAtIndex:[imageNamePart count] -1];
        NSString *myPath = [cachesDirectory stringByAppendingPathComponent:imageName];
        
        NSData* localdata =  [NSData dataWithContentsOfFile:myPath];
        if ( localdata == nil || [localdata length] == 0 ){
            NSURL *_url = [NSURL URLWithString:imageUrl];
            NSData *urlData = [NSData dataWithContentsOfURL:_url];
            [urlData writeToFile:myPath atomically:YES];
        }
    }
}

-(NSString*)getCurrentPageURLStr{
    return [self stringByEvaluatingJavaScriptFromString:
            @"document.URL"];
}

-(NSString*)getHtmlCode{
    return [self stringByEvaluatingJavaScriptFromString:
            @"document.body.innerHTML"];
}
-(NSString*)getVideoURL{
    //  NSLog(@"page = %@", [self  getHtmlCode]);
    NSString* url = [self getURLForYouTubeVideo];
    NSLog(@"url = %@", url);
    if ( [url length] > 3 && ![url hasPrefix:@"http:"]){
        NSString* curPageUrl = [self getCurrentPageURLStr];
        if ( [curPageUrl hasPrefix:@"http:"]){
            NSRange range  =  [curPageUrl  rangeOfString:@".com" options:NSCaseInsensitiveSearch];
            if ( range.location != NSNotFound ){
                url = [[[curPageUrl componentsSeparatedByString:@".com"] objectAtIndex:0] stringByAppendingFormat:@".com/%@",  url ];
            }
        }
    }
      NSLog(@"url2 = %@", url);
    return url;
}
-(NSString*)getURLForYouTubeVideo{
    NSString* url =  [self stringByEvaluatingJavaScriptFromString:@"function getURL() {  var video = document.getElementsByTagName('video')[0]; return video.getAttribute('src');} getURL();"];
    
    if ( ![Util isEmptyString:url minSize:20] ){
         if( [url  rangeOfString:@".m3u8" options:NSCaseInsensitiveSearch].location != NSNotFound  )
        return url;
        if( [url  rangeOfString:@".mp4" options:NSCaseInsensitiveSearch].location != NSNotFound )
            return url;
    }
    url =  [self stringByEvaluatingJavaScriptFromString:@"function getURL() {  var video = document.getElementsByTagName('video')[0];  var source = video.getElementsByTagName('source')[0] ; return source.getAttribute('src');} getURL();"];
    if ( ![Util isEmptyString:url minSize:20] ){
       if( [url  rangeOfString:@".m3u8" options:NSCaseInsensitiveSearch].location != NSNotFound  )
            return url;
        if( [url  rangeOfString:@".mp4" options:NSCaseInsensitiveSearch].location != NSNotFound )
            return url;
    }
        
    NSString* htmlcode = [self getHtmlCode];
    NSRange range  =  [htmlcode  rangeOfString:@".mp4" options:NSCaseInsensitiveSearch];
    if ( range.location != NSNotFound ){
        int endLoc = range.location + range.length;
        range.length = range.location;
        range.location = 0;
        range  =  [htmlcode  rangeOfString:@"\"" options:NSBackwardsSearch range:range];
        
        range.location = range.location + 1;
        range.length = endLoc - range.location;
      
        url = [htmlcode substringWithRange:range];
              return url;
    }
    range  =  [htmlcode  rangeOfString:@".m3u8" options:NSCaseInsensitiveSearch];
    if ( range.location != NSNotFound ){
        int endLoc = range.location + range.length;
        range.length = range.location;
        range.location = 0;
        range  =  [htmlcode  rangeOfString:@"\"" options:NSBackwardsSearch range:range];
        
        range.location = range.location + 1;
        range.length = endLoc - range.location;
        url = [htmlcode substringWithRange:range];
            return url;
    }
    return @"";
}

-(NSString*)getTitleForYourTubeVideo{
    // NSLog(@" %@",  [self getHtmlCode]);
    return[self getTitleForCurrentPage];
    //for youtube .. we dont have it..
 return [self stringByEvaluatingJavaScriptFromString:@"function getTitle() {var kt = document.getElementsByClassName('kt'); if (kt.length) {return kt[0].innerHTML;} else  { var jm = document.getElementsByClassName('jm'); if (jm.length) {return jm[0].innerHTML;}   var lp = document.getElementsByClassName('lp')[0]; return lp.childNodes[0].innerHTML;}} getTitle();"];
}

-(NSString*)getTitleFromChannel{
    return [self stringByEvaluatingJavaScriptFromString:@"function getTitleFromChannel() {var video_title = document.getElementById('video_title'); return video_title.childNodes[0].innerHTML;} getTitleFromChannel();"];
}

-(void)tryLoadUrl:(NSString*)url{
    if ( [url rangeOfString:@"http://"].location == NSNotFound ){
        if ( [url rangeOfString:@"/"].location == 0 )
            url = [@"http://www.xici.net" stringByAppendingString:url];
        else
            url = [@"http://www.xici.net/" stringByAppendingString:url];
    }
     [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60]];
}


@end
