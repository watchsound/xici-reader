//
//  Constants.h
//  FlipViewControllerDemo
//
//  Created by Hanning Ni on 11/21/13.
//  Copyright (c) 2013 Michael Henry Pantaleon. All rights reserved.
//

#ifndef FlipViewControllerDemo_Constants_h
#define FlipViewControllerDemo_Constants_h


#define  kImageBatchForCoverPage @"kImageBatchForCoverPage"
#define  kDATABSE_NAME  @"xici.db"

#define  kENC  CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)

#define kSettingHtmlNotificationKey @"kSettingHtmlNotificationKey"
#define kSettingImageNotificationKey @"kSettingImageNotificationKey"
#define kSettingReloadNotificationKey @"kSettingReloadNotificationKey"
#define kFootReloadNotificationKey @"kFootReloadNotificationKey"

#define kCateogryHomeDetailForumReloadNotificationKey @"kCateogryHomeDetailForumReloadNotificationKey"
#define kCateogryHomeDetailDiscussionReloadNotificationKey @"kCateogryHomeDetailDiscussionReloadNotificationKey"



typedef enum {
    DirectionLeft = 0,
    DirectionRight = 1
} TransDirection;

@protocol SizeConfigurableDelegate

-(TransDirection)getTransition;

@end


#endif
