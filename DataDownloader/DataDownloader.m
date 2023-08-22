#import "DataDownloader.h"
#import "HetimaUnZipContainer.h"

@implementation DataDownloader

- (int) download {
#ifdef ZIP_URL
    char *url = ZIP_URL;
#else
    char *url = "";
#endif
#ifdef MAGIC_FILE
    char *magic = MAGIC_FILE;
#else
    char *magic = ".ONS.COPY.DONE";
#endif

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    ons_path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ONS"];
    magic_path = [ons_path stringByAppendingPathComponent:[NSString stringWithCString: magic encoding:NSUTF8StringEncoding]];

    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:magic_path]) return 0;

    UIWindow *uiwindow = uiwindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    uiwindow.rootViewController = self;
    [uiwindow makeKeyAndVisible];

    progressBar = [[UIProgressView alloc] initWithFrame:CGRectMake(30.0f, 50.0f, 240.0f, 90.0f)];
    progressBar.progressViewStyle = UIProgressViewStyleDefault;
    progressBar.progress = 0.0f;

    progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 60.0f, 240.0f, 20.0f)];
    progressLabel.backgroundColor = [UIColor clearColor];
    progressLabel.font = [UIFont fontWithName:@"Courier" size:16];

    is_unzip_completed = NO;
    is_visible = FALSE;
    [self buildDialog];

    // waiting for download to be completed
    total_read = 0;
    num_retry = 0;
    is_completed = NO;
    while(YES){
        is_running = YES;
        NSString *url_path = [NSString stringWithCString: url encoding:NSUTF8StringEncoding];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url_path] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3.0f];
        if (total_read > 0){
            NSString *str = [NSString stringWithFormat:@"bytes=%qi-%qi", total_read, total_size];
            [req setValue:str forHTTPHeaderField:@"Range"];
            num_retry++;
        }
        con = [[NSURLConnection alloc] initWithRequest:req delegate:self];

        while(is_running){
            [self buildDialog];
            [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        if (con != nil){
            [con release];
            con = nil;
        }
        if (is_completed) break;

        if (num_retry > 100){
            [self showAlert:@"Download failed."];
            return -1;
        }
    }

    if (is_unzip_completed == NO) return -1;

    return 0;
}

- (void)buildDialog
{
    if (is_visible) return;

    NSString *str = [NSString stringWithFormat:@"Downloading archives from Internet:\n\n\n\n"];
    if (is_unzip_completed)
        str = [NSString stringWithFormat:@"Extracting archives:\n\n\n\n"];
    else if (num_retry > 0)
        str = [NSString stringWithFormat:@"Downloading archives from Internet:\nRetry %d\n\n\n", num_retry];

    ac = [UIAlertController alertControllerWithTitle:str message:@""
                            preferredStyle:UIAlertControllerStyleActionSheet ];

    [ac addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        is_visible = FALSE;
    }]];

    [ac.popoverPresentationController setPermittedArrowDirections:0];
    ac.popoverPresentationController.sourceView = self.view;
    ac.popoverPresentationController.sourceRect = CGRectMake(0, 0, 0, 0);

    [ac.view addSubview:progressBar];
    [ac.view addSubview:progressLabel];

    [self presentViewController:ac animated:YES completion:nil];

    is_visible = TRUE;
}

- (void)showAlert:(NSString*)mes
{
    is_alert_finished = NO;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:mes preferredStyle:UIAlertControllerStyleAlert ];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        is_alert_finished = YES;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        is_alert_finished = YES;
    }]];

    [alert.popoverPresentationController setPermittedArrowDirections:0];
    alert.popoverPresentationController.sourceView = self.view;
    alert.popoverPresentationController.sourceRect = CGRectMake(0, 0, 0, 0);
    [self presentViewController:alert animated:YES completion:nil];

    while(is_alert_finished == NO){
        [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

///////////////////////////////////////////////////////////////////////////////////////
// HetimaUnZipItemDelegate
- (void)item:(HetimaUnZipItem *)item didExtractDataOfLength:(NSUInteger)length {
    [self buildDialog];
    total_size += length;
    if (total_original_size > 0) progressBar.progress = (long double)total_size / total_original_size;
    progressLabel.text = [NSString stringWithFormat:@"%qi/%qiKB", total_size/1024, total_original_size/1024];
}

///////////////////////////////////////////////////////////////////////
- (void)connectionDidFinishLoading:(NSURLConnection *)con {
    [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	
    is_unzip_completed = YES;
    HetimaUnZipContainer *unzipContainer = [[HetimaUnZipContainer alloc] initWithZipFile:zip_path];
    [unzipContainer setListOnlyRealFile:YES];
	
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([[unzipContainer contents] count] == 0) {
        [self showAlert:NSLocalizedString(@"Timeout or zip file is not found.", nil)];
        is_unzip_completed = NO;
    } else {
        HetimaUnZipItem *item;
        NSEnumerator *contentsEnum = [[unzipContainer contents] objectEnumerator];
        total_size = 0;
        total_original_size = 0;
        for (item in contentsEnum)
            total_original_size += [item uncompressedSize];

        contentsEnum = [[unzipContainer contents] objectEnumerator];
        for (item in contentsEnum) {
            NSString *path = [ons_path stringByAppendingPathComponent:[item path]];
            if ([fm fileExistsAtPath:path])
                [fm removeItemAtPath:path error:nil];
            [fm createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories: YES attributes: nil error:nil];
            BOOL result = [item extractTo:path delegate:self];
            if (!result) {
                [self showAlert:[NSString stringWithFormat:@"Failed to extract %@.", [item path]]];
                is_unzip_completed = NO;
                break;
            }
        }
    }
	
    if (is_unzip_completed){
        NSArray* dpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* dpath = [[dpaths objectAtIndex:0] stringByAppendingPathComponent:@"ONS"];
        [fm createDirectoryAtPath:dpath withIntermediateDirectories: YES attributes: nil error:nil];

        [fm createFileAtPath:magic_path contents:nil attributes:nil];
    }
	
    is_completed = YES;
    [fm removeItemAtPath:zip_path error:nil];

    [unzipContainer release];

    is_running = NO;
}

- (void)connection:(NSURLConnection *)con didFailWithError:(NSError *)error {
    is_running = NO;
}

- (void)connection:(NSURLConnection *)con didReceiveResponse:(NSURLResponse *)res {
    NSString *path = [res suggestedFilename];
    zip_path = [[[NSTemporaryDirectory() stringByAppendingPathComponent:path] stringByStandardizingPath] retain];

    if (total_read == 0) total_size = [res expectedContentLength];
    progressBar.progress = 0.0f;
}

- (void)connection:(NSURLConnection *)con didReceiveData:(NSData *)data {
    @try {
        if (file == nil) {
            [[NSFileManager defaultManager] createFileAtPath:zip_path contents:[NSData data] attributes:nil];
            file = [[NSFileHandle fileHandleForWritingAtPath:zip_path] retain];
        }
        [file writeData:data];
    }
    @catch (NSException * e) {
        [con cancel];
    }

    total_read += [data length];
    if (total_size > 0) progressBar.progress = (float)total_read / total_size;
    progressLabel.text = [NSString stringWithFormat:@"%qi/%qiKB", total_read/1024, total_size/1024];
}
@end
