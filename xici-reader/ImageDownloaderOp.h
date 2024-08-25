
#import <Foundation/Foundation.h>
#import "ForumImage.h"

@protocol ImageDownloaderOpDelegate;

@interface ImageDownloaderOp : NSOperation {
    
}

@property (nonatomic, assign) id <ImageDownloaderOpDelegate> delegate;
@property (nonatomic, readonly, strong) ForumImage *forumImage;
@property (nonatomic,  readonly, strong) NSString*  batchId;


- (id)initWithForumImage:(ForumImage *)forumImage  delegate:(id<ImageDownloaderOpDelegate>) theDelegate;
- (id)initWithForumImage:(ForumImage *)forumImage batchId:(NSString*)batchId delegate:(id<ImageDownloaderOpDelegate>) theDelegate;

-( NSString* )identifier;

@end

@protocol ImageDownloaderOpDelegate <NSObject>

- (void)finishDownload:(ImageDownloaderOp *)downloader;

@end