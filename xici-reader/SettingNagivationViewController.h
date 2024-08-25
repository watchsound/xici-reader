//
//  SettingNagivationViewController.h
//  西祠利器
//
//  Created by Hanning Ni on 11/30/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingNagivationViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (retain) IBOutlet UITableView*  navigationTableView;
@property (retain) IBOutlet UIScrollView*  detailContainer;


-(void)showMySettingPane;

@end
