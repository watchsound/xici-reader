//
//  ImageBatchRequest.h
//  西祠利器
//
//  Created by Hanning Ni on 11/22/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadNotificationObj.h"

@interface ImageBatchRequest : NSObject

@property (retain, readonly) NSMutableArray* forumImageList;


-(id)initWithForumImageList:(NSMutableArray*)forumImageList notifcationObj:(DownloadNotificationObj*)notifcationObj;

-(BOOL)updateResult;

-(NSString*)getBatchId;

@end

 