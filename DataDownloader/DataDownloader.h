#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "HetimaUnZipItem.h"

@interface DataDownloader : UIViewController<HetimaUnZipItemDelegate> {
    NSURLConnection *con;
    NSString *zip_path;
    NSString *magic_path;
    NSString *ons_path;
    NSFileHandle *file;

    UIAlertController *ac;
    UIProgressView *progressBar;
    UILabel *progressLabel;

    volatile BOOL is_running;
    volatile BOOL is_unzip_completed;
    volatile BOOL is_alert_finished;
    volatile BOOL is_completed;
    volatile BOOL is_visible;
    volatile int num_retry;
    volatile long long total_read;
    volatile long long total_size;
    volatile long long total_original_size;
}

- (int)download;
- (void)buildDialog;
- (void)showAlert:(NSString*)mes;
- (void)downloadDidFinish:(NSURLConnection *)con;
- (void)download:(NSURLConnection *)con didFailWithError:(NSError *)error;
- (void)download:(NSURLConnection *)con didReceiveData:(NSData *)data;
@end

