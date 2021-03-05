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
#include <ffmpegkit/FFmpegKit.h>
#include "VideoViewController.h"
#include "ProgressIndicator.h"
#include "Video.h"

@interface VideoViewController ()

@property (strong) IBOutlet NSComboBox *videoCodecComboBox;
@property (strong) IBOutlet NSButton *encodeButton;
@property (strong) IBOutlet AVPlayerView *videoPlayerFrame;

@end

@implementation VideoViewController {

    // Video codec data
    NSArray *codecData;
    NSInteger selectedCodec;

    // Video player references
    AVQueuePlayer *player;
    AVPlayerItem *activeItem;

    ProgressIndicator *indicator;

    Statistics *statistics;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // VIDEO CODEC PICKER INIT
    codecData = @[@"mpeg4", @"h264 (x264)", @"h264 (openh264)", @"h264 (videotoolbox)", @"x265", @"xvid", @"vp8", @"vp9", @"aom", @"kvazaar", @"theora", @"hap"];
    selectedCodec = 0;

    [self.videoCodecComboBox setUsesDataSource:YES];
    self.videoCodecComboBox.dataSource = self;
    self.videoCodecComboBox.delegate = self;
    self.videoCodecComboBox.stringValue = codecData[selectedCodec];

    // STYLE UPDATE
    [Util applyComboBoxStyle: self.videoCodecComboBox];
    [Util applyButtonStyle: self.encodeButton];
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

/**
 * Returns the index of the given string
 */
- (NSUInteger)comboBox:(NSComboBox *)comboBox indexOfItemWithStringValue:(NSString *)string {
    return [codecData indexOfObject:string];
}

/**
 * Returns the item  in the given row
 */
- (id)comboBox:(NSComboBox *)comboBox objectValueForItemAtIndex:(NSInteger)index {
    return codecData[index];
}

/**
 * Returns number of items
 */
- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox {
    return codecData.count;
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
    selectedCodec = [self.videoCodecComboBox indexOfSelectedItem];
}

- (IBAction)encodeVideo:(id)sender {
    NSString *resourceFolder = [[NSBundle mainBundle] resourcePath];
    NSString *image1 = [resourceFolder stringByAppendingPathComponent: @"machupicchu.jpg"];
    NSString *image2 = [resourceFolder stringByAppendingPathComponent: @"pyramid.jpg"];
    NSString *image3 = [resourceFolder stringByAppendingPathComponent: @"stonehenge.jpg"];
    NSString *videoFile = [self getVideoPath];

    if (player != nil) {
        [player removeAllItems];
        activeItem = nil;
    }

    [[NSFileManager defaultManager] removeItemAtPath:videoFile error:NULL];

    NSString *videoCodec = codecData[selectedCodec];

    NSLog(@"Testing VIDEO encoding with '%@' codec\n", videoCodec);

    [self showProgressDialog:@"Encoding video\n\n"];

    NSString* ffmpegCommand = [Video generateVideoEncodeScript:image1:image2:image3:videoFile:[self getSelectedVideoCodec]:[self getCustomOptions]];

    NSLog(@"FFmpeg process started with arguments\n'%@'.\n", ffmpegCommand);

    id<Session> session = [FFmpegKit executeAsync:ffmpegCommand withExecuteCallback:^(id<Session> session){
        SessionState state = [session getState];
        ReturnCode *returnCode = [session getReturnCode];

        addUIAction(^{
            [self hideProgressDialog];
        });

        if ([ReturnCode isSuccess:returnCode]) {
            NSLog(@"Encode completed successfully in %ld milliseconds; playing video.\n", [session getDuration]);
            addUIAction(^{
                [self playVideo];
            });
        } else {
            NSLog(@"Encode failed with state %@ and rc %@.%@", [FFmpegKitConfig sessionStateToString:state], returnCode, notNull([session getFailStackTrace], @"\n"));
            addUIAction(^{
                [self hideProgressDialogAndAlert:@"Encode failed. Please check logs for the details."];
            });
        }
    } withLogCallback:^(Log *log) {
        NSLog(@"%@", [log getMessage]);
    } withStatisticsCallback:^(Statistics *statistics) {
        addUIAction(^{
            self->statistics = statistics;
            [self updateProgressDialog];
        });
    }];

    NSLog(@"Async FFmpeg process started with sessionId %ld.\n", [session getSessionId]);
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

- (NSString*)getSelectedVideoCodec {
    NSString *videoCodec = codecData[selectedCodec];

    // VIDEO CODEC PICKER HAS BASIC NAMES, FFMPEG NEEDS LONGER AND EXACT CODEC NAMES.
    // APPLYING NECESSARY TRANSFORMATION HERE
    if ([videoCodec isEqualToString:@"h264 (x264)"]) {
        videoCodec = @"libx264";
    } else if ([videoCodec isEqualToString:@"h264 (openh264)"]) {
        videoCodec = @"libopenh264";
    } else if ([videoCodec isEqualToString:@"h264 (videotoolbox)"]) {
        videoCodec = @"h264_videotoolbox";
    } else if ([videoCodec isEqualToString:@"x265"]) {
        videoCodec = @"libx265";
    } else if ([videoCodec isEqualToString:@"xvid"]) {
        videoCodec = @"libxvid";
    } else if ([videoCodec isEqualToString:@"vp8"]) {
        videoCodec = @"libvpx";
    } else if ([videoCodec isEqualToString:@"vp9"]) {
        videoCodec = @"libvpx-vp9";
    } else if ([videoCodec isEqualToString:@"aom"]) {
        videoCodec = @"libaom-av1";
    } else if ([videoCodec isEqualToString:@"kvazaar"]) {
        videoCodec = @"libkvazaar";
    } else if ([videoCodec isEqualToString:@"theora"]) {
        videoCodec = @"libtheora";
    }

    return videoCodec;
}

- (NSString*)getVideoPath {
    NSString *videoCodec = codecData[selectedCodec];

    NSString *extension;
    if ([videoCodec isEqualToString:@"vp8"] || [videoCodec isEqualToString:@"vp9"]) {
        extension = @"webm";
    } else if ([videoCodec isEqualToString:@"aom"]) {
        extension = @"mkv";
    } else if ([videoCodec isEqualToString:@"theora"]) {
        extension = @"ogv";
    } else if ([videoCodec isEqualToString:@"hap"]) {
        extension = @"mov";
    } else {

        // mpeg4, x264, x265, xvid, kvazaar
        extension = @"mp4";
    }

    NSString* docFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [[docFolder stringByAppendingPathComponent: @"video."] stringByAppendingString: extension];
}

- (NSString*)getCustomOptions {
    NSString *videoCodec = codecData[selectedCodec];

    if ([videoCodec isEqualToString:@"x265"]) {
        return @"-crf 28 -preset fast ";
    } else if ([videoCodec isEqualToString:@"vp8"]) {
        return @"-b:v 1M -crf 10 ";
    } else if ([videoCodec isEqualToString:@"vp9"]) {
        return @"-b:v 2M ";
    } else if ([videoCodec isEqualToString:@"aom"]) {
        return @"-crf 30 -strict experimental ";
    } else if ([videoCodec isEqualToString:@"theora"]) {
        return @"-qscale:v 7 ";
    } else if ([videoCodec isEqualToString:@"hap"]) {
        return @"-format hap_q ";
    } else {
        return @"";
    }
}

- (void)setActive {
    NSLog(@"Video Tab Activated");
    [FFmpegKitConfig enableLogCallback:nil];
    [FFmpegKitConfig enableStatisticsCallback:nil];
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
