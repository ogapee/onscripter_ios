#import "DataCopier.h"

@implementation DataCopier

- (int) copy {
#ifdef MAGIC_FILE
    char *magic = MAGIC_FILE;
#else
    char *magic = ".ONS.COPY.DONE";
#endif

    NSString* src_path = [[NSBundle mainBundle] pathForResource:@"ONS" ofType:@""];

    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* dst_path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ONS"];
    NSString* magic_path = [dst_path stringByAppendingPathComponent:[NSString stringWithCString: magic encoding:NSUTF8StringEncoding]];

    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:dst_path]){
        if ([fm fileExistsAtPath:magic_path]) return 0;
        // delete and copy again
        //[fm removeItemAtPath:dst_path error:nil];
    }
    else
        [fm createDirectoryAtPath:dst_path withIntermediateDirectories: YES attributes: nil error:nil];

    int src_num = [self countFileRecursively:src_path];

    UIWindow *uiwindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    uiwindow.rootViewController = self;
    [uiwindow makeKeyAndVisible];

    progressBar = [[UIProgressView alloc] initWithFrame:CGRectMake(30.0f, 50.0f, 240.0f, 90.0f)];
    progressBar.progressViewStyle = UIProgressViewStyleDefault;
    progressBar.progress = 0.0f;

    progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 60.0f, 240.0f, 20.0f)];
    progressLabel.backgroundColor = [UIColor clearColor];
    progressLabel.font = [UIFont fontWithName:@"Courier" size:16];

    is_visible = FALSE;
    [self buildDialog];

    is_running = YES;
    dst_num = 0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [fm setDelegate:self];
        [self copyFileRecursively:src_path toPath:dst_path];
        is_running = NO;
    });

    while(is_running){
        [self buildDialog];
        [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

        if (src_num > 0) progressBar.progress = (float)dst_num / src_num;
        progressLabel.text = [NSString stringWithFormat:@"%qi/%qi", dst_num, src_num];
    }

    NSArray* dpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* dpath = [[dpaths objectAtIndex:0] stringByAppendingPathComponent:@"ONS"];
    [fm createDirectoryAtPath:dpath withIntermediateDirectories: YES attributes: nil error:nil];

    [fm createFileAtPath:magic_path contents:nil attributes:nil];

    return 0;
}

- (void)buildDialog
{
    if (is_visible) return;

    ac = [UIAlertController alertControllerWithTitle:@"Copying archives from Resources.\n\n" 
                            message:@""
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

- (BOOL)fileManager:(NSFileManager*)fm shouldProceedAfterError:(NSError*)error copyingItemAtPath:(NSString*)srcPath toPath:(NSString*)dstPath {
  if ([error code] == NSFileWriteFileExistsError){
    BOOL isDir;
    if ([fm fileExistsAtPath:dstPath isDirectory:&isDir] && !isDir){
      [fm removeItemAtPath:dstPath error:nil];
      [fm copyItemAtPath:srcPath toPath:dstPath error:nil];
    }
    return YES;
  }
  else
    return NO;
}

- (int)countFileRecursively:(NSString*)path{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *arr = [fm contentsOfDirectoryAtPath:path error:nil];

    int count=0;
    for (NSString *item in arr){
        NSString *path2 = [path stringByAppendingPathComponent:item];
        BOOL is_dir;
        [fm fileExistsAtPath:path2 isDirectory:&is_dir];
        if (is_dir) count += [self countFileRecursively:path2];
        else count++;
    }

    return count;
}

- (void)copyFileRecursively:(NSString*)src_path toPath:(NSString*)dst_path{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *src_arr = [fm contentsOfDirectoryAtPath:src_path error:nil];
    NSArray *dst_arr = [fm contentsOfDirectoryAtPath:dst_path error:nil];

    for (NSString *item in src_arr){
        NSString *src_path2 = [src_path stringByAppendingPathComponent:item];
        NSString *dst_path2 = [dst_path stringByAppendingPathComponent:item];
        BOOL isDir;
        [fm fileExistsAtPath:src_path2 isDirectory:&isDir];
        if (isDir){
            [fm createDirectoryAtPath:dst_path2 withIntermediateDirectories:YES attributes: nil error:nil];
            [self copyFileRecursively:src_path2 toPath:dst_path2];
        }
        else{
            if ([fm fileExistsAtPath:dst_path2])
                [fm removeItemAtPath:dst_path2 error:nil];
            dst_num++;
            [fm copyItemAtPath:src_path2 toPath:dst_path2 error:nil];
        }
    }
}
@end
