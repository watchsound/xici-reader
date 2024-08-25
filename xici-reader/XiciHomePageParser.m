//
//  XiciHomePageParser.m
//  西祠利器
//
//  Created by Hanning Ni on 11/22/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "XiciHomePageParser.h"
#import "HttpService.h"
#import "TopMapImgItem.h"
#import "NSString+Util.h"
#import "TextWithLoc.h"
#import "Util.h"
#import "NSObject+R9SBJson.h"
#import "Discussion.h"
#import "Forum.h"
#import "TFHpple.h"
#import "TFHppleElement.h"
#import "NSString+Util.h"

@implementation XiciHomePageParser

@synthesize  originalHtmlData;
@synthesize  originalHtmlString;
@synthesize  topMapImageList;
@synthesize  categoryHomeList;

+ (instancetype)sharedHomePageParser
{
    static dispatch_once_t onceToken;
    static XiciHomePageParser * homeParser  ;
    dispatch_once(&onceToken, ^{
        homeParser = [[[self class] alloc] init];
        homeParser.categoryHomeList = [[NSMutableDictionary alloc] init];
    });
    return homeParser;
}


-(void)loadXiciHomePage{
    [self.categoryHomeList removeAllObjects];
    self.originalHtmlData= [[HttpService sharedHttpService] getHtmlData:@"http://www.xici.net"];
   //  NSStringEncoding enc = NSUTF8StringEncoding;
    
     NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    self.originalHtmlString = [[NSString alloc] initWithData:self.originalHtmlData encoding:enc];
    
}

-(CategoryHome*)getCategoryHome:(NSString*)category{
    return [self.categoryHomeList objectForKey:category];
}
-(void)setCategoryHome:(NSString*)category home:(CategoryHome*)home{
    [self.categoryHomeList setObject:home forKey:category];
}


-(void)downloadForum:(Forum*)forum  notificationKey:(NSString*)notificationKey{
    [[HttpService sharedHttpService]  downloadWithUrl:forum.forumId key:forum.category  parameters:nil isPost:FALSE requestKey: notificationKey   delegate: self ];
}

#pragma mark -
#pragma mark HtmlDownloaderOpDelegate <NSObject>

-(void)finishDownloadHtml:(HtmlDownloaderOp *)downloader{
    if ( downloader.result ){
        CategoryHome* home =  [[XiciHomePageParser sharedHomePageParser] populateCategoryHomeFromJson:downloader.result url:downloader.url category:downloader.key];
        if ( home.category )
           [self setCategoryHome:home.category home:home];
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys: home,    @"result",  nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:downloader.requestKey
															object:self
														  userInfo:info];
    } else {
        NSLog(@" fetch data failed on CategoryThumbnailRegularViewController");
    }
}

-(NSString*)getCategoryJsonStart:(NSString*)url{
    NSString* startTag = @"var clubdata =";
     if ( [url   rangeOfString: @"http://www.xici.net/owner" ].location != NSNotFound)
        startTag = @"owner_data =";
    return  startTag;
}

