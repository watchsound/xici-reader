//
//  LocalService.m
//  西祠利器
//
//  Created by Hanning Ni on 11/23/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "LocalService.h"
#import "AnywhereWebview.h"
#import "Util.h"
#import "XiciCategory.h"
#import "Constants.h"

@implementation LocalService

+ (instancetype)sharedLocalService
{
    static dispatch_once_t onceToken;
    static LocalService * localService;
    dispatch_once(&onceToken, ^{
        localService = [[[self class] alloc] init];
    });
    return localService;
}

-(NSMutableArray*)getDefaultCateogryList{
    NSMutableArray* catList = [XiciCategory getDefaultCategoryList];
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:24];
    for(XiciCategory * cat in catList ){
        Forum* forum = [[Forum alloc] init];
        forum.topForum = TRUE;
        forum.forumId = cat.categoryServerId;
        forum.forumTitle = cat.categoryName;
        forum.category = cat.categoryName;
        UIImage* image = [UIImage imageWithData:[[LocalService sharedLocalService] getImageFromBundle:cat.defaultImageUid]];
        if (  [cat.defaultImageUid rangeOfString:@".png"].location != NSNotFound ){
            forum.forumIcon = UIImagePNGRepresentation(image);
        } else {
            forum.forumIcon = UIImageJPEGRepresentation(image, 1);
        }
        forum.iconLocal = cat.defaultImageUid;
        
        forum.subscribed = TRUE;
        [result addObject:forum];
    }
    return result;
}

-(void)populateInitialData{
    int forumNum = [[ForumDAO sharedForumDAO] getSubscribedForumNum];
    if ( forumNum > 0 )
        return;
    //populate categories
    NSMutableArray* catList = [self getDefaultCateogryList];
    for(Forum * forum in catList ){
         [[ForumDAO sharedForumDAO] saveForum:forum];
    }
    
}

-(void)saveImage:(ForumImage*)forumImage{
    //  ForumThumbnail = 0,
    // AuthorThumbnail = 1,
    if ( forumImage.imageSourceType == CacheOnly ){
         [self saveImageToCache:forumImage.imageUid image:forumImage.imageData];
       
    } else  if ( forumImage.imageSourceType == ForumThumbnail && forumImage.forum != nil ){
       [[ForumDAO sharedForumDAO] saveForum: forumImage.forum];
    } else if ( forumImage.imageSourceType == AuthorThumbnail && forumImage.user != nil ){
       [[ForumDAO sharedForumDAO] saveUser: forumImage.user];
        
    }
    else {
         [[ForumDAO sharedForumDAO] saveImage:forumImage.sourceUid imageId:forumImage.imageUid image:forumImage.imageData];
    }
}

-(void)saveImage:(NSString*)containerId imageId:(NSString*)imageId image:(NSData*)image{
    [[ForumDAO sharedForumDAO] saveImage:containerId imageId:imageId image:image];
}

-(void)saveImageToCache:(NSString*)imageName  image:(NSData*)image{
    
    NSString* filepath  = [[ NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]   stringByAppendingPathComponent:imageName ];
    NSError* error;
    BOOL success = [image writeToFile:filepath atomically:TRUE  ];
    if ( !success  ){
        NSLog(@"Error createFold  %@ with error %@", filepath , error);
    } else {
        [LocalService addSkipBackupAttributeToItemAtPath:filepath ];
    }

}

