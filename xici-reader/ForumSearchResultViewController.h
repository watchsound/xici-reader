//
//  ForumSearchResultViewController.h
//  西祠利器
//
//  Created by Hanning Ni on 11/30/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Forum.h"
#import "SearchResultRow.h"
#import "R9ImageCacheManager.h"

@protocol ForumSearchResultViewControllerDelegate <NSObject>

-(void)tryLoadMoreData;

@end

@interface ForumSearchResultViewController : UIViewController<ImageDownloaderDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>{
    
}


@property (retain) NSMutableArray* resultForumList;
@property (retain) IBOutlet UITableView* tableView;
@property (retain) UIPopoverController* searchPopoverController;
@property (assign) id <ForumSearchResultViewControllerDelegate>   reloadMoreDelegate;


-(void)showData:(NSMutableArray*)result;

@end
