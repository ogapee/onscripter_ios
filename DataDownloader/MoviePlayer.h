#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MoviePlayer : UIViewController{
    BOOL loop_flag;
    volatile BOOL is_running;
    AVPlayerViewController *player;
    AVPlayerItem *playerItem;
}

- (int)play:(NSString*)path click:(BOOL)click_flag loop:(BOOL)loop_flag;
- (void)observeValueForKeyPath:(NSString *)keyPath;
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
			change:(NSDictionary *)change context:(void *)context;
- (void)playerItemDidReachEnd:(NSNotification *)notification;
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;
- (void)handleTap:(UITapGestureRecognizer *)gesture;
@end
