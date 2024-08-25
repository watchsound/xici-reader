//
//  MainViewController.h
//  西祠利器
//
//  Created by Hanning Ni on 11/24/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPFlipViewController.h"
#import "SettingNagivationViewController.h"
#import "CategoryHome.h"
#import "FootprintViewController.h"

typedef void (^FlipBoardNavigationControllerCompletionBlock)(void);


@interface MainViewController : UIViewController<MPFlipViewControllerDelegate, MPFlipViewControllerDataSource>

@property (strong, nonatomic) MPFlipViewController *flipViewController;
@property(nonatomic, retain) NSMutableArray *viewControllers;
@property (retain) SettingNagivationViewController* settingNagivationViewController;
 

- (id) initWithRootViewController:(UIViewController*)rootViewController;

- (void) pushViewController:(UIViewController *)viewController;
- (void) pushViewController:(UIViewController *)viewController completion:(FlipBoardNavigationControllerCompletionBlock)handler;
- (void) popViewController;
- (void) popViewControllerWithCompletion:(FlipBoardNavigationControllerCompletionBlock)handler;

-(void)showSettingPage;
-(void)showCollectedPostPage;
-(void)showFootPage;


- (void)gotoPreviousPage;
- (void)gotoNextPage;
-(void)gotoCategoryHomePage:(CategoryHome*)categoryHome;
-(void)gotoForumOrDiscussion:(NSString*)url;

@end

@interface UIViewController (FlipBoardNavigationController)
@property (nonatomic, retain) MainViewController *flipboardNavigationController;
@end