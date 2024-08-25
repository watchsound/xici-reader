//
//  XiciDriver.m
//  西祠利器
//
//  Created by Hanning Ni on 11/24/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "XiciDriver.h"
#import "TFHpple.h"
#import "TFHppleElement.h"
#import "XPathQuery.h"
#import "XiciEncoder.h"
#import "NSString+Util.h"
#import "TextWithLoc.h"

@interface XiciDriver()

@end

@implementation XiciDriver

@synthesize sessionId = _sessionId;
@synthesize userid = _userid ;
@synthesize timer = _timer;
@synthesize topicTitle = _topicTitle;
@synthesize docTitle = _docTitle;;
@synthesize forumId = _forumId;// = "1123643";
@synthesize topicId = _topicId;//= "194914219"


+ (instancetype)sharedXiciDriver
{
    static dispatch_once_t onceToken;
    static XiciDriver * xiciDriver;
    dispatch_once(&onceToken, ^{
        xiciDriver = [[[self class] alloc] init];
    });
    return xiciDriver;
}


+(void)xiciDriverTest {
    XiciDriver* driver = [[XiciDriver alloc] init];
    
    
    NSString* username = @"heartskipsabeat";
    NSString* password = @"1qaz2wsx";
    
    if ([driver tryLoginXici:username :password]) {
        [driver reloadPageAfterLogin];
        [driver startPingProcess:driver.topicId];
        
        [driver addComments:driver.forumId :driver.topicId :@"test" ];
        
        [driver logoutXici];
    }
}

-(BOOL)loginXici:(NSString*)userName :(NSString*)password {
    self.forumId = @"1123643";
    self.topicId = @"194914219";
    if ([self tryLoginXici:userName :password]) {
        [self reloadPageAfterLogin];
        [self startPingProcess:nil];
        return TRUE;
    }
    return FALSE;
}

-(NSMutableURLRequest*) getNSMutableURLRequest:(NSString*)urlStr :(BOOL)isPost :(NSDictionary*)postBody {
    NSMutableArray *pairs = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSString *key in postBody) {
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, postBody[key]]];
    }
    /* We finally join the pairs of our array
     using the '&' */
    NSString *requestParams = [pairs componentsJoinedByString:@"&"];
    return [self getNSMutableURLRequest2:urlStr :isPost :requestParams];
}

-(NSMutableURLRequest*) getNSMutableURLRequest2:(NSString*)urlStr :(BOOL)isPost :(NSString*)postBody {
    NSURL * url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod: isPost? @"POST" :  @"GET"  ];
    
    [self addCommonHeader:request];
    
    if ( isPost && postBody != nil ){
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        [request setHTTPBody:[postBody dataUsingEncoding:enc]];
        NSString* requestDataLengthString = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)postBody.length];
        [request setValue:requestDataLengthString forHTTPHeaderField:@"Content-Length"];
    }
    return request;

}

-(NSData*)getHtmlData:(NSString*)urlStr :(BOOL)isPost :(NSString*)postBody{
    
    NSMutableURLRequest *request =  [self getNSMutableURLRequest2:urlStr :isPost :postBody];
    NSError *error;
    
    [request setTimeoutInterval:20];
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
   // NSArray* cookies =   [[NSHTTPCookieStorage sharedHTTPCookieStorage ]cookiesForURL:url];
    if(error)
    {
        NSLog(@"getHtmlData failed %@", error);
    }
    return data;
}