-(CategoryHome*)populateCategoryHomeFromJson:(NSData*) result  url:(NSString*)url  category:(NSString*)category{
    NSStringEncoding enc =  CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString* responseString = [[NSString alloc] initWithData:result encoding:enc];
      CategoryHome* home = [[CategoryHome alloc] init];
    home.category = category;
    if ( [url   rangeOfString: @"http://www.xici.net/baby" ].location != NSNotFound){
        NSMutableArray* topImageList = [self extractTopMapImageItemsFromHref:responseString];
        if( [topImageList count] > 0 ){
           
            home.topMapImageList = topImageList ;
            [self.categoryHomeList setObject:home forKey:category];
            return home;
        }
    }
    if ( [url   rangeOfString: @"http://www.xici.net/travel" ].location != NSNotFound){
        NSMutableArray* topImageList = [self extractTopMapImageItemsFromTravel:responseString];
        if( [topImageList count] > 0 ){
             home.topMapImageList = topImageList ;
            [self.categoryHomeList setObject:home forKey:category];
            return home;
        }
    }
    
    if ( [url   rangeOfString: @"http://www.xici.net/life" ].location != NSNotFound){
         return  [self extractTopMapImageItemsFromLIFE:responseString category:category];
    }
    
    NSString* startTag = [self getCategoryJsonStart:url];
    NSString* endTag =  @"\"main\": {";
    
    if ( [url   rangeOfString: @"http://www.xici.net/jiong" ].location != NSNotFound){
         endTag =  @"\"hotsort\": ";
    }
    
    
    NSString* clubdata =  [responseString getText:startTag endTag:endTag startLoc:0 includeTag:FALSE].content;
    
    clubdata = [clubdata stringByReplacingOccurrencesOfString:endTag withString:@""];
    clubdata = [clubdata stringByReplacingOccurrencesOfString:@"]," withString:@"]" options:NSCaseInsensitiveSearch range: NSMakeRange(clubdata.length - 20, 20)];
    clubdata = [clubdata stringByReplacingOccurrencesOfString:@"}," withString:@"}" options:NSCaseInsensitiveSearch range: NSMakeRange(clubdata.length - 20, 20)];
    clubdata = [clubdata stringByAppendingString:@"} }"];
    NSDictionary * resultJson =  (NSDictionary *)[[clubdata dataUsingEncoding:enc] JSONValue];
    
    if (resultJson == nil){
        NSMutableArray* topImageList = [self extractTopMapImageItems:responseString];
        if( [topImageList count] > 0 ){
            home.topMapImageList = topImageList ;
            [self.categoryHomeList setObject:home forKey:category];
            return home;
        }
        return home;
    }
    
    //hotboard
    NSMutableArray* hotboardList = [[NSMutableArray alloc] initWithCapacity:8];
    
  //   NSString* category = [[[resultJson objectForKey:@"result"] objectForKey:@"club"] objectForKey:@"clubname"];
  //  if ( category )
   //     home.category = category;
    
    NSArray*  hotboard = [[resultJson objectForKey:@"result"] objectForKey:@"hotboard"];
    for (int i = 0; i < [hotboard count]; i++ ){
        NSDictionary*  hot = [hotboard objectAtIndex:i];
       // Discussion* discussion = [[Discussion alloc] init];
        Forum*  forum = [[Forum alloc] init];
        forum.forumId =  [hot objectForKey:@"bid"];
        forum.forumTitle = [hot objectForKey:@"bltitle"];
        forum.category = category;
        [hotboardList addObject:forum];
    }
    home.hotboard = hotboardList;
    
    NSMutableArray* hotflyList = [[NSMutableArray alloc] initWithCapacity:8];
    
    NSArray*  hotfly = [[resultJson objectForKey:@"result"] objectForKey:@"hotfly"];
    for (int i = 0; i < [hotfly count]; i++ ){
        NSDictionary*  hot = [hotfly objectAtIndex:i];
        // Discussion* discussion = [[Discussion alloc] init];
        Discussion*  discussion = [[Discussion alloc] init];
        discussion.forumId =  [hot objectForKey:@"bid"];
        discussion.title = [hot objectForKey:@"docltitle"];
        [discussion setDiscussionId: [hot objectForKey:@"docurl"]];
        discussion.defaultImageUrl = [hot objectForKey:@"imgurl"];
        [hotflyList addObject:discussion];
    }
    home.hotfly = hotflyList;
    
    NSMutableArray* hotpicList = [[NSMutableArray alloc] initWithCapacity:8];
    
    NSArray*  hotpic = [[resultJson objectForKey:@"result"] objectForKey:@"hotpic"];
    for (int i = 0; i < [hotpic count]; i++ ){
        NSDictionary*  hot = [hotpic objectAtIndex:i];
        // Discussion* discussion = [[Discussion alloc] init];
        Discussion*  discussion = [[Discussion alloc] init];
        discussion.forumId =  [hot objectForKey:@"bid"];
         discussion.title = [hot objectForKey:@"docltitle"];
        [discussion setDiscussionId: [hot objectForKey:@"docurl"]];
        discussion.defaultImageUrl = [hot objectForKey:@"imgurl"];
        [hotpicList addObject:discussion];
    }
    home.hotpic = hotpicList;
    
    NSMutableArray* hotsortList = [[NSMutableArray alloc] initWithCapacity:8];
    
    NSArray*  hotsort = [[resultJson objectForKey:@"result"] objectForKey:@"hotsort"];
    for (int i = 0; i < [hotsort count]; i++ ){
        NSDictionary*  hot = [hotsort objectAtIndex:i];
        // Discussion* discussion = [[Discussion alloc] init];
        Discussion*  discussion = [[Discussion alloc] init];
        discussion.forumId =  [hot objectForKey:@"bid"];
        discussion.title = [hot objectForKey:@"docltitle"];
        [discussion setDiscussionId: [hot objectForKey:@"docurl"]];
        discussion.defaultImageUrl = [hot objectForKey:@"imgurl"];
        [hotsortList addObject:discussion];
    }
    home.hotsort = hotsortList;
    
    [self.categoryHomeList setObject:home forKey:category];
    
    return home;
}

