//
//  ImageBatchRequest.m
//  西祠利器
//
//  Created by Hanning Ni on 11/22/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "ImageBatchRequest.h"
#import "Util.h"

@interface ImageBatchRequest()

@property (retain) NSMutableArray* forumImageList;
@property (retain) DownloadNotificationObj* notifcationObj;
@property (assign) int count;

@property (retain) NSString* batchId;

@end

@implementation ImageBatchRequest

@synthesize   forumImageList;
@synthesize   notifcationObj;
@synthesize   count;


-(id)initWithForumImageList:(NSMutableArray*)_forumImageList notifcationObj:(DownloadNotificationObj*)_notifcationObj{
    if ( self = [super init] ){
        self.forumImageList = _forumImageList;
        self.notifcationObj = _notifcationObj;
        self.count = [self.forumImageList count];
        self.batchId = [Util generateShortUUID];
    }
    return self;
}

-(NSString*)getBatchId{
    return self.batchId;
}

-(BOOL)updateResult{
    @synchronized( self.forumImageList ){
        self.count --;
        if ( self.count == 0 ){
            [[NSNotificationCenter defaultCenter]
             postNotificationName:self.notifcationObj.notificationKey
             object:self.notifcationObj];
        }
    }
    return self.count == 0;
}

@end