-(void) addCommonHeader: (NSMutableURLRequest*) request   {
    [request setValue:@"application/json, text/javascript, */*; q=0.01" forHTTPHeaderField:@"Accept"];
    [request setValue:@"ISO-8859-1,utf-8;q=0.7,*;q=0.3" forHTTPHeaderField:@"Accept-Charset"];
    [request setValue:@"gzip,deflate,sdch" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"en-US,en;q=0.8" forHTTPHeaderField:@"Accept-Language"];
     [request setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
     [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:@"www.xici.net" forHTTPHeaderField:@"Host"];
    [request setValue:@"http://www.xici.net" forHTTPHeaderField:@"Origin"];

   

    [request setValue:@"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.97 Safari/537.22" forHTTPHeaderField:@"User-Agent"];
    
    
    // post.addHeader("Accept",   "application/json, text/javascript, */*; q=0.01");
    
    
   
    
    
    
}


-(void) parseHtmlToGetTopicAndDocTitle:(NSData*)htmlCode{
       NSStringEncoding gbEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
       NSString *htmlStr = [[NSString alloc] initWithData:htmlCode encoding:gbEncoding]  ;
      NSString *utf8HtmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"charset=gb2312>"  withString:@"charset=utf-8"];
        NSData *htmlDataUTF8 = [utf8HtmlStr dataUsingEncoding:NSUTF8StringEncoding];
        TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:htmlDataUTF8];
    
        NSString* xPathExpression = @"//form[@name='DocLists']//input";
         NSArray *inputNodes = [tutorialsParser searchWithXPathQuery:xPathExpression];
     self.topicTitle = @"";
    self.docTitle = @"";
       for (TFHppleElement *element in inputNodes) {
            NSString* key =[element objectForKey:@"name"];
           if ( [@"" isEqualToString:key] ){
               self.topicTitle = [element objectForKey:@"value"];
                self.docTitle = [element objectForKey:@"value"];
           }
        }
    
        xPathExpression = @"//form[@name='DocLists']//textarea";
        inputNodes = [tutorialsParser searchWithXPathQuery:xPathExpression];
       for (TFHppleElement *element in inputNodes) {
          NSString* key =[element objectForKey:@"name"];
          if ( [@"" isEqualToString:key] ){
              self.topicTitle = [element objectForKey:@"value"];
              self.docTitle = [element objectForKey:@"value"];
          }
      }
    
}

-(NSString*) getXiciSessionID {
    if (self.sessionId.length < 2) {
       [self makeInitialRequest];
        //			String sessionTag = "var SessionID = ";
        //			int startIndex = html.indexOf(sessionTag);
        //			if (startIndex > 0) {
        //				startIndex = html.indexOf("'", startIndex);
        //				int endIndex = html.indexOf("';", startIndex);
        //				sessionId = html.substring(startIndex + 1, endIndex);
        //			}
    }
    return self.sessionId;
}


-(void)reloadPageAfterLogin{
   // NSString* sessionId = [self getXiciSessionID];
   // if (sessionId.length == 0)
    //    return;
    NSString* url = [NSString stringWithFormat:@"http://www.xici.net/d%@.htm", self.topicId];
    NSData* result = [self getHtmlData:url :FALSE  :nil];
    [self parseHtmlToGetTopicAndDocTitle:result];
   
}