-(NSData*)getImageFromDB:(NSString*)imageId{
    return  [[ForumDAO sharedForumDAO] getImage:imageId];
}
-(NSData*)getImageFromCache:(NSString*)imageId{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *defaultDBPath   = [ NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    defaultDBPath = [defaultDBPath stringByAppendingPathComponent:imageId ];
    if ( [fileManager fileExistsAtPath:defaultDBPath] ){
        return [NSData dataWithContentsOfFile:defaultDBPath];;
    } else {
        return nil;
    }
}
-(NSData*)getImageFromBundle:(NSString*)imageId{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *defaultDBPath  = [[NSBundle mainBundle] resourcePath];
    defaultDBPath = [defaultDBPath stringByAppendingPathComponent:imageId ];
    if ( [fileManager fileExistsAtPath:defaultDBPath] ){
        return   [NSData dataWithContentsOfFile:defaultDBPath];
    } else {
        return nil;
    }

}

-(NSData*)getImage:(NSString*)imageId{
    NSData* data = [self getImageFromBundle:imageId];
    if ( data != nil )
        return data;
    
    data = [self getImageFromCache:imageId];
    if ( data != nil )
        return data;
    
    return [self getImageFromDB:imageId];
}


-(Discussion*)getDisscussion:(NSString*)discussionId{
    Discussion* discussion = [[ForumDAO sharedForumDAO] getDisscussion:discussionId];
    discussion.replyList = [[ForumDAO sharedForumDAO] getDiscussionReply:discussionId];
    discussion.imageList = [[ForumDAO sharedForumDAO] getImageByContainerId:discussionId];
    return discussion;
}


//help method
//for iOS 5.1 and later. Starting in iOS 5.1, apps can use either NSURLIsExcludedFromBackupKey or kCFURLIsExcludedFromBackupKey file properties to exclude files from backups.
+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)path{
    return  [self addSkipBackupAttributeToItemAtURL: [NSURL fileURLWithPath:path]];
}

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL{
    
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

+(NSURL*)restoreResourceUrlFromCache:(NSString*)title{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString * fileName =   [NSString stringWithFormat:@"%@.html", title];
    NSString *myPath = [cachesDirectory stringByAppendingPathComponent:fileName];
    
    return  [NSURL fileURLWithPath:myPath];
}

+(void)createFoldForSavedPage:(long)folderId{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString* folder = [NSString stringWithFormat:@"%li", folderId];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:folder];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]){
        NSError *error ;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
        
        if ( !success  ){
            NSLog(@"Error createFoldForSavedPage  %@ with error %@", dataPath , error);
        } else {
            [LocalService addSkipBackupAttributeToItemAtPath:dataPath ];
        }
    }
}

+(void)createFold:(NSString*)folderId{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString* folder = [NSString stringWithFormat:@"%@", folderId];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:folder];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]){
        NSError *error ;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
        if ( !success  ){
            NSLog(@"Error createFold  %@ with error %@", dataPath , error);
        } else {
            [LocalService addSkipBackupAttributeToItemAtPath:dataPath ];
        }
    }
}


+(NSString*)createALocalFile:(NSString*)file folderId:(long)folderId :(NSString*)content{
    if ( file == nil )
        return nil;
    [LocalService createFoldForSavedPage:folderId];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString * fileName =   [NSString stringWithFormat:@"%li/%@", folderId,file];
    NSString * myPath = [cachesDirectory stringByAppendingPathComponent:fileName];
	
    NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:myPath error:NULL];
    NSError* error;
    BOOL success = [content writeToFile:myPath
                             atomically:NO
                               encoding:NSStringEncodingConversionAllowLossy
                                  error:&error];
    
    if ( !success  ){
        NSLog(@"Error createFold  %@ with error %@", myPath , error);
    } else {
        [LocalService addSkipBackupAttributeToItemAtPath:myPath ];
    }
    
    return myPath;
}

+(BOOL)hasCachedDocument:(NSString*)webname folderId:(long)folderId{
    if ( webname == nil )
        return NO;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString * fileName =   [NSString stringWithFormat:@"%li/%@", folderId,webname];
    NSString * myPath = [cachesDirectory stringByAppendingPathComponent:fileName];
	
    NSFileManager *fileManager = [NSFileManager defaultManager];
	return [fileManager fileExistsAtPath:myPath];
}

+(NSString*)loadCachedFilePath:(long)foldId{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString * fileName =   [NSString stringWithFormat:@"%li/index.html", foldId];
    return [cachesDirectory stringByAppendingPathComponent:fileName];
}