-(NSMutableArray*)extractTopMapImageItemsForHomePage{
    if ( self.originalHtmlString == nil || self.originalHtmlString.length == 0 )
        return nil;
    
    self.topMapImageList = [self extractTopMapImageItems:self.originalHtmlString];
    
    return self.topMapImageList;
}


-(NSMutableArray*)extractTopMapImageItems2:(NSString*) htmlString{
   
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:8];
    NSString* startTag = @"TopMap.AddImgItem(";
    NSString* endTag = @");";
    TextWithLoc* textWithLoc = nil;
    do {
        int startLoc = textWithLoc == nil ? 0 :  textWithLoc.range.location + 2;
        textWithLoc =    [htmlString getText:startTag  endTag:endTag startLoc:startLoc   includeTag:FALSE];
       // NSLog(@"extractTopMapImageItems, %@", textWithLoc);
        if ( textWithLoc == nil || textWithLoc.content == nil )
            break;
        NSString*  startTagForField = @"'";
        NSString*  endTagForField = @"',";
        //int startLocForField = 0;
        TopMapImgItem* item = [[TopMapImgItem alloc] init];
       // item.imageUid = [Util generateShortUUID];
        TextWithLoc* field =    [textWithLoc.content getText:startTagForField  endTag:endTagForField startLoc:0   includeTag:FALSE];
        if (field == nil || field.content == nil )
            continue;
        item.articleSourceLink = field.content;
        
        field =    [textWithLoc.content getText:startTagForField  endTag:endTagForField startLoc:field.range.location + field.range.length +1  includeTag:FALSE];
        if (field == nil || field.content == nil )
            continue;
        item.imageSourceLink = field.content;
        item.imageUid = [ForumImage  sourceLinkToUid :item.imageSourceLink];
        
        field =    [textWithLoc.content getText:startTagForField  endTag:endTagForField startLoc:field.range.location + field.range.length +1  includeTag:FALSE];
        if (field == nil || field.content == nil )
            continue;
        
        if ( [field.content rangeOfString: @"http://"] .location == NSNotFound  ){
              item.headline = field.content;
        } else {
            item.imageThumbnailLink = field.content;
            field =    [textWithLoc.content getText:startTagForField  endTag:endTagForField startLoc:field.range.location + field.range.length +1  includeTag:FALSE];
           
            item.headline = field.content;
        }
       
        [result addObject:item];
        
    } while (1);
    
    return result;
}

-(NSMutableArray*)extractTopMapImageItems:(NSString*) htmlString
{
    NSString* startTag = @"scrollChannel";
    
    NSString* endTag = @"scroll_label";
    
    return [self extractTopMapImageItemsFromHref:htmlString start:startTag end:endTag];
}

-(NSMutableArray*)extractTopMapImageItemsFromHref:(NSString*) htmlString
{
    NSString* startTag = @"<div class=\"house_imgs\">";
    
    NSString* endTag = @"<div class=\"house_img_num\">";
    
    return [self extractTopMapImageItemsFromHref:htmlString start:startTag end:endTag];
}

-(NSMutableArray*)extractTopMapImageItemsFromHref:(NSString*) htmlString start:(NSString*)startTag end:(NSString*)endTag
{
    
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:8];
  
    TextWithLoc* textWithLoc =  [htmlString getText:startTag  endTag:endTag startLoc:0   includeTag:FALSE];
    if( textWithLoc == nil || textWithLoc.content == nil)
        return result;
    htmlString = textWithLoc.content;
    
    TextWithLoc* field = nil;
    do {
        int startLoc = field == nil ? 0 :  field.range.location + 2;
        field =    [htmlString getText:@" href=\""  endTag:@"\" " startLoc:startLoc   includeTag:FALSE];
        if ( field == nil || field.content == nil )
            break;
        //int startLocForField = 0;
        TopMapImgItem* item = [[TopMapImgItem alloc] init];
        item.articleSourceLink = field.content;
        
        field =    [htmlString getText:@"title=\""  endTag:@"\" " startLoc:field.range.location + field.range.length +1  includeTag:FALSE];
        if (field == nil || field.content == nil )
            continue;
        item.headline = field.content;
       
         field =    [textWithLoc.content getText:@"<img src=\""  endTag:@"\" " startLoc:field.range.location + field.range.length +1  includeTag:FALSE];
        
        if (field == nil || field.content == nil )
            continue;
        item.imageSourceLink = field.content;
         item.imageUid = [ForumImage  sourceLinkToUid :item.imageSourceLink];
        
        
        [result addObject:item];
        
    } while (1);
    
    return result;
}

