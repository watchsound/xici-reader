//
//  XiciHomePageParser.h
//  西祠利器
//
//  Created by Hanning Ni on 11/22/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoryHome.h"
#import "HtmlDownloaderOp.h"
#import "Forum.h"


@interface XiciHomePageParser : NSObject<HtmlDownloaderOpDelegate>


@property (retain) NSData*  originalHtmlData;
@property (retain) NSString* originalHtmlString;
@property (retain) NSMutableArray* topMapImageList;

@property (retain) NSMutableDictionary* categoryHomeList;

+ (instancetype)sharedHomePageParser;

-(void)loadXiciHomePage;
-(NSMutableArray*)extractTopMapImageItems:(NSString*) htmlString;
-(NSMutableArray*)extractTopMapImageItemsForHomePage;

-(CategoryHome*)getCategoryHome:(NSString*)category;
-(void)setCategoryHome:(NSString*)category home:(CategoryHome*)home;
-(CategoryHome*)populateCategoryHomeFromJson:(NSData*) jsonStr url:(NSString*)url;

-(void)downloadForum:(Forum*)forum  notificationKey:(NSString*)notificationKey;

-(NSMutableArray*)parseUserVisitedForum:(NSData*)data;

-(NSMutableArray*)parseSearchResult:(NSData*)data;

@end