+(void)clearDocumentFile:(NSString*)webname folderId:(long)folderId{
    if ( webname == nil )
        return;
  	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString * fileName =   [NSString stringWithFormat:@"%li/%@", folderId,webname];
    NSString * myPath = [cachesDirectory stringByAppendingPathComponent:fileName];
	
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError* error;
	BOOL success = [fileManager removeItemAtPath:myPath error:&error];
    if ( !success  ){
        NSLog(@"Error clearDocumentFile  %@ with error %@", myPath , error);
    }
}

+(BOOL)deleteFolder:(long)foldid{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString * fileName =   [NSString stringWithFormat:@"%li", foldid];
    NSString * myPath = [cachesDirectory stringByAppendingPathComponent:fileName];
	
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError* error;
	BOOL success = [fileManager removeItemAtPath:myPath error:&error];
    if ( !success  ){
        NSLog(@"Error clearDocumentFile  %@ with error %@", myPath , error);
    }
    
    return success;
}
+(BOOL)deleteFile :(NSString*)fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString * myPath = [cachesDirectory stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError* error;
	BOOL success = [fileManager removeItemAtPath:myPath error:&error];
    if ( !success  ){
        NSLog(@"Error clearDocumentFile  %@ with error %@", myPath , error);
    }
    
    return success;
    
}

