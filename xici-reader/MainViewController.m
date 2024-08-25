//
//  MainViewController.m
//  西祠利器
//
//  Created by Hanning Ni on 11/24/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "MainViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CoverPageViewController.h"
#import "CategoryViewController.h"
#import "CategoryHomeViewController.h"
#import "CategoryHome.h"
#import "LocalService.h"
#import "ForumDAO.h"
#import "ForumWebViewController.h"
#import "PostCollectionViewController.h"
#import "FootprintViewController.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


static const CGFloat kAnimationDuration = 0.5f;
static const CGFloat kAnimationDelay = 0.0f;
static const CGFloat kMaxBlackMaskAlpha = 0.8f;

typedef enum {
    PanDirectionNone = 0,
    PanDirectionLeft = 1,
    PanDirectionRight = 2
} PanDirection;

@interface MainViewController (){
    int numPages;
    
    
    NSMutableArray *_gestures;
    UIView *_blackMask;
    CGPoint _panOrigin;
    BOOL _animationInProgress;
    CGFloat _percentageOffsetFromLeft;
    
    
    
}


@property (assign, nonatomic) int previousIndex;
@property (assign, nonatomic) int tentativeIndex;
@property (assign, nonatomic) BOOL observerAdded;
@property (retain) NSMutableArray* forumList;

@property (retain) CategoryHome* categoryHome;
@property (retain) NSString*  forumOrDiscussionUrl;

@property  (retain) PostCollectionViewController* postCollectionViewController;
@property  (retain) FootprintViewController *footprintViewController;
//@property (retain) NSMutableArray* viewControlList;


- (void) addPanGestureToView:(UIView*)view;
- (void) rollBackViewController;


//flip
- (UIViewController *)currentViewController;
- (UIViewController *)previousViewController;

- (void) transformAtPercentage:(CGFloat)percentage ;
- (void) completeSlidingAnimationWithDirection:(PanDirection)direction;
- (void) completeSlidingAnimationWithOffset:(CGFloat)offset;
- (CGRect) getSlidingRectWithPercentageOffset:(CGFloat)percentage orientation:(UIInterfaceOrientation)orientation ;
- (CGRect) viewBoundsWithOrientation:(UIInterfaceOrientation)orientation;

@end

@implementation MainViewController

#define CONTENT_IDENTIFIER @"ContentViewController"
#define FRAME_MARGIN	0
#define MOVIE_MIN		0
#define NUM_FORUM_IN_ONE_PAGE 7



@synthesize flipViewController = _flipViewController;
@synthesize previousIndex = _previousIndex;
@synthesize tentativeIndex = _tentativeIndex;
@synthesize forumList = _forumList;
@synthesize settingNagivationViewController = _settingNagivationViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.viewControllers = [[NSMutableArray alloc] initWithCapacity:4];
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect viewRect = self.view.frame;
    
    _blackMask = [[UIView alloc] initWithFrame:viewRect];
    _blackMask.backgroundColor = [UIColor blackColor];
    _blackMask.alpha = 0.0;
    _blackMask.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view insertSubview:_blackMask atIndex:0];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
	self.previousIndex = MOVIE_MIN;
	
	// Configure the page view controller and add it as a child view controller.
	self.flipViewController = [[MPFlipViewController alloc] initWithOrientation:[self flipViewController:nil orientationForInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation]];
	self.flipViewController.delegate = self;
	self.flipViewController.dataSource = self;

    [self.viewControllers addObject:self.flipViewController];
    
	CGRect pageViewRect = self.view.bounds;
	
//	
//		self.flipViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
	
	self.flipViewController.view.frame = pageViewRect;
	[self addChildViewController:self.flipViewController];
	[self.view addSubview:self.flipViewController.view];
	[self.flipViewController didMoveToParentViewController:self];
	
	[self.flipViewController setViewController:[self contentViewWithIndex:self.previousIndex] direction:MPFlipViewControllerDirectionForward animated:NO completion:nil];
	
	// Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
	self.view.gestureRecognizers = self.flipViewController.gestureRecognizers;
	
   // if ( self.viewControlList == nil )
   //     self.viewControlList = [[NSMutableArray alloc] initWithCapacity:4];
	
	[self addObserver];
    [[LocalService sharedLocalService] populateInitialData];
    
     self.forumList = [[ForumDAO sharedForumDAO] getSubscribedForums];
     Forum* dummy = [[Forum alloc] init];
    dummy.forumTitle = @"dummy";
    dummy.forumIcon = [[LocalService sharedLocalService] getImageFromBundle:@"plus.png"];
    [self.forumList addObject: dummy];
     int count = [self.forumList count] ;
     numPages =   count / NUM_FORUM_IN_ONE_PAGE;
     if ( count % NUM_FORUM_IN_ONE_PAGE != 0 )
         numPages ++;
}

