//
//  CategoryHome.h
//  西祠利器
//
//  Created by Hanning Ni on 11/28/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Forum.h"
@interface CategoryHome : NSObject

@property (retain) NSString* category;

@property (retain) NSMutableArray* hotboard;
@property (retain) NSMutableArray* hotfly;
@property (retain) NSMutableArray* hotpic;
@property (retain) NSMutableArray* hotsort;
@property (retain) NSMutableArray* others;

@property (retain) NSMutableArray* topMapImageList;
@property (retain) Forum*  forum;

@end
