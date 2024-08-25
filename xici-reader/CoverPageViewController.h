//
//  CoverPageViewController.h
//  西祠利器
//
//  Created by Hanning Ni on 11/21/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JBKenBurnsView.h"
#import "Constants.h"
#import "DDSocialLoginDialog.h"

@interface CoverPageViewController : UIViewController<JBKenBurnsViewDelegate, DDSocialLoginDialogDelegate>

@property (retain) IBOutlet UIImageView*  xiciLogo;
@property (retain) IBOutlet UILabel*  welcomeLabel;
@property (retain) IBOutlet UILabel*  titleLabel;
@property (retain) IBOutlet UIButton*  loginButton;
@property (retain) IBOutlet JBKenBurnsView* kbImageView;


-(IBAction)loginButtonClicked:(id)sender;
-(IBAction)leftButtonClicked:(id)sender;

@end
