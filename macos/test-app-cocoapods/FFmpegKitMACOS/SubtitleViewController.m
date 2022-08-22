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
#include <ffmpegkit/FFmpegKit.h>
#include "SubtitleViewController.h"
#include "ProgressIndicator.h"
#include "Video.h"

typedef enum {
    IdleState = 1,
    CreatingState = 2,
    BurningState = 3
} UITestState;

@interface SubtitleViewController ()

@property (strong) IBOutlet NSButton *burnSubtitlesButton;
@property (strong) IBOutlet AVPlayerView *videoPlayerFrame;

@end

@implementation SubtitleViewController {

    // Video player references
    AVQueuePlayer *player;

    ProgressIndicator *indicator;

    Statistics *statistics;

    UITestState state;

    long sessionId;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // STYLE UPDATE
    [Util applyButtonStyle: self.burnSubtitlesButton];
    [Util applyVideoPlayerFrameStyle: self.videoPlayerFrame];

    // VIDEO PLAYER INIT
    player = [[AVQueuePlayer alloc] init];
    self.videoPlayerFrame.player = player;

    indicator = [[ProgressIndicator alloc] init];
    statistics = nil;

    state = IdleState;
    
    sessionId = 0;

    addUIAction(^{
        [self setActive];
    });
}

- (void)enableLogCallback {
    [FFmpegKitConfig enableLogCallback:^(Log* log){
        NSLog(@"%@", [log getMessage]);
    }];
}

- (void)enableStatisticsCallback {
    [FFmpegKitConfig enableStatisticsCallback:^(Statistics *statistics){
        addUIAction(^{
            self->statistics = statistics;
            [self updateProgressDialog];
        });
    }];
}

- (IBAction)burnSubtitles:(id)sender {
    NSString *resourceFolder = [[NSBundle mainBundle] resourcePath];
    NSString *image1 = [resourceFolder stringByAppendingPathComponent: @"machupicchu.jpg"];
    NSString *image2 = [resourceFolder stringByAppendingPathComponent: @"pyramid.jpg"];
    NSString *image3 = [resourceFolder stringByAppendingPathComponent: @"stonehenge.jpg"];
    NSString *subtitle = [self getSubtitlePath];
    NSString *videoFile = [self getVideoPath];
    NSString *videoWithSubtitlesFile = [self getVideoWithSubtitlesPath];
    
    if (player != nil) {
        [player removeAllItems];
    }

    NSLog(@"Testing SUBTITLE burning\n");

    [self showProgressDialog:@"Creating video\n\n"];

    NSString* ffmpegCommand = [Video generateVideoEncodeScript:image1:image2:image3:videoFile:@"mpeg4":@""];
    
    NSLog(@"FFmpeg process started with arguments '%@'.\n", ffmpegCommand);
    
    self->state = CreatingState;
    
    sessionId = [[FFmpegKit executeAsync:ffmpegCommand withCompleteCallback:^(FFmpegSession* session) {

        NSLog(@"FFmpeg process exited with state %@ and rc %@.%@", [FFmpegKitConfig sessionStateToString:[session getState]], [session getReturnCode], notNull([session getFailStackTrace], @"\n"));

        addUIAction(^{
            [self hideProgressDialog];
        });

        if ([ReturnCode isSuccess:[session getReturnCode]]) {
            NSLog(@"Create completed successfully; burning subtitles.\n");

            NSString *burnSubtitlesCommand = [NSString stringWithFormat:@"-hide_banner -y -i %@ -vf subtitles=%@:force_style='FontName=MyFontName' %@", videoFile, subtitle, videoWithSubtitlesFile];

            addUIAction(^{
                [self showProgressDialog:@"Burning subtitles\n\n"];
            });

            NSLog(@"FFmpeg process started with arguments '%@'.\n", burnSubtitlesCommand);

            self->state = BurningState;
            
            [FFmpegKit executeAsync:burnSubtitlesCommand withCompleteCallback:^(id<Session> secondSession) {
                
                addUIAction(^{
                    [self hideProgressDialog];

                    if ([ReturnCode isSuccess:[secondSession getReturnCode]]) {
                        NSLog(@"Burn subtitles completed successfully; playing video.\n");
                        [self playVideo];
                    } else if ([ReturnCode isCancel:[secondSession getReturnCode]]) {
                        NSLog(@"Burn subtitles operation cancelled\n");
                        [Util alert:self.view.window withTitle:@"Error" message:@"Burn subtitles operation cancelled." buttonText:@"OK" andHandler:nil];
                    } else {
                        NSLog(@"Burn subtitles failed with state %@ and rc %@.%@", [FFmpegKitConfig sessionStateToString:[secondSession getState]], [secondSession getReturnCode], notNull([secondSession getFailStackTrace], @"\n"));

                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.3 * NSEC_PER_SEC);
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            [self hideProgressDialogAndAlert:@"Burn subtitles failed. Please check logs for the details."];
                        });
                    }
                });
            }];
        }
    }] getSessionId];

    NSLog(@"Async FFmpeg process started with sessionId %ld.\n", sessionId);
}

- (void)playVideo {
    NSString *videoWithSubtitlesFile = [self getVideoWithSubtitlesPath];
    NSURL*videoWithSubtitlesURL=[NSURL fileURLWithPath:videoWithSubtitlesFile];
    
    AVAsset *asset = [AVAsset assetWithURL:videoWithSubtitlesURL];
    NSArray *assetKeys = @[@"playable", @"hasProtectedContent"];
    
    AVPlayerItem *newVideo = [AVPlayerItem playerItemWithAsset:asset
                                  automaticallyLoadedAssetKeys:assetKeys];
    
    [player insertItem:newVideo afterItem:nil];
    [player play];
}

- (NSString*)getSubtitlePath {
    NSString *resourceFolder = [[NSBundle mainBundle] resourcePath];
    return [resourceFolder stringByAppendingPathComponent: @"subtitle.srt"];
}

- (NSString*)getVideoPath {
    NSString* docFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [docFolder stringByAppendingPathComponent: @"video.mp4"];
}

- (NSString*)getVideoWithSubtitlesPath {
    NSString* docFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [docFolder stringByAppendingPathComponent: @"video-with-subtitles.mp4"];
}
- (void)setActive {
    NSLog(@"Subtitle Tab Activated");
    [self enableLogCallback];
    [self enableStatisticsCallback];
}

- (void)showProgressDialog:(NSString*)dialogMessage {

    // CLEAN STATISTICS
    statistics = nil;

    [indicator show:self.view message:dialogMessage indeterminate:false asyncBlock:^{
        if (self->state == CreatingState) {
            if (self->sessionId != 0) {
                [FFmpegKit cancel:self->sessionId];
            }
        } else if (self->state == BurningState) {
            [FFmpegKit cancel];
        }
    }];
}

- (void)updateProgressDialog {
    if (statistics == nil || [statistics getTime] < 0) {
        return;
    }

    int timeInMilliseconds = [statistics getTime];
    int totalVideoDuration = 9000;

    int percentage = timeInMilliseconds*100/totalVideoDuration;

    if (state == CreatingState) {
        [indicator updateMessage:@"Creating video" percentage:percentage];
    } else if (state == BurningState) {
        [indicator updateMessage:@"Burning subtitles" percentage:percentage];
    }
}

- (void)hideProgressDialog {
    [indicator hide];
}

- (void)hideProgressDialogAndAlert:(NSString*)message {
    [indicator hide];
    [Util alert:self.view.window withTitle:@"Error" message:message buttonText:@"OK" andHandler:nil];
}

@end