-(int)getTotalNumPages{
    int num = numPages;
    if ( self.categoryHome )
        num++;
    if ( self.forumOrDiscussionUrl )
        num++;
    return num;
}

- (void)viewDidUnload
{
	[self removeObserver];
    [super viewDidUnload];
	
    // Release any retained subviews of the main view.
}

- (void)addObserver
{
	if (![self observerAdded])
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flipViewControllerDidFinishAnimatingNotification:) name:MPFlipViewControllerDidFinishAnimatingNotification object:nil];
		[self setObserverAdded:YES];
	}
}

- (void)removeObserver
{
	if ([self observerAdded])
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self name:MPFlipViewControllerDidFinishAnimatingNotification object:nil];
		[self setObserverAdded:NO];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([self flipViewController])
		return [[self flipViewController] shouldAutorotateToInterfaceOrientation:interfaceOrientation];
	else
		return YES;
}


- (UIViewController *)contentViewWithIndex:(int)index
{
    UIViewController* controller;
	if ( index == 0 ){
             controller = [[CoverPageViewController alloc]  initWithNibName:@"CoverPageViewController" bundle:nil];
      
    } else  {
        
        if ( index >= numPages ){
            if ( index == numPages ){
                if ( self.categoryHome ){
                      controller = [[CategoryHomeViewController alloc]  initWithNibName:@"CategoryHomeViewController" bundle:nil];
                    [(CategoryHomeViewController*)controller setupUI:self.categoryHome];
                } else if ( self.forumOrDiscussionUrl ){
                    controller = [[ForumWebViewController alloc]  initWithNibName:@"ForumWebViewController" bundle:nil];
                    [(ForumWebViewController*)controller showForumOrPost:self.forumOrDiscussionUrl];
                }
            } else {
                if ( self.forumOrDiscussionUrl ){
                    controller = [[ForumWebViewController alloc]  initWithNibName:@"ForumWebViewController" bundle:nil];
                    [(ForumWebViewController*)controller showForumOrPost:self.forumOrDiscussionUrl];
                }
            }
            if ( controller == nil )
                 controller = [[CoverPageViewController alloc]  initWithNibName:@"CoverPageViewController" bundle:nil];
        }
        
        else {
         
              controller = [[CategoryViewController alloc]  initWithNibName:@"CategoryViewController" bundle:nil];
           
            NSMutableArray* forumInPage = [[NSMutableArray alloc] initWithCapacity:8];
            for(int i = (index -1) * NUM_FORUM_IN_ONE_PAGE ; i < [self.forumList count]  && i < index * NUM_FORUM_IN_ONE_PAGE; i++){
                [forumInPage addObject:[self.forumList objectAtIndex:i]];
            }
            ((CategoryViewController*)controller).forumList = forumInPage;
        }
        
    }
    
 //hni   controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
	return controller;
}

#pragma mark - MPFlipViewControllerDelegate protocol

- (void)flipViewController:(MPFlipViewController *)flipViewController didFinishAnimating:(BOOL)finished previousViewController:(UIViewController *)previousViewController transitionCompleted:(BOOL)completed
{
	if (completed)
	{
		self.previousIndex = self.tentativeIndex;
	}
}

- (MPFlipViewControllerOrientation)flipViewController:(MPFlipViewController *)flipViewController orientationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
		return UIInterfaceOrientationIsPortrait(orientation)? MPFlipViewControllerOrientationVertical : MPFlipViewControllerOrientationHorizontal;
	else
		return MPFlipViewControllerOrientationHorizontal;
}

