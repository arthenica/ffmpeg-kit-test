/*
 * Copyright (c) 2018-2021 Taner Sener
 *
 * This file is part of FFmpegKitTest.
 *
 * FFmpegKitTest is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FFmpegKitTest is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with FFmpegKitTest.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <AVFoundation/AVFoundation.h>
#include <AVKit/AVKit.h>
#include <ffmpegkit/FFmpegKitConfig.h>
#include <ffmpegkit/FFmpegKit.h>
#include "VidStabViewController.h"
#include "ProgressIndicator.h"
#include "Video.h"

@interface VidStabViewController ()

@property (strong) IBOutlet NSButton *stabilizeVideoButton;
@property (strong) IBOutlet AVPlayerView *videoPlayerFrame;
@property (strong) IBOutlet AVPlayerView *stabilizedVideoPlayerFrame;

@end

@implementation VidStabViewController {
    AVQueuePlayer *player;
    AVQueuePlayer *stabilizedVideoPlayer;
    ProgressIndicator *indicator;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // STYLE UPDATE
    [Util applyButtonStyle: self.stabilizeVideoButton];
    [Util applyVideoPlayerFrameStyle: self.videoPlayerFrame];
    [Util applyVideoPlayerFrameStyle: self.stabilizedVideoPlayerFrame];

    // VIDEO PLAYER INIT
    player = [[AVQueuePlayer alloc] init];
    self.videoPlayerFrame.player = player;
    stabilizedVideoPlayer = [[AVQueuePlayer alloc] init];
    self.stabilizedVideoPlayerFrame.player = stabilizedVideoPlayer;

    indicator = [[ProgressIndicator alloc] init];

    addUIAction(^{
        [self setActive];
    });
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

    NSLog(@"FFmpeg process started with arguments\n'%@'.\n", ffmpegCommand);

    [FFmpegKit executeAsync:ffmpegCommand withExecuteCallback:^(id<Session> session) {
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

            NSLog(@"FFmpeg process started with arguments\n'%@'.\n", analyzeVideoCommand);

            [FFmpegKit executeAsync:analyzeVideoCommand withExecuteCallback:^(id<Session> secondSession) {

                NSLog(@"FFmpeg process exited with state %@ and rc %@.%@", [FFmpegKitConfig sessionStateToString:[secondSession getState]], [secondSession getReturnCode], notNull([secondSession getFailStackTrace], @"\n"));

                if ([ReturnCode isSuccess:[secondSession getReturnCode]]) {

                    NSString *stabilizeVideoCommand = [NSString stringWithFormat:@"-hide_banner -y -i %@ -vf vidstabtransform=smoothing=30:input=%@ %@", videoFile, shakeResultsFile, stabilizedVideoFile];
                    
                    NSLog(@"FFmpeg process started with arguments\n'%@'.\n", stabilizeVideoCommand);

                    [FFmpegKit executeAsync:stabilizeVideoCommand withExecuteCallback:^(id<Session> thirdSession) {

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
}

- (void)showProgressDialog:(NSString*)dialogMessage {
    [indicator show:self.view message:dialogMessage indeterminate:true asyncBlock:nil];
}

- (void)hideProgressDialog {
    [indicator hide];
}

- (void)hideProgressDialogAndAlert: (NSString*)message {
    [indicator hide];
    [Util alert:self.view.window withTitle:@"Error" message:message buttonText:@"OK" andHandler:nil];
}

@end