-(NSMutableArray*)extractTopMapImageItemsFromTravel:(NSString*) htmlString{
    
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:8];
    NSString* startTag = @"\"eachbox_result\":";
    
    NSString* endTag = @"}]},";
    
    TextWithLoc* textWithLoc =  [htmlString getText:startTag  endTag:endTag startLoc:0   includeTag:FALSE];
    if( textWithLoc == nil || textWithLoc.content == nil)
        return result;
    htmlString = [textWithLoc.content copy];
    
    TextWithLoc* field = nil;
    do {
        int startLoc = field == nil ? 0 :  field.range.location + 2;
        field =    [htmlString getText:@"\"docurl\":\""  endTag:@"\"" startLoc:startLoc   includeTag:FALSE];
        if ( field == nil || field.content == nil )
            break;
        //int startLocForField = 0;
        TopMapImgItem* item = [[TopMapImgItem alloc] init];
        item.articleSourceLink = field.content;
        
        field =    [textWithLoc.content getText:@"\"imgurl\":\""  endTag:@"\"" startLoc:field.range.location + field.range.length +1  includeTag:FALSE];
        
        if (field == nil || field.content == nil )
            continue;
        item.imageSourceLink = field.content;
        item.imageUid = [ForumImage  sourceLinkToUid :item.imageSourceLink];
        
        field =    [htmlString getText:@"\"title\":\""  endTag:@"\"" startLoc:field.range.location + field.range.length +1  includeTag:FALSE];
        if (field == nil || field.content == nil )
            continue;
        item.headline = field.content;
        
        
        [result addObject:item];
        
    } while (1);
    
    return result;
}