-(NSData*) makeInitialRequest{
    NSString* url = [NSString stringWithFormat:@"http://www.xici.net/d%@.htm", self.topicId];
    NSMutableURLRequest *request =  [self getNSMutableURLRequest2:url :FALSE :nil];
     [request setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
    
    NSError *error;
    
    [request setTimeoutInterval:20];
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    // NSArray* cookies =   [[NSHTTPCookieStorage sharedHTTPCookieStorage ]cookiesForURL:url];
    if(error)
    {
        NSLog(@"getHtmlData failed %@", error);
    }
   
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
    {
        NSLog(@"name: '%@'\n",   [cookie name]);
        NSLog(@"value: '%@'\n",  [cookie value]);
        NSLog(@"domain: '%@'\n", [cookie domain]);
        NSLog(@"path: '%@'\n",   [cookie path]);
        if ( [[cookie name] isEqualToString:@"SessionID"] ){
            self.sessionId = [cookie value ];
        }
    }
    return data;
}


-(void) logoutXici {
    if (self.sessionId == nil || self.sessionId .length == 0)
       return;
   
        NSString* siteUrl = @"http://www.xici.net/api.asp?method=xici.token.logout";
        [self getHtmlData:siteUrl :TRUE :nil];
}

-(BOOL)tryLoginXici:(NSString*)username :(NSString*)password {
 
        NSString* siteUrl = @"http://www.xici.net/api.asp?method=xici.token.newlogon";
        XiciEncoder* encoder =   [[XiciEncoder alloc] init];
        NSString* sessionId = [self getXiciSessionID];
        if (sessionId == nil || sessionId.length == 0 )
            return false;
       NSLog(@ "sessionId = %@", sessionId);
        NSString*  encode1 = [encoder H2:password  :8];
    NSString*  encode1session = [NSString stringWithFormat:@"%@-%@", encode1, sessionId];
        NSString*  encode2 = [encoder H2: encode1session :8];
        NSLog(@ "encoder.H2(%@ :8) = %@",password, encode1);
    
       NSLog(@ " encoder H2(  %@ :8) = %@", encode1session, encode2);
        NSString* keycode = @"";// new Date().getTime() + "{$}";
        NSString* postBody = [NSString stringWithFormat:@"username=%@&Usercode=%@&autologon=1&keycode=%@&verifyimg=&ispoor=0",
                             username, encode2, keycode ];
    
        NSLog(@"%@", postBody);
        NSMutableURLRequest *request =  [self getNSMutableURLRequest2:siteUrl :TRUE :postBody];
        long long time = (long long)[[NSDate date] timeIntervalSince1970] * 1000;
    
         [request setValue: [NSString stringWithFormat:@"%@%lld", @"http://www.xici.net/user/loginbox.asp?login_type=logform&gotoUrl=&t=", time]  forHTTPHeaderField:@"Referer"];
    
        [request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With" ];
    
        NSError *error;
         [request setTimeoutInterval:20];
        NSURLResponse *response = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        // NSArray* cookies =   [[NSHTTPCookieStorage sharedHTTPCookieStorage ]cookiesForURL:url];
        if(error)
        {
             NSLog(@"tryLoginXici failed %@", error);
            return FALSE;
         }

        else {
            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            NSString* responseString = [[NSString alloc] initWithData:data encoding:enc];
            NSLog(@"login response %@", responseString);
            NSRange range  =  [responseString  rangeOfString:@"Userid"];
            if ( range.location == NSNotFound )
                return FALSE;
            TextWithLoc* userText = [responseString getText:@":" endTag:@",\"" startLoc:(int)range.location includeTag:FALSE];
            if ( userText == nil )
                return FALSE;
            self.userid = userText.content;
            return TRUE;
        }
}

-(void)startPingProcess:(NSString*)   topicId  {
    if ( self.timer != nil ){
        [self.timer invalidate];
        self.timer = nil;
    }
    NSMutableDictionary *cb = [[NSMutableDictionary alloc] init];
    [cb setObject:topicId forKey:@"topicId"];
    
    self.timer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(pingIt:) userInfo:cb repeats:TRUE];
    
}

-(void) pingIt:(NSTimer *)timer{
    NSString* sessionId = [self getXiciSessionID];
    if (sessionId == nil || sessionId.length == 0)
        return;
    NSDictionary *dict = [timer userInfo];
    NSString* topicId = [dict objectForKey:@"topicId"];
    NSString* siteUrl = [NSString stringWithFormat:@"http://www.xici.net/xiciservice/ping.asp?userid=%@&t=2&%lli", self.userid,  (long long)[[NSDate date] timeIntervalSince1970] * 1000 ];
    
    NSMutableURLRequest *request =  [self getNSMutableURLRequest2:siteUrl :false  :nil];
    
    if ( topicId != nil )
         [request setValue:[NSString stringWithFormat:@"%@%@",@"http://www.xici.net/b", topicId ] forHTTPHeaderField:@"Referer" ];
    [request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With" ];
    NSError *error;
    [request setTimeoutInterval:20];
    NSURLResponse *response = nil;
   // NSData *data =
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    // NSArray* cookies =   [[NSHTTPCookieStorage sharedHTTPCookieStorage ]cookiesForURL:url];
    if(error)
    {
        NSLog(@"pingIt failed %@", error);
    }
}


-(void)addComments:(NSString*) forumId  :(NSString*)topicId  :(NSString*)comments {
    XiciEncoder * encoder =   [[XiciEncoder  alloc] init];
  //  NSString* action =   [NSString stringWithFormat:@"/%@/doc_proc.asp" , forumId ];
    NSString* action2 =  [NSString stringWithFormat:@"/b%@/put.asp" , forumId ] ;
  //  NSString* action3 =  [NSString stringWithFormat:@"/b%@/put.asp?sub_id=%@" , forumId , topicId]; // 136081
    
   NSMutableDictionary* params =  [[NSMutableDictionary alloc] initWithCapacity:16];
    
    [params setObject:@"lDocId"  forKey: topicId];
    [params setObject:@"puttype"  forKey:@"1"];
    [params setObject:@"OpType"  forKey:@""];
    [params setObject:@"rate"  forKey:@"0"];
    [params setObject:@"lSubDoc"  forKey:@"0"];
    [params setObject:@"isEdit"  forKey:@"0"];
    [params setObject:@"DocVote_a"  forKey:@""];
    [params setObject:@"doc_type"  forKey:@"0"];
    [params setObject:@"refblock"  forKey:@""];
    [params setObject:@"doc_refer"  forKey:@""];
    [params setObject:@"refType"  forKey:@""];
    [params setObject:@"sTitle"  forKey:  [encoder TitleEncode: self.topicTitle ]];
    NSString * r = [encoder P:comments];
    NSLog(@" encoder.P(comments) %@",  r );
    NSString *  rr = [NSString stringWithFormat:@"%@-%@-%@", forumId, topicId, r];
    
    NSString* hvalue = [encoder H22:rr  :self.sessionId];
    NSLog(@" h =  %@",  hvalue);
    
    [params setObject:@"h" forKey: hvalue];
    [params setObject:@"reAndRef" forKey:@""];
    [params setObject:@"doc_title" forKey: self.docTitle];
    [params setObject:@"doc_text" forKey: [comments stringByAppendingString: @"\n" ]];
    [params setObject:@"doctext"  forKey: [comments stringByAppendingString:@"\n%^@!*$"] ];
    
   
        NSString* siteUrl = @"http://www.xici.net";
        
     //   NSString* sessionId =  [self getXiciSessionID];
    
    NSMutableURLRequest *request =  [self getNSMutableURLRequest:[siteUrl stringByAppendingString:action2] :TRUE  :params];
    
     [request setValue:@"max-age=0" forHTTPHeaderField:@"Cache-Control"];
       [request setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
     [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
     [request setValue:[NSString stringWithFormat:@"http://www.xici.net/d%@.htm", topicId ] forHTTPHeaderField:@"Referer"];
    [request setValue:@"ISO-8859-1,utf-8;q=0.7,*;q=0.3" forHTTPHeaderField:@"Accept-Charset"];
    [request setValue:@"gzip,deflate,sdch" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"en-US,en;q=0.8" forHTTPHeaderField:@"Accept-Language"];
  ///  [request setValue:@"" forHTTPHeaderField:@""];
//[request setValue:@"" forHTTPHeaderField:@""];
    
    NSError *error;
    [request setTimeoutInterval:20];
    NSURLResponse *response = nil;
  //  NSData *data =
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    // NSArray* cookies =   [[NSHTTPCookieStorage sharedHTTPCookieStorage ]cookiesForURL:url];
    if(error)
    {
        NSLog(@"pingIt failed %@", error);
    }
    else {
        
    }
}

@end
