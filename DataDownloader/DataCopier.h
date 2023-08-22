#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface DataCopier : UIViewController {
    UIAlertController *ac;
    UIProgressView *progressBar;
    UILabel *progressLabel;
    volatile int dst_num;
    volatile BOOL is_running;
    volatile BOOL is_visible;
}

- (int)copy;
- (void)buildDialog;
- (BOOL)fileManager:(NSFileManager*)fm shouldProceedAfterError:(NSError*)error copyingItemAtPath:(NSString*)srcPath toPath:(NSString*)dstPath;
- (int)countFileRecursively:(NSString*)path;
- (void)copyFileRecursively:(NSString*)src_path toPath:(NSString*)dst_path;
@end

