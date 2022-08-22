/*
 * Copyright (c) 2020-2021 Taner Sener
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

#include <ffmpegkit/FFmpegKitConfig.h>
#include <ffmpegkit/FFmpegKit.h>
#include <ffmpegkit/FFprobeKit.h>
#include <ffmpegkit/FFmpegSession.h>
#include "AppDelegate.h"
#include "ConcurrentExecutionViewController.h"
#include "Video.h"

@interface ConcurrentExecutionViewController ()

@property (strong, nonatomic) IBOutlet UILabel *header;
@property (strong, nonatomic) IBOutlet UIButton *encode1Button;
@property (strong, nonatomic) IBOutlet UIButton *encode2Button;
@property (strong, nonatomic) IBOutlet UIButton *encode3Button;
@property (strong, nonatomic) IBOutlet UIButton *cancel1Button;
@property (strong, nonatomic) IBOutlet UIButton *cancel2Button;
@property (strong, nonatomic) IBOutlet UIButton *cancel3Button;
@property (strong, nonatomic) IBOutlet UIButton *cancelAllButton;
@property (strong, nonatomic) IBOutlet UITextView *outputText;

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
    [Util applyHeaderStyle: self.header];

    addUIAction(^{
        [self setActive];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

    NSLog(@"FFmpeg process starting for button %d with arguments '%@'.\n", buttonNumber, ffmpegCommand);

    FFmpegSession* session = [FFmpegKit executeAsync:ffmpegCommand withCompleteCallback:^(FFmpegSession* session) {
        SessionState state = [session getState];
        ReturnCode* returnCode = [session getReturnCode];
        
        if ([ReturnCode isCancel:returnCode]) {
            NSLog(@"FFmpeg process ended with cancel for button %d with sessionId %ld.", buttonNumber, [session getSessionId]);
        } else {
            NSLog(@"FFmpeg process ended with state %lu and rc %@ for button %d with sessionId %ld.%@", state, returnCode, buttonNumber, [session getSessionId], notNull([session getFailStackTrace], @"\n"));
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
            [FFmpegKitConfig setSessionHistorySize:3];
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
    self.outputText.text = [self.outputText.text stringByAppendingString:message];

    if (self.outputText.text.length > 0 ) {
        NSRange bottom = NSMakeRange(self.outputText.text.length - 1, 1);
        [self.outputText scrollRangeToVisible:bottom];
    }
}

@end
