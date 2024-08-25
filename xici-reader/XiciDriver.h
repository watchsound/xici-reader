//
//  XiciDriver.h
//  西祠利器
//
//  Created by Hanning Ni on 11/24/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XiciDriver : NSObject{
//NSString* sessionId ;
//NSString* userid  ;
//NSTimer* timer;
//NSString* topicTitle ;
//NSString* docTitle ;;
//
//NSString* forumId;// = "1123643";
//NSString* topicId ;//= "194914219";
}


@property (retain) NSString* sessionId ;
@property (retain) NSString* userid  ;
@property (retain) NSTimer* timer;
@property (retain) NSString* topicTitle ;
@property (retain) NSString* docTitle ;;

@property (retain) NSString* forumId;// = "1123643";
@property (retain) NSString* topicId ;//= "194914219"


+ (instancetype)sharedXiciDriver;

+(void)xiciDriverTest;
-(NSMutableURLRequest*) getNSMutableURLRequest:(NSString*)urlStr :(BOOL)isPost :(NSDictionary*)postBody ;
-(NSMutableURLRequest*) getNSMutableURLRequest2:(NSString*)urlStr :(BOOL)isPost :(NSString*)postBody;
-(NSData*)getHtmlData:(NSString*)urlStr :(BOOL)isPost :(NSString*)postBody;
-(void) addCommonHeader: (NSMutableURLRequest*) request ;
-(void) parseHtmlToGetTopicAndDocTitle:(NSData*)htmlCode;

-(NSString*) getXiciSessionID ;
-(void)reloadPageAfterLogin;
-(NSData*) makeInitialRequest;


-(void) logoutXici ;
-(BOOL)tryLoginXici:(NSString*)userName :(NSString*)password ;
-(BOOL)loginXici:(NSString*)userName :(NSString*)password ;



-(void)startPingProcess:(NSString*)   _topicId ;
-(void)addComments:(NSString*) forumId  :(NSString*)topicId  :(NSString*)comments;


@end
