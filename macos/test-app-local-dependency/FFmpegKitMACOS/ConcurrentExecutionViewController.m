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

#include <ffmpegkit/FFmpegKitConfig.h>
#include <ffmpegkit/FFmpegKit.h>
#include <ffmpegkit/FFprobeKit.h>
#include <ffmpegkit/FFmpegSession.h>
#include "AppDelegate.h"
#include "ConcurrentExecutionViewController.h"
#include "Video.h"

@interface ConcurrentExecutionViewController ()

@property (strong) IBOutlet NSButton *encode1Button;
@property (strong) IBOutlet NSButton *encode2Button;
@property (strong) IBOutlet NSButton *encode3Button;
@property (strong) IBOutlet NSButton *cancel1Button;
@property (strong) IBOutlet NSButton *cancel2Button;
@property (strong) IBOutlet NSButton *cancel3Button;
@property (strong) IBOutlet NSButton *cancelAllButton;
@property (strong) IBOutlet NSTextView *outputText;

@end

@implementation ConcurrentExecutionViewController {
    long sessionId1;
    long sessionId2;
    long sessionId3;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // STYLE UPDATE
    [Util applyButtonStyle: self.encode1Button];
    [Util applyButtonStyle: self.encode2Button];
    [Util applyButtonStyle: self.encode3Button];
    [Util applyButtonStyle: self.cancel1Button];
    [Util applyButtonStyle: self.cancel2Button];
    [Util applyButtonStyle: self.cancel3Button];
    [Util applyButtonStyle: self.cancelAllButton];
    [Util applyOutputTextStyle: self.outputText];

    addUIAction(^{
        [self setActive];
    });
}

- (void)enableLogCallback {
    [FFmpegKitConfig enableLogCallback: ^(Log* log){
        addUIAction(^{
            [self appendOutput: [NSString stringWithFormat:@"%ld -> %@", [log getSessionId], [log getMessage]]];
        });
    }];
}

- (IBAction)encode1Clicked:(id)sender {
    [self encodeVideo:1];
}

- (IBAction)encode2Clicked:(id)sender {
    [self encodeVideo:2];
}

- (IBAction)encode3Clicked:(id)sender {
    [self encodeVideo:3];
}

- (IBAction)cancel1Button:(id)sender {
    [self cancel:1];
}

- (IBAction)cancel2Button:(id)sender {
    [self cancel:2];
}

- (IBAction)cancel3Button:(id)sender {
    [self cancel:3];
}

- (IBAction)cancelAllButton:(id)sender {
    [self cancel:0];
}

- (void)encodeVideo:(int)buttonNumber {
    NSString* docFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *resourceFolder = [[NSBundle mainBundle] resourcePath];
    NSString *image1 = [resourceFolder stringByAppendingPathComponent: @"machupicchu.jpg"];
    NSString *image2 = [resourceFolder stringByAppendingPathComponent: @"pyramid.jpg"];
    NSString *image3 = [resourceFolder stringByAppendingPathComponent: @"stonehenge.jpg"];
    NSString *videoFile = [docFolder stringByAppendingPathComponent: [NSString stringWithFormat:@"video%d.mp4", buttonNumber]];

    NSLog(@"Testing CONCURRENT EXECUTION for button %d.\n", buttonNumber);

    NSString* ffmpegCommand = [Video generateVideoEncodeScript:image1:image2:image3:videoFile:@"mpeg4":@""];

    NSLog(@"FFmpeg process starting for button %d with arguments\n'%@'.\n", buttonNumber, ffmpegCommand);

    id<Session> session = [FFmpegKit executeAsync:ffmpegCommand withExecuteCallback:^(id<Session> session) {
        SessionState state = [session getState];
        ReturnCode* returnCode = [session getReturnCode];
        
        if ([ReturnCode isCancel:returnCode]) {
            NSLog(@"FFmpeg process ended with cancel for button %d with sessionId %ld.", buttonNumber, [session getSessionId]);
        } else {
            NSLog(@"FFmpeg process ended with state %@ and rc %@ for button %d with sessionId %ld.%@", [FFmpegKitConfig sessionStateToString:state], returnCode, buttonNumber, [session getSessionId], notNull([session getFailStackTrace], @"\n"));
        }
    }];
    
    long sessionId = [session getSessionId];

    NSLog(@"Async FFmpeg process started for button %d with sessionId %ld.\n", buttonNumber, sessionId);

    switch (buttonNumber) {
        case 1: {
            sessionId1 = sessionId;
        }
        break;
        case 2: {
            sessionId2 = sessionId;
        }
        break;
        default: {
            sessionId3 = sessionId;
        }
    }

    [AppDelegate listFFmpegSessions];
}

- (void)cancel:(int)buttonNumber {
    long sessionId = 0;

    switch (buttonNumber) {
        case 1: {
            sessionId = sessionId1;
        }
        break;
        case 2: {
            sessionId = sessionId2;
        }
        break;
        case 3: {
            sessionId = sessionId3;
        }
    }

    NSLog(@"Cancelling FFmpeg process for button %d with sessionId %ld.\n", buttonNumber, sessionId);

    if (sessionId == 0) {
        [FFmpegKit cancel];
    } else {
        [FFmpegKit cancel:sessionId];
    }
}

- (void)setActive {
    NSLog(@"Concurrent Execution Tab Activated");
    [self enableLogCallback];
}

- (void)appendOutput:(NSString*) message {
    [self.outputText setString:[self.outputText.string stringByAppendingString:message]];
    [self.outputText scrollRangeToVisible:NSMakeRange([[self.outputText string] length], 0)];
}

@end
