//
//  FootprintViewController.h
//  西祠利器
//
//  Created by Hanning Ni on 12/2/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Forum.h"

#import "HttpService.h"
#import "HtmlDownloaderOp.h"
#import "R9ImageCacheManager.h"

@interface FootprintViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UITableViewDataSource, UITableViewDelegate, HtmlDownloaderOpDelegate,ImageDownloaderDelegate>


@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;


@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* indicator1;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* indicator2;

@property (nonatomic, strong) IBOutlet UIImageView* bgone;
@property (nonatomic, strong) IBOutlet UIImageView* bgtwo;



-(IBAction)backClicked:(id)sender;
-(IBAction)refreshClicked:(id)sender;

-(BOOL)addForum:(Forum*)forum;



@end