#pragma mark - MPFlipViewControllerDataSource protocol

- (UIViewController *)flipViewController:(MPFlipViewController *)flipViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
	int index = self.previousIndex;
	index--;
	if (index < MOVIE_MIN)
		return nil; // reached beginning, don't wrap
	self.tentativeIndex = index;
	return [self contentViewWithIndex:index];
}

- (UIViewController *)flipViewController:(MPFlipViewController *)flipViewController viewControllerAfterViewController:(UIViewController *)viewController
{
	int index = self.previousIndex;
	index++;
	if (index > [self getTotalNumPages])
		return nil; // reached end, don't wrap
	self.tentativeIndex = index;
	return [self contentViewWithIndex:index];
}

#pragma mark - Notifications

- (void)flipViewControllerDidFinishAnimatingNotification:(NSNotification *)notification
{
	NSLog(@"Notification received: %@", notification);
}

- (void)gotoPreviousPage{
    [self.flipViewController gotoPreviousPage];
}
- (void)gotoNextPage{
     [self.flipViewController gotoNextPage];
}

-(void)gotoCategoryHomePage:(CategoryHome*)categoryHome{
    self.categoryHome = categoryHome;
    self.previousIndex = numPages -1;
    [self gotoNextPage];
}

-(void)gotoForumOrDiscussion:(NSString*)url{
    self.forumOrDiscussionUrl = url;
    self.previousIndex =  [self getTotalNumPages] -1 ;
    [self gotoNextPage];
}





//flip slide in effect
#pragma mark - PushViewController With Completion Block
- (void) pushViewController:(UIViewController *)viewController completion:(FlipBoardNavigationControllerCompletionBlock)handler {
    
    _animationInProgress = YES;
    
    if ( [viewController conformsToProtocol:@protocol(SizeConfigurableDelegate)]){
        TransDirection transDirection  =  [(id<SizeConfigurableDelegate>)viewController getTransition];
        viewController.view.frame = transDirection == DirectionLeft ? CGRectOffset(self.view.bounds, self.view.bounds.size.width, 0)
        : CGRectOffset(self.view.bounds, -self.view.bounds.size.width, 0);
    } else {
        viewController.view.frame =   CGRectOffset(self.view.bounds, self.view.bounds.size.width, 0);
    }
    viewController.view.autoresizingMask =  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _blackMask.alpha = 0.0;
    [viewController willMoveToParentViewController:self];
    [self addChildViewController:viewController];
    [self.view bringSubviewToFront:_blackMask];
    [self.view addSubview:viewController.view];
    [UIView animateWithDuration:kAnimationDuration delay:kAnimationDelay options:0 animations:^{
        CGAffineTransform transf = CGAffineTransformIdentity;
        [self currentViewController].view.transform = CGAffineTransformScale(transf, 0.9f, 0.9f);
        viewController.view.frame = self.view.bounds;
        _blackMask.alpha = kMaxBlackMaskAlpha;
    }   completion:^(BOOL finished) {
        if (finished) {
            [self.viewControllers addObject:viewController];
            [viewController didMoveToParentViewController:self];
            _animationInProgress = NO;
            _gestures = [[NSMutableArray alloc] init];
            [self addPanGestureToView:[self currentViewController].view];
            handler();
        }
    }];
}

- (void) pushViewController:(UIViewController *)viewController {
    [self pushViewController:viewController completion:^{}];
}

