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
#include "VideoViewController.h"
#include "Video.h"

@interface VideoViewController ()

@property (strong, nonatomic) IBOutlet UILabel *header;
@property (strong, nonatomic) IBOutlet UIPickerView *videoCodecPicker;
@property (strong, nonatomic) IBOutlet UIButton *encodeButton;
@property (strong, nonatomic) IBOutlet UILabel *videoPlayerFrame;

@end

@implementation VideoViewController {

    // Video codec data
    NSArray *codecData;
    NSInteger selectedCodec;
    
    // Video player references
    AVQueuePlayer *player;
    AVPlayerLayer *playerLayer;
    AVPlayerItem *activeItem;
    
    // Loading view
    UIAlertController *alertController;
    UIActivityIndicatorView* indicator;

    Statistics *statistics;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // VIDEO CODEC PICKER INIT
    codecData = @[@"mpeg4", @"h264 (x264)", @"h264 (openh264)", @"h264 (videotoolbox)", @"x265", @"xvid", @"vp8", @"vp9", @"aom", @"kvazaar", @"theora", @"hap"];
    selectedCodec = 0;
    
    self.videoCodecPicker.dataSource = self;
    self.videoCodecPicker.delegate = self;

    // STYLE UPDATE
    [Util applyButtonStyle: self.encodeButton];
    [Util applyPickerViewStyle: self.videoCodecPicker];
    [Util applyVideoPlayerFrameStyle: self.videoPlayerFrame];
    [Util applyHeaderStyle: self.header];

    // VIDEO PLAYER INIT
    player = [[AVQueuePlayer alloc] init];
    playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    activeItem = nil;
    
    CGRect rectangularFrame = self.view.layer.bounds;
    rectangularFrame.size.width = self.view.layer.bounds.size.width - 40;
    rectangularFrame.origin.x = 20;
    rectangularFrame.origin.y = self.encodeButton.layer.bounds.origin.y + 120;
    
    playerLayer.frame = rectangularFrame;
    [self.view.layer addSublayer:playerLayer];

    alertController = nil;
    statistics = nil;

    addUIAction(^{
        [self setActive];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 * The number of columns of data
 */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

/**
 * The number of rows of data
 */
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return codecData.count;
}

/**
 * The data to return for the row and component (column) that's being passed in
 */
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return codecData[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    selectedCodec = row;
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

- (void)showProgressDialog:(NSString*) dialogMessage {

    // CLEAN STATISTICS
    statistics = nil;

    alertController = [UIAlertController alertControllerWithTitle:nil
                                                                     message:dialogMessage
                                                              preferredStyle:UIAlertControllerStyleAlert];
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.color = [UIColor blackColor];
    indicator.translatesAutoresizingMaskIntoConstraints=NO;
    [alertController.view addSubview:indicator];
    NSDictionary * views = @{@"pending" : alertController.view, @"indicator" : indicator};

    NSArray * constraintsVertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[indicator]-(20)-|" options:0 metrics:nil views:views];
    NSArray * constraintsHorizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[indicator]|" options:0 metrics:nil views:views];
    NSArray * constraints = [constraintsVertical arrayByAddingObjectsFromArray:constraintsHorizontal];
    [alertController.view addConstraints:constraints];
    [indicator startAnimating];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)updateProgressDialog {
    if (statistics == nil) {
        return;
    }

    if (alertController != nil) {
        int timeInMilliseconds = [statistics getTime];
        if (timeInMilliseconds > 0) {
            int totalVideoDuration = 9000;

            int percentage = timeInMilliseconds*100/totalVideoDuration;
            
            [alertController setMessage:[NSString stringWithFormat:@"Encoding video  %% %d \n\n", percentage]];
        }
    }
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
                
                [Util alert:self withTitle:@"Player Error" message:message andButtonText:@"OK"];
            }
        } break;
        default: {
            NSLog(@"Status %ld received from player.\n", status);
        }
    }
}

@end