-(CategoryHome*)extractTopMapImageItemsFromLIFE:(NSString*) htmlString  category:(NSString*)category{
    CategoryHome* home = [[CategoryHome alloc] init];
     NSStringEncoding enc =  CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString* startTag =  @"pageData = ";
    NSString* endTag =  @"]}}};";
    
    NSString* clubdata =  [htmlString getText:startTag endTag:endTag startLoc:0 includeTag:FALSE].content;
    clubdata = [clubdata stringByAppendingString:@"]}}}"];
    NSDictionary * resultJson =  (NSDictionary *)[[clubdata dataUsingEncoding:enc] JSONValue];
    
    //hotboard
    NSMutableArray* hotboardList = [[NSMutableArray alloc] initWithCapacity:8];
    
    //   NSString* category = [[[resultJson objectForKey:@"result"] objectForKey:@"club"] objectForKey:@"clubname"];
    //  if ( category )
    //     home.category = category;
    
    NSArray*  hotboard = [[[resultJson objectForKey:@"result"] objectForKey:@"city"] objectForKey:@"pos1"];
    for (int i = 0; i < [hotboard count]; i++ ){
        NSDictionary*  hot = [hotboard objectAtIndex:i];
        Discussion*  discussion = [[Discussion alloc] init];
        discussion.forumId =  [hot objectForKey:@"bid"];
        discussion.title = [hot objectForKey:@"docltitle"];
        [discussion setDiscussionId: [hot objectForKey:@"docurl"]];
        discussion.defaultImageUrl = [hot objectForKey:@"imgurl"];
        
        [hotboardList addObject:discussion];
    }
//    hotboard = [[[resultJson objectForKey:@"result"] objectForKey:@"city"] objectForKey:@"pos2"];
//    for (int i = 0; i < [hotboard count]; i++ ){
//        NSDictionary*  hot = [hotboard objectAtIndex:i];
//        Discussion*  discussion = [[Discussion alloc] init];
//        discussion.forumId =  [hot objectForKey:@"bid"];
//        discussion.title = [hot objectForKey:@"docltitle"];
//        [discussion setDiscussionId: [hot objectForKey:@"docurl"]];
//        discussion.defaultImageUrl = [hot objectForKey:@"imgurl"];
//        
//        [hotboardList addObject:discussion];
//    }
//    hotboard = [[[resultJson objectForKey:@"result"] objectForKey:@"city"] objectForKey:@"pos3"];
//    for (int i = 0; i < [hotboard count]; i++ ){
//        NSDictionary*  hot = [hotboard objectAtIndex:i];
//        Discussion*  discussion = [[Discussion alloc] init];
//        discussion.forumId =  [hot objectForKey:@"bid"];
//        discussion.title = [hot objectForKey:@"docltitle"];
//        [discussion setDiscussionId: [hot objectForKey:@"docurl"]];
//        discussion.defaultImageUrl = [hot objectForKey:@"imgurl"];
//        
//        [hotboardList addObject:discussion];
//    }
    
    home.hotboard = hotboardList;
    
    NSMutableArray* hotflyList = [[NSMutableArray alloc] initWithCapacity:8];
    
    NSArray*  hotfly = [[[resultJson objectForKey:@"result"] objectForKey:@"it"] objectForKey:@"pos1"];
    for (int i = 0; i < [hotfly count]; i++ ){
        NSDictionary*  hot = [hotfly objectAtIndex:i];
        // Discussion* discussion = [[Discussion alloc] init];
        Discussion*  discussion = [[Discussion alloc] init];
        discussion.forumId =  [hot objectForKey:@"bid"];
        discussion.title = [hot objectForKey:@"docltitle"];
        [discussion setDiscussionId: [hot objectForKey:@"docurl"]];
        discussion.defaultImageUrl = [hot objectForKey:@"imgurl"];
        [hotflyList addObject:discussion];
    }
    
    
    home.hotfly = hotflyList;
    
    NSMutableArray* hotpicList = [[NSMutableArray alloc] initWithCapacity:8];
    
    NSArray*  hotpic = [[[resultJson objectForKey:@"result"] objectForKey:@"shop"] objectForKey:@"pos1"];
    for (int i = 0; i < [hotpic count]; i++ ){
        NSDictionary*  hot = [hotpic objectAtIndex:i];
        // Discussion* discussion = [[Discussion alloc] init];
        Discussion*  discussion = [[Discussion alloc] init];
        discussion.forumId =  [hot objectForKey:@"bid"];
        discussion.title = [hot objectForKey:@"docltitle"];
        [discussion setDiscussionId: [hot objectForKey:@"docurl"]];
        discussion.defaultImageUrl = [hot objectForKey:@"imgurl"];
        [hotpicList addObject:discussion];
    }
    home.hotpic = hotpicList;
    
    NSMutableArray* hotsortList = [[NSMutableArray alloc] initWithCapacity:8];
    
    NSArray*  hotsort = [[[resultJson objectForKey:@"result"] objectForKey:@"shop"] objectForKey:@"pos2"];
    for (int i = 0; i < [hotsort count]; i++ ){
        NSDictionary*  hot = [hotsort objectAtIndex:i];
        // Discussion* discussion = [[Discussion alloc] init];
        Discussion*  discussion = [[Discussion alloc] init];
        discussion.forumId =  [hot objectForKey:@"bid"];
        discussion.title = [hot objectForKey:@"docltitle"];
        [discussion setDiscussionId: [hot objectForKey:@"docurl"]];
        discussion.defaultImageUrl = [hot objectForKey:@"imgurl"];
        [hotsortList addObject:discussion];
    }
    home.hotsort = hotsortList;
    
    [self.categoryHomeList setObject:home forKey:category];
    
    return home;

}

-(int)parseIntValue:(NSString*)description{
   description = [description stringByReplacingOccurrencesOfString:@"人" withString:@""];
    BOOL hasThounds = FALSE;
    if ( [description rangeOfString:@"万"].location != NSNotFound  ){
         hasThounds = TRUE;
         description = [description stringByReplacingOccurrencesOfString:@"万" withString:@""];
    }
    int value = 0;
    @try {
        value = [description intValue];
    }
    @catch (NSException *exception) {
        
    }
    if ( hasThounds )
        value = value * 10000;
    
    return value;
}