#pragma mark - PopViewController With Completion Block
- (void) popViewControllerWithCompletion:(FlipBoardNavigationControllerCompletionBlock)handler {
    _animationInProgress = YES;
    if (self.viewControllers.count < 2) {
        return;
    }
    
    UIViewController *currentVC = [self currentViewController];
    UIViewController *previousVC = [self previousViewController];
    [previousVC viewWillAppear:NO];
    [UIView animateWithDuration:kAnimationDuration delay:kAnimationDelay options:0 animations:^{
        currentVC.view.frame = CGRectOffset(self.view.bounds, self.view.bounds.size.width, 0);
        if ( [currentVC conformsToProtocol:@protocol(SizeConfigurableDelegate)]){
            TransDirection transDirection  =  [(id<SizeConfigurableDelegate>)currentVC getTransition];
            currentVC.view.frame = transDirection == DirectionLeft ? CGRectOffset(self.view.bounds, self.view.bounds.size.width, 0)
            : CGRectOffset(self.view.bounds, -self.view.bounds.size.width, 0);
        } else {
            currentVC.view.frame =   CGRectOffset(self.view.bounds, self.view.bounds.size.width, 0);
        }
        
        
        CGAffineTransform transf = CGAffineTransformIdentity;
        previousVC.view.transform = CGAffineTransformScale(transf, 1.0, 1.0);
        previousVC.view.frame = self.view.bounds;
        _blackMask.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [currentVC.view removeFromSuperview];
            [currentVC willMoveToParentViewController:nil];
            [self.view bringSubviewToFront:[self previousViewController].view];
            [currentVC removeFromParentViewController];
            [currentVC didMoveToParentViewController:nil];
            [self.viewControllers removeObject:currentVC];
            _animationInProgress = NO;
            [previousVC viewDidAppear:NO];
            handler();
        }
    }];
    
}

- (void) popViewController {
    [self popViewControllerWithCompletion:^{}];
}

- (void) rollBackViewController {
    _animationInProgress = YES;
    
    UIViewController * vc = [self currentViewController];
    UIViewController * nvc = [self previousViewController];
    CGRect rect = CGRectMake(0, 0, vc.view.frame.size.width, vc.view.frame.size.height);
    
    [UIView animateWithDuration:0.3f delay:kAnimationDelay options:0 animations:^{
        CGAffineTransform transf = CGAffineTransformIdentity;
        nvc.view.transform = CGAffineTransformScale(transf, 0.9f, 0.9f);
        vc.view.frame = rect;
        _blackMask.alpha = kMaxBlackMaskAlpha;
    }   completion:^(BOOL finished) {
        if (finished) {
            _animationInProgress = NO;
        }
    }];
}

#pragma mark - ChildViewController
- (UIViewController *)currentViewController {
    UIViewController *result = nil;
    if ([self.viewControllers count]>0) {
        result = [self.viewControllers lastObject];
    }
    return result;
}

#pragma mark - ParentViewController
- (UIViewController *)previousViewController {
    UIViewController *result = nil;
    if ([self.viewControllers count]>1) {
        result = [self.viewControllers objectAtIndex:self.viewControllers.count - 2];
    }
    return result;
}

#pragma mark - Get the size of view in the main screen
- (CGRect) viewBoundsWithOrientation:(UIInterfaceOrientation)orientation{
	CGRect bounds = [UIScreen mainScreen].bounds;
    if([[UIApplication sharedApplication]isStatusBarHidden]){
        return bounds;
    } else  {
		CGFloat width = bounds.size.width;
		bounds.size.width = bounds.size.height;
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))  {
            bounds.size.height = width - 20;
        }else {
            bounds.size.height = width;
        }
        return bounds;
	}
}


#pragma mark - Add Pan Gesture
- (void) addPanGestureToView:(UIView*)view
{
    NSLog(@"ADD PAN GESTURE $$### %i",[_gestures count]);
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(gestureRecognizerDidPan:)];
    panGesture.cancelsTouchesInView = YES;
    panGesture.delegate = self;
    [view addGestureRecognizer:panGesture];
    [_gestures addObject:panGesture];
    panGesture = nil;
}

# pragma mark - Avoid Unwanted Vertical Gesture
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint translation = [panGestureRecognizer translationInView:self.view];
    return fabs(translation.x) > fabs(translation.y) ;
}

#pragma mark - Gesture recognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UIViewController * vc =  [self.viewControllers lastObject];
    _panOrigin = vc.view.frame.origin;
    gestureRecognizer.enabled = YES;
    return !_animationInProgress;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Handle Panning Activity
