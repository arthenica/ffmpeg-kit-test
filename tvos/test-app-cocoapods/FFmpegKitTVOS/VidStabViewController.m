/*
 * Copyright (c) 2018-2021 Taner Sener
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include <AVFoundation/AVFoundation.h>
#include <AVKit/AVKit.h>
#include <ffmpegkit/FFmpegKitConfig.h>
#include <ffmpegkit/FFmpegKit.h>
#include "VidStabViewController.h"
#include "Video.h"

@interface VidStabViewController ()

@property (strong, nonatomic) IBOutlet UILabel *header;
@property (strong, nonatomic) IBOutlet UIButton *stabilizeVideoButton;
@property (strong, nonatomic) IBOutlet UILabel *videoPlayerFrame;
@property (strong, nonatomic) IBOutlet UILabel *stabilizedVideoPlayerFrame;

@end

@implementation VidStabViewController {

    // Video player references
    AVQueuePlayer *player;
    AVPlayerLayer *playerLayer;
    AVQueuePlayer *stabilizedVideoPlayer;
    AVPlayerLayer *stabilizedVideoPlayerLayer;

    // Loading view
    UIActivityIndicatorView* indicator;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // STYLE UPDATE
    [Util applyButtonStyle: self.stabilizeVideoButton];
    [Util applyVideoPlayerFrameStyle: self.videoPlayerFrame];
    [Util applyVideoPlayerFrameStyle: self.stabilizedVideoPlayerFrame];
    [Util applyHeaderStyle: self.header];

    // VIDEO PLAYER INIT
    player = [[AVQueuePlayer alloc] init];
    playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    stabilizedVideoPlayer = [[AVQueuePlayer alloc] init];
    stabilizedVideoPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:stabilizedVideoPlayer];

    // SETTING VIDEO FRAME POSITIONS
    CGRect upperRectangularFrame = CGRectMake(self.videoPlayerFrame.frame.origin.x + 20,
                                         self.videoPlayerFrame.frame.origin.y + 20,
                                         self.videoPlayerFrame.frame.size.width - 40,
                                         self.videoPlayerFrame.frame.size.height - 40);

    playerLayer.frame = upperRectangularFrame;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:playerLayer];

    CGRect lowerRectangularFrame = CGRectMake(self.stabilizedVideoPlayerFrame.frame.origin.x + 20,
                                              self.stabilizedVideoPlayerFrame.frame.origin.y + 20,
                                              self.stabilizedVideoPlayerFrame.frame.size.width - 40,
                                              self.stabilizedVideoPlayerFrame.frame.size.height - 40);

    stabilizedVideoPlayerLayer.frame = lowerRectangularFrame;
    stabilizedVideoPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:stabilizedVideoPlayerLayer];

    addUIAction(^{
        [self setActive];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)enableLogCallback {
    [FFmpegKitConfig enableLogCallback: ^(Log* log){
        NSLog(@"%@", [log getMessage]);
    }];
}

- (IBAction)stabilizedVideo:(id)sender {
    NSString *resourceFolder = [[NSBundle mainBundle] resourcePath];
    NSString *image1 = [resourceFolder stringByAppendingPathComponent: @"machupicchu.jpg"];
    NSString *image2 = [resourceFolder stringByAppendingPathComponent: @"pyramid.jpg"];
    NSString *image3 = [resourceFolder stringByAppendingPathComponent: @"stonehenge.jpg"];
    NSString *shakeResultsFile = [self getShakeResultsFilePath];
    NSString *videoFile = [self getVideoPath];
    NSString *stabilizedVideoFile = [self getStabilizedVideoPath];
    
    if (player != nil) {
        [player removeAllItems];
    }
    if (stabilizedVideoPlayer != nil) {
        [stabilizedVideoPlayer removeAllItems];
    }

    [[NSFileManager defaultManager] removeItemAtPath:shakeResultsFile error:NULL];
    [[NSFileManager defaultManager] removeItemAtPath:videoFile error:NULL];
    [[NSFileManager defaultManager] removeItemAtPath:stabilizedVideoFile error:NULL];
    
    NSLog(@"Testing VID.STAB\n");
    
    [self showProgressDialog:@"Creating video\n\n"];

    NSString* ffmpegCommand = [Video generateShakingVideoScript:image1:image2:image3:videoFile];

    NSLog(@"FFmpeg process started with arguments '%@'.\n", ffmpegCommand);

    [FFmpegKit executeAsync:ffmpegCommand withCompleteCallback:^(FFmpegSession* session) {
        NSLog(@"FFmpeg process exited with state %@ and rc %@.%@", [FFmpegKitConfig sessionStateToString:[session getState]], [session getReturnCode], notNull([session getFailStackTrace], @"\n"));

        addUIAction(^{
            [self hideProgressDialog];
        });

        if ([ReturnCode isSuccess:[session getReturnCode]]) {
            NSLog(@"Create completed successfully; stabilizing video.\n");
            
            NSString *analyzeVideoCommand = [NSString stringWithFormat:@"-hide_banner -y -i %@ -vf vidstabdetect=shakiness=10:accuracy=15:result=%@ -f null -", videoFile, shakeResultsFile];

            addUIAction(^{
                [self showProgressDialog:@"Stabilizing video\n\n"];
            });

            NSLog(@"FFmpeg process started with arguments '%@'.\n", analyzeVideoCommand);

            [FFmpegKit executeAsync:analyzeVideoCommand withCompleteCallback:^(id<Session> secondSession) {

                NSLog(@"FFmpeg process exited with state %@ and rc %@.%@", [FFmpegKitConfig sessionStateToString:[secondSession getState]], [secondSession getReturnCode], notNull([secondSession getFailStackTrace], @"\n"));

                if ([ReturnCode isSuccess:[secondSession getReturnCode]]) {

                    NSString *stabilizeVideoCommand = [NSString stringWithFormat:@"-hide_banner -y -i %@ -vf vidstabtransform=smoothing=30:input=%@ %@", videoFile, shakeResultsFile, stabilizedVideoFile];
                    
                    NSLog(@"FFmpeg process started with arguments '%@'.\n", stabilizeVideoCommand);

                    [FFmpegKit executeAsync:stabilizeVideoCommand withCompleteCallback:^(id<Session> thirdSession) {

                        NSLog(@"FFmpeg process exited with state %@ and rc %@.%@", [FFmpegKitConfig sessionStateToString:[thirdSession getState]], [thirdSession getReturnCode], notNull([thirdSession getFailStackTrace], @"\n"));

                        addUIAction(^{
                            [self hideProgressDialog];

                            if ([ReturnCode isSuccess:[thirdSession getReturnCode]]) {
                                NSLog(@"Stabilize video completed successfully; playing videos.\n");
                                [self playVideo];
                                [self playStabilizedVideo];
                            } else {
                                [self hideProgressDialogAndAlert:@"Stabilize video failed. Please check logs for the details."];
                            }
                        });
                    }];
                } else {
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.3 * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [self hideProgressDialogAndAlert:@"Stabilize video failed. Please check logs for the details."];
                    });
                }
            }];
        } else {
            addUIAction(^{
                [self hideProgressDialogAndAlert:@"Create video failed. Please check logs for the details."];
            });
        }
    }];
}

- (void)playVideo {
    NSString *videoFile = [self getVideoPath];
    NSURL*videoURL=[NSURL fileURLWithPath:videoFile];
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    NSArray *assetKeys = @[@"playable", @"hasProtectedContent"];
    AVPlayerItem *video = [AVPlayerItem playerItemWithAsset:asset
                                         automaticallyLoadedAssetKeys:assetKeys];
   
    [player insertItem:video afterItem:nil];
    [player play];
}

- (void)playStabilizedVideo {
    NSString *stabilizedVideoFile = [self getStabilizedVideoPath];
    NSURL*stabilizedVideoURL=[NSURL fileURLWithPath:stabilizedVideoFile];
    AVAsset *asset = [AVAsset assetWithURL:stabilizedVideoURL];
    NSArray *assetKeys = @[@"playable", @"hasProtectedContent"];
    AVPlayerItem *stabilizedVideo = [AVPlayerItem playerItemWithAsset:asset
                                  automaticallyLoadedAssetKeys:assetKeys];
    
    [stabilizedVideoPlayer insertItem:stabilizedVideo afterItem:nil];
    [stabilizedVideoPlayer play];
}

- (NSString*)getShakeResultsFilePath {
    NSString* docFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [docFolder stringByAppendingPathComponent: @"transforms.trf"];
}

- (NSString*)getVideoPath {
    NSString* docFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [docFolder stringByAppendingPathComponent: @"video.mp4"];
}

- (NSString*)getStabilizedVideoPath {
    NSString* docFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [docFolder stringByAppendingPathComponent: @"video-stabilized.mp4"];
}

- (void)setActive {
    NSLog(@"VidStab Tab Activated");
    [FFmpegKitConfig enableLogCallback:^(Log *log){
        NSLog(@"%@", [log getMessage]);
    }];
    [FFmpegKitConfig enableStatisticsCallback:nil];
}

- (void)showProgressDialog:(NSString*) dialogMessage {
    UIAlertController *pending = [UIAlertController alertControllerWithTitle:nil
                                                                     message:dialogMessage
                                                              preferredStyle:UIAlertControllerStyleAlert];
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.color = [UIColor blackColor];
    indicator.translatesAutoresizingMaskIntoConstraints=NO;
    [pending.view addSubview:indicator];
    NSDictionary * views = @{@"pending" : pending.view, @"indicator" : indicator};
    
    NSArray * constraintsVertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[indicator]-(20)-|" options:0 metrics:nil views:views];
    NSArray * constraintsHorizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[indicator]|" options:0 metrics:nil views:views];
    NSArray * constraints = [constraintsVertical arrayByAddingObjectsFromArray:constraintsHorizontal];
    [pending.view addConstraints:constraints];
    [indicator startAnimating];
    [self presentViewController:pending animated:YES completion:nil];
}

- (void)hideProgressDialog {
    [indicator stopAnimating];
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (void)hideProgressDialogAndAlert: (NSString*)message {
    [indicator stopAnimating];
    [self dismissViewControllerAnimated:TRUE completion:^{
        [Util alert:self withTitle:@"Error" message:message andButtonText:@"OK"];
    }];
}

@end
