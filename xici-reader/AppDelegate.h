//
//  AppDelegate.h
//  西祠利器
//
//  Created by Hanning Ni on 11/21/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlipBoardNavigationController.h"
#import "CoverPageViewController.h"
#import "MainViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//@property (strong, nonatomic) FlipBoardNavigationController * flipBoardNVC;
//@property (strong, nonatomic) CoverPageViewController * coverPageViewController;
@property (strong, nonatomic) MainViewController* mainViewController;

@end

