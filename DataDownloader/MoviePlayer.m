#import "MoviePlayer.h"

@implementation MoviePlayer

- (void)play:(NSString*)path click:(BOOL)click_flag loop:(BOOL)loop_flag {
    self->loop_flag = loop_flag;
    NSString *path2 = [path stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    NSURL *url = [NSURL fileURLWithPath:path2];
    playerItem = [AVPlayerItem playerItemWithURL:url];
    [playerItem addObserver:self forKeyPath:@"status" options:0 context:nil];

    [[NSNotificationCenter defaultCenter]
      addObserver:self
      selector:@selector(playerItemDidReachEnd:)
      name:AVPlayerItemDidPlayToEndTimeNotification
      object:player];

    UIWindow *uiwindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    uiwindow.rootViewController = self;
    [uiwindow makeKeyAndVisible];

    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation != UIInterfaceOrientationLandscapeLeft &&
        orientation != UIInterfaceOrientationLandscapeRight)
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];

    player = [[AVPlayerViewController alloc] init];
    player.showsPlaybackControls = false;
    player.player = [AVPlayer playerWithPlayerItem: playerItem];
    [self presentViewController:player animated:YES completion:nil];

    if (click_flag){
        // add tap handler
        UITapGestureRecognizer *tap_recog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tap_recog.delegate = self;
        tap_recog.numberOfTapsRequired = 1;
        [player.view addGestureRecognizer:tap_recog];
        [tap_recog release];
    }

    is_running = YES;
    while(is_running)
        [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

    [player release];

    uiwindow.hidden = YES;
    [uiwindow release];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    is_running = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
			change:(NSDictionary *)change context:(void *)context
{
    if (object == playerItem && [keyPath isEqualToString:@"status"]){
        if(playerItem.status == AVPlayerStatusReadyToPlay)
            [player.player play];
        else if(playerItem.status == AVPlayerStatusFailed){
          NSLog(@"AVPlayerStatusFailed");
          is_running = NO;
        }
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    if (loop_flag){
	[player.player seekToTime:kCMTimeZero];
        [player.player play];
    }
    else{
        [[NSNotificationCenter defaultCenter] removeObserver:self
					      name:AVPlayerItemDidPlayToEndTimeNotification
                                              object:player];

        [self dismissViewControllerAnimated:YES completion:nil];
        is_running = NO;
    }
}

@end
