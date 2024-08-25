//
//  PostCollectionViewController.h
//  西祠利器
//
//  Created by Hanning Ni on 12/1/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnywhereWebView.h"

@interface PostCollectionViewController : UIViewController<UIWebViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (retain) IBOutlet AnywhereWebview* webview;
@property (retain) IBOutlet UITableView*  tableview;
@property (retain) IBOutlet UIActivityIndicatorView*  loadingIndicator1;
@property (retain) IBOutlet UIActivityIndicatorView*  loadingIndicator2;

@property (nonatomic, strong) IBOutlet UIImageView* bgone;
@property (nonatomic, strong) IBOutlet UIImageView* bgtwo;

-(IBAction)backClicked:(id)sender;

@end
