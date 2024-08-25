//
//  XiciCategory.h
//  西祠利器
//
//  Created by Hanning Ni on 11/25/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XiciCategory : NSObject

@property (retain) NSString* categoryName;
@property (retain) NSString*  categoryServerId;
@property (retain) NSString*  defaultImageUid;

-(id)initWithName:(NSString*)name sid:(NSString*)serverId  image:(NSString*)imageUid ;

+ (NSMutableArray*) getDefaultCategoryList;

@end