+(NSString*)saveWebview:(AnywhereWebview *)webView{
    NSString* foldId = [Util generateShortUUID];
    [LocalService createFold:foldId];
    
    [webView stringByEvaluatingJavaScriptFromString:@"var script = document.createElement('script');"
     "script.type = 'text/javascript';"
     "script.text = \"function everywhereReaderExtractImages() { "
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
    
    NSString* imgUrls=[webView stringByEvaluatingJavaScriptFromString:@"everywhereReaderExtractImages();"];
    NSArray* imageUrls = [imgUrls componentsSeparatedByString:@"|"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    
    NSString *html = [webView stringByEvaluatingJavaScriptFromString: @"document.all[0].innerHTML"];
    for (int i =1; i < [imageUrls count]; i++){
        NSString* imageUrl = [imageUrls objectAtIndex:i];
        NSArray* imageNamePart = [imageUrl componentsSeparatedByString:@"/"];
        NSString* imageName = [imageNamePart objectAtIndex:[imageNamePart count] -1];
        NSString * fileName =   [NSString stringWithFormat:@"%@/%@",foldId, imageName];
        NSString *myPath = [cachesDirectory stringByAppendingPathComponent:fileName];
        
        NSData* localdata =  [NSData dataWithContentsOfFile:myPath];
        if ( localdata == nil || [localdata length] == 0 ){
            NSURL *_url = [NSURL URLWithString:imageUrl];
            NSData *urlData = [NSData dataWithContentsOfURL:_url];
            
            BOOL success =  [urlData writeToFile:myPath atomically:YES];
            if ( !success ){
                NSLog(@" error  saveWebview  %@ ", _url);
            }else {
                [LocalService addSkipBackupAttributeToItemAtPath:myPath ];
            }
        }
        
        html = [html stringByReplacingOccurrencesOfString:imageUrl withString:imageName];
    }
    
    //try css file
    [webView stringByEvaluatingJavaScriptFromString:@"var script = document.createElement('script');"
     "script.type = 'text/javascript';"
     "script.text = \"function everywhereReaderExtractCss() { "
     " var csss = document.styleSheets; "
     " var csssrc = '';  "
     " for (var i=0; i<csss.length; i++) { "
     "    var url = csss[i].href;   "
     "    if (url.length>0) {   "
     "        csssrc += '|' + url;   "
     "    }  "
     " }  "
     " return csssrc; "
     "}\";"
     "document.getElementsByTagName('head')[0].appendChild(script);"];
    
    NSString* cssUrls=[webView stringByEvaluatingJavaScriptFromString:@"everywhereReaderExtractCss();"];
    NSArray* csssUrls = [cssUrls componentsSeparatedByString:@"|"];
    for (int i =1; i < [csssUrls count]; i++){
        NSString* cssUrl = [csssUrls objectAtIndex:i];
        NSArray* cssNamePart = [cssUrl componentsSeparatedByString:@"/"];
        NSString* cssName = [cssNamePart objectAtIndex:[cssNamePart count] -1];
        NSString * fileName =   [NSString stringWithFormat:@"%@/%@",foldId, cssName];
        NSString *myPath = [cachesDirectory stringByAppendingPathComponent:fileName];
        
        NSData* localdata =  [NSData dataWithContentsOfFile:myPath];
        if ( localdata == nil || [localdata length] == 0 ){
            NSURL *_url = [NSURL URLWithString:cssUrl];
            NSData *urlData = [NSData dataWithContentsOfURL:_url];
            BOOL success =  [urlData writeToFile:myPath atomically:YES];
            if ( !success ){
                NSLog(@" error  saveWebview  %@ ", _url);
            }else {
                [LocalService addSkipBackupAttributeToItemAtPath:myPath ];
            }
        }
        
        html = [html stringByReplacingOccurrencesOfString:cssUrl withString:cssName];
    }
    //
    
    NSString * fileName =   [NSString stringWithFormat:@"%@/index.html", foldId];
    NSString * myPath = [cachesDirectory stringByAppendingPathComponent:fileName];
	
    // NSFileManager *fileManager = [NSFileManager defaultManager];
	//[fileManager removeItemAtPath:myPath error:NULL];
    //  NSError *error;
    NSData* data=[html dataUsingEncoding:kENC];
    BOOL success = [data writeToFile:myPath  atomically:NO];
    if ( !success ){
        NSLog(@" error  saveWebview ");
    }else {
        [LocalService addSkipBackupAttributeToItemAtPath:myPath ];
    }
    return foldId;
}

+(void)saveFile:(NSString*) filename content:(NSString*)content{
    filename = [filename stringByAppendingString:@".json"];
    
    NSString* filepath  = [[ NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]   stringByAppendingPathComponent:filename ];
    NSError* error;
    BOOL success = [content writeToFile:filepath atomically:TRUE encoding:kENC error:&error];
    if ( !success  ){
        NSLog(@"Error createFold  %@ with error %@", filepath , error);
    } else {
        [LocalService addSkipBackupAttributeToItemAtPath:filepath ];
    }
}


+(void)renameFileFolder:(NSString*)oldname newname:(NSString*)newname{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString  * oldpath = [path stringByAppendingPathComponent:oldname];
    NSString  * newpath = [path stringByAppendingPathComponent:newname];
    NSError *error = nil;
    BOOL success = [fileManager moveItemAtPath:oldpath toPath:newpath error:&error];
    if ( !success  ){
        NSLog(@"Error renameFileFolder to %@ with error %@", newpath , error);
    } else {
        [LocalService addSkipBackupAttributeToItemAtPath:newpath ];
    }
}


+(NSString*)getFilePathFor:(NSString*)folder  file:(NSString*)file{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    
    return [[cachesDirectory stringByAppendingPathComponent:folder] stringByAppendingPathComponent: file];
}

-(void)subscribeForum:(Forum*)forum subscribe:(BOOL)subscribe{
    forum.subscribed = subscribe;
    Forum * f= [[ForumDAO sharedForumDAO] getForum:forum.forumId];
    if ( f == nil ){
         [[ForumDAO sharedForumDAO] saveForum:forum];
    } else {
        [[ForumDAO sharedForumDAO ] subscribeForum:forum subscribe:subscribe];
    }
}

-(void)saveUser:(User*)auser{
    User * user = [[ForumDAO sharedForumDAO] getUserById : auser.userId];
    if ( user ) {
        [[ForumDAO sharedForumDAO] updateUser:auser];
    } else {
        [[ForumDAO sharedForumDAO] saveUser:auser];
    }
}

-(void)saveOnlyNewUser:(User*)auser{
    User * user = [[ForumDAO sharedForumDAO] getUserById : auser.userId];
    if ( !user ) {
        [[ForumDAO sharedForumDAO] saveUser:auser];
    }
}

@end