- (void) gestureRecognizerDidPan:(UIPanGestureRecognizer*)panGesture {
    if(_animationInProgress) return;
    
    CGPoint currentPoint = [panGesture translationInView:self.view];
    CGFloat x = currentPoint.x + _panOrigin.x;
    
    PanDirection panDirection = PanDirectionNone;
    CGPoint vel = [panGesture velocityInView:self.view];
    
    if (vel.x > 0) {
        panDirection = PanDirectionRight;
    } else {
        panDirection = PanDirectionLeft;
    }
    
    CGFloat offset = 0;
    
    UIViewController * vc ;
    vc = [self currentViewController];
    offset = CGRectGetWidth(vc.view.frame) - x;
    
    _percentageOffsetFromLeft = offset/[self viewBoundsWithOrientation:self.interfaceOrientation].size.width;
    vc.view.frame = [self getSlidingRectWithPercentageOffset:_percentageOffsetFromLeft orientation:self.interfaceOrientation];
    [self transformAtPercentage:_percentageOffsetFromLeft];
    
    if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled) {
        // If velocity is greater than 100 the Execute the Completion base on pan direction
        if(abs(vel.x) > 100) {
            [self completeSlidingAnimationWithDirection:panDirection];
        }else {
            [self completeSlidingAnimationWithOffset:offset];
        }
    }
}

#pragma mark - Set the required transformation based on percentage
- (void) transformAtPercentage:(CGFloat)percentage {
    CGAffineTransform transf = CGAffineTransformIdentity;
    CGFloat newTransformValue =  1 - (percentage*10)/100;
    CGFloat newAlphaValue = percentage* kMaxBlackMaskAlpha;
    [self previousViewController].view.transform = CGAffineTransformScale(transf,newTransformValue,newTransformValue);
    _blackMask.alpha = newAlphaValue;
}

#pragma mark - This will complete the animation base on pan direction
- (void) completeSlidingAnimationWithDirection:(PanDirection)direction {
    if(direction==PanDirectionRight){
        [self popViewController];
    }else {
        [self rollBackViewController];
    }
}

#pragma mark - This will complete the animation base on offset
- (void) completeSlidingAnimationWithOffset:(CGFloat)offset{
    
    if(offset<[self viewBoundsWithOrientation:self.interfaceOrientation].size.width/2) {
        [self popViewController];
    }else {
        [self rollBackViewController];
    }
}


#pragma mark - Get the origin and size of the visible viewcontrollers(child)
- (CGRect) getSlidingRectWithPercentageOffset:(CGFloat)percentage orientation:(UIInterfaceOrientation)orientation {
    CGRect viewRect = [self viewBoundsWithOrientation:orientation];
    CGRect rectToReturn = CGRectZero;
    UIViewController * vc;
    vc = [self currentViewController];
    rectToReturn.size = viewRect.size;
    rectToReturn.origin = CGPointMake(MAX(0,(1-percentage)*viewRect.size.width), 0.0);
    return rectToReturn;
}



-(void)showSettingPage {
    if( !self.settingNagivationViewController )
        self.settingNagivationViewController = [[SettingNagivationViewController alloc]  initWithNibName:@"SettingNagivationViewController" bundle:nil];
    [self pushViewController:self.settingNagivationViewController completion:^{
        [self.settingNagivationViewController showMySettingPane];
    }];
}

-(void)showCollectedPostPage{
    //PostCollectionViewController
    if( !self.postCollectionViewController )
        self.postCollectionViewController = [[PostCollectionViewController alloc]  initWithNibName:@"PostCollectionViewController" bundle:nil];
    [self pushViewController:self.postCollectionViewController completion:^{
        
    }];
}


-(void)showFootPage{
    //FootprintViewController.h
    //PostCollectionViewController
    if( !self.footprintViewController )
        self.footprintViewController = [[FootprintViewController alloc]  initWithNibName:@"FootprintViewController" bundle:nil];
    [self pushViewController:self.footprintViewController completion:^{
        
    }];
}


@end



#pragma mark - UIViewController Category
//For Global Access of flipViewController
@implementation UIViewController (FlipBoardNavigationController)
@dynamic flipboardNavigationController;

- (MainViewController *)flipboardNavigationController
{
    
    if([self.parentViewController isKindOfClass:[MainViewController class]]){
        return (MainViewController*)self.parentViewController;
    }
    else if([self.parentViewController isKindOfClass:[UINavigationController class]] &&
            [self.parentViewController.parentViewController isKindOfClass:[MainViewController class]]){
        return (MainViewController*)[self.parentViewController parentViewController];
    }
    else{
        return nil;
    }
    
}


@end