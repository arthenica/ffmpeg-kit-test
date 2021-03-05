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
#include "PipeViewController.h"
#include "ProgressIndicator.h"
#include "Video.h"

@interface PipeViewController ()

@property (strong) IBOutlet NSButton *createButton;
@property (strong) IBOutlet AVPlayerView *videoPlayerFrame;

@end

@implementation PipeViewController {

    // Video player references
    AVQueuePlayer *player;
    AVPlayerItem *activeItem;

    ProgressIndicator *indicator;

    Statistics *statistics;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // STYLE UPDATE
    [Util applyButtonStyle: self.createButton];
    [Util applyVideoPlayerFrameStyle: self.videoPlayerFrame];

    // VIDEO PLAYER INIT
    player = [[AVQueuePlayer alloc] init];
    self.videoPlayerFrame.player = player;
    activeItem = nil;

    indicator = [[ProgressIndicator alloc] init];

    statistics = nil;

    addUIAction(^{
        [self setActive];
    });
}

- (void)enableLogCallback {
    [FFmpegKitConfig enableLogCallback: ^(Log* log){
        addUIAction(^{
            NSLog(@"%@", [log getMessage]);
        });
    }];
}

- (void)enableStatisticsCallback {
    [FFmpegKitConfig enableStatisticsCallback:^(Statistics* statistics){
        addUIAction(^{
            self->statistics = statistics;
            [self updateProgressDialog];
        });
    }];
}

+ (void)startAsyncCopyImageProcess: (NSString*)imagePath onPipe:(NSString*)namedPipePath {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSLog(@"Starting copy %@ to pipe %@ operation.\n", imagePath, namedPipePath);

        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath: imagePath];
        if (fileHandle == nil) {
            NSLog(@"Failed to open file %@.\n", imagePath);
            return;
        }

        NSFileHandle *pipeHandle = [NSFileHandle fileHandleForWritingAtPath: namedPipePath];
        if (pipeHandle == nil) {
            NSLog(@"Failed to open pipe %@.\n", namedPipePath);
            [fileHandle closeFile];
            return;
        }

        int BUFFER_SIZE = 4096;
        unsigned long readBytes = 0;
        unsigned long totalBytes = 0;
        double startTime = CACurrentMediaTime();

        @try {
            [fileHandle seekToFileOffset: 0];

            do {
                NSData *data = [fileHandle readDataOfLength:BUFFER_SIZE];
                readBytes = [data length];
                if (readBytes > 0) {
                    totalBytes += readBytes;
                    [pipeHandle writeData:data];
                }
            } while (readBytes > 0);

            double endTime = CACurrentMediaTime();

            NSLog(@"Completed copy %@ to pipe %@ operation. %lu bytes copied in %f seconds.\n", imagePath, namedPipePath, totalBytes, (endTime - startTime));

        } @catch (NSException *e) {
            NSLog(@"Copy failed %@.\n", [e reason]);
        } @finally {
            [fileHandle closeFile];
            [pipeHandle closeFile];
        }
    });
}