-(NSString*)normalizeString:(NSString*)result{
    result = [result stringByConvertingHTMLToPlainText];
    result = [result stringByReplacingOccurrencesOfString:@" " withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return result;
}

-(NSMutableArray*)parseSearchResult:(NSData*)data{
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:16];
    NSStringEncoding enc =  CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString* htmlString = [[NSString alloc] initWithData:data encoding:enc];
    NSString*  startTag = @"<p class=\"w_name\">";
    
    NSString* endTag = @"<div class=\"showpagenum\">";
    
    TextWithLoc* textWithLoc =  [htmlString getText:startTag  endTag:endTag startLoc:0   includeTag:FALSE];
    if( textWithLoc == nil || textWithLoc.content == nil)
        return result;
    htmlString = [textWithLoc.content copy];
    
    TextWithLoc* field = nil;
    do {
        int startLoc = field == nil ? 0 :  field.range.location + 2;
        field =    [htmlString getText:@"<a href=\""  endTag:@"\"" startLoc:startLoc   includeTag:FALSE];
        if ( field == nil || field.content == nil )
            break;
        //int startLocForField = 0;
        Forum* item = [[Forum alloc] init];
        item.forumId = field.content;
        
        field =    [htmlString getText:@"target=_blank>"  endTag:@"</a>" startLoc:field.range.location + field.range.length +1  includeTag:FALSE];
        
        if (field == nil || field.content == nil )
            continue;
        item.forumTitle = [self normalizeString:field.content];
        
        field =    [htmlString getText:@"版友：</font>"  endTag:@"<font " startLoc:field.range.location + field.range.length +1  includeTag:FALSE];
        if (field == nil || field.content == nil )
            continue;
        item.popularity = [self parseIntValue: field.content] ;
        
        field =    [htmlString getText:@"</font>"  endTag:@"帖" startLoc:field.range.location + field.range.length +1  includeTag:FALSE];
        if (field == nil || field.content == nil )
            continue;
        item.activity = [self parseIntValue: field.content] ;
        
        field =    [htmlString getText:@"<p class=\"b_info color_5 \">"  endTag:@"<p class=\"w_tag\">" startLoc:field.range.location + field.range.length +1  includeTag:FALSE];
        if (field == nil || field.content == nil )
            continue;
        item.summary = [self normalizeString:field.content];
        
        field =    [htmlString getText:@"标签：</font>"  endTag:@"</p>" startLoc:field.range.location + field.range.length +1  includeTag:FALSE];
        if (field == nil || field.content == nil )
            continue;
        item.tagList = [self normalizeString:field.content];
        
        [result addObject:item];
        
    } while (1);

    
    return result;
}

-(NSMutableArray*)parseUserVisitedForum:(NSData*)data{
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:16];
    NSStringEncoding enc =  CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString* htmlString = [[NSString alloc] initWithData:data encoding:enc];
    NSString*  startTag = @"<font class=\"color_2\">来自：</font><a href=\"";
    
    NSString* endTag = @"/\"";
    
    TextWithLoc* field = nil;
    do {
        int startLoc = field == nil ? 0 :  field.range.location + 2;
        field =    [htmlString getText:startTag  endTag:endTag startLoc:startLoc   includeTag:FALSE];
        if ( field == nil || field.content == nil )
            break;
        //int startLocForField = 0;
        Forum* item = [[Forum alloc] init];
        item.forumId = field.content;
                [result addObject:item];
        
    } while (1);
    
    
    return result;
}


-(NSMutableArray*)parseSearchResult2:(NSData*)data{
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:16];
    TFHpple * searchParser = [TFHpple hppleWithHTMLData:data];
    NSString * searchXpathQueryString = @"//div[@class='result_list result_list_board']/li/div";
    NSArray *resultNodes = [searchParser searchWithXPathQuery:searchXpathQueryString];
    for (TFHppleElement *element in resultNodes)  {
        Forum* forum = [[Forum alloc] init];
        for (TFHppleElement *child in element.children)  {
            TFHppleElement* firstChild = child.firstChild;
            if ( [child.tagName isEqualToString:@"p"]){
                NSString* className = [child objectForKey:@"class"];
                if ( [className isEqualToString:@"w_name"] ){
                    forum.forumId = [firstChild objectForKey:@"href"];
                    forum.forumTitle = [firstChild content];
                    
                }
                if ( [className isEqualToString:@"b_word color_5"] ){
                    NSString* content = [ child content];
                    NSLog(@"content = %@", content);
                }
                if ( [className isEqualToString:@"b_info color_5 "] ){
                    forum.summary = [ child content];
                }
                if ( [className isEqualToString:@"w_tag"] ){
                    forum.tagList = [ child content];
                }
                //
            }
        }
        [result addObject:forum];
    }
    //
    return result;
}


@end