- (IBAction)createVideo:(id)sender {
    NSString *resourceFolder = [[NSBundle mainBundle] resourcePath];
    NSString *image1 = [resourceFolder stringByAppendingPathComponent: @"machupicchu.jpg"];
    NSString *image2 = [resourceFolder stringByAppendingPathComponent: @"pyramid.jpg"];
    NSString *image3 = [resourceFolder stringByAppendingPathComponent: @"stonehenge.jpg"];
    NSString *videoFile = [self getVideoPath];

    NSString *pipe1 = [FFmpegKitConfig registerNewFFmpegPipe];
    NSString *pipe2 = [FFmpegKitConfig registerNewFFmpegPipe];
    NSString *pipe3 = [FFmpegKitConfig registerNewFFmpegPipe];
    
    if (player != nil) {
        [player removeAllItems];
        activeItem = nil;
    }

    [[NSFileManager defaultManager] removeItemAtPath:videoFile error:NULL];

    NSLog(@"Testing PIPE with 'mpeg4' codec\n");

    [self showProgressDialog:@"Creating video\n\n"];

    NSString* ffmpegCommand = [Video generateCreateVideoWithPipesScript:pipe1:pipe2:pipe3:videoFile];
    
    NSLog(@"FFmpeg process started with arguments\n'%@'.\n", ffmpegCommand);

    [FFmpegKit executeAsync:ffmpegCommand withExecuteCallback:^(id<Session> session) {
        SessionState state = [session getState];
        ReturnCode* returnCode = [session getReturnCode];

        NSLog(@"FFmpeg process exited with state %@ and rc %@.%@", [FFmpegKitConfig sessionStateToString:state], returnCode, notNull([session getFailStackTrace], @"\n"));

        addUIAction(^{
            [self hideProgressDialog];
        });

        // CLOSE PIPES
        [FFmpegKitConfig closeFFmpegPipe:pipe1];
        [FFmpegKitConfig closeFFmpegPipe:pipe2];
        [FFmpegKitConfig closeFFmpegPipe:pipe3];

        addUIAction(^{
            if ([ReturnCode isSuccess:returnCode]) {
                NSLog(@"Create completed successfully; playing video.\n");
                [self playVideo];
            } else {
                [self hideProgressDialogAndAlert:@"Create failed. Please check logs for the details."];
            }
        });
    }];
    
    // START ASYNC PROCESSES AFTER INITIATING FFMPEG COMMAND
    [PipeViewController startAsyncCopyImageProcess:image1 onPipe:pipe1];
    [PipeViewController startAsyncCopyImageProcess:image2 onPipe:pipe2];
    [PipeViewController startAsyncCopyImageProcess:image3 onPipe:pipe3];
}

- (void)playVideo {
    NSString *videoFile = [self getVideoPath];
    NSURL*videoURL=[NSURL fileURLWithPath:videoFile];

    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    NSArray *assetKeys = @[@"playable", @"hasProtectedContent"];

    AVPlayerItem *newVideo = [AVPlayerItem playerItemWithAsset:asset
                                  automaticallyLoadedAssetKeys:assetKeys];

    NSKeyValueObservingOptions options =
    NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew;

    activeItem = newVideo;

    [newVideo addObserver:self forKeyPath:@"status" options:options context:nil];

    [player insertItem:newVideo afterItem:nil];
}

- (NSString*)getVideoPath {
    NSString* docFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [docFolder stringByAppendingPathComponent: @"video.mp4"];
}

- (void)setActive {
    NSLog(@"Pipe Tab Activated");
    [self enableLogCallback];
    [self enableStatisticsCallback];
}

- (void)showProgressDialog:(NSString*)dialogMessage {

    // CLEAN STATISTICS
    statistics = nil;

    [indicator show:self.view message:dialogMessage indeterminate:false asyncBlock:nil];
}

- (void)updateProgressDialog {
    if (statistics == nil) {
        return;
    }

    int timeInMilliseconds = [statistics getTime];
    if (timeInMilliseconds > 0) {
        int totalVideoDuration = 9000;

        int percentage = timeInMilliseconds*100/totalVideoDuration;

        [indicator updatePercentage:percentage];
    }
}

- (void)hideProgressDialog {
    [indicator hide];
}

- (void)hideProgressDialogAndAlert: (NSString*)message {
    [indicator hide];
    [Util alert:self.view.window withTitle:@"Error" message:message buttonText:@"OK" andHandler:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    NSNumber *statusNumber = change[NSKeyValueChangeNewKey];
    NSInteger status = -1;
    if ([statusNumber isKindOfClass:[NSNumber class]]) {
        status = statusNumber.integerValue;
    }

    switch (status) {
        case AVPlayerItemStatusReadyToPlay: {
            [player play];
        } break;
        case AVPlayerItemStatusFailed: {
            if (activeItem != nil && activeItem.error != nil) {

                NSString *message = activeItem.error.localizedFailureReason;
                if (message == nil) {
                    message = activeItem.error.localizedDescription;
                }

                [Util alert:self.view.window withTitle:@"Player Error" message:message buttonText:@"OK" andHandler:nil];
            }
        } break;
        default: {
            NSLog(@"Status %ld received from player.\n", status);
        }
    }
}

@end
