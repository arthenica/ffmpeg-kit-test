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

#include <ffmpegkit/FFmpegKitConfig.h>
#include <ffmpegkit/FFmpegKit.h>
#include "OtherViewController.h"
#include "Video.h"

@interface OtherViewController ()

@property (strong, nonatomic) IBOutlet UILabel *header;
@property (strong, nonatomic) IBOutlet UITextField *otherTestText;
@property (strong, nonatomic) IBOutlet UIButton *runButton;
@property (strong, nonatomic) IBOutlet UITextView *outputText;

@end

@implementation OtherViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // STYLE UPDATE
    [Util applyEditTextStyle: self.otherTestText];
    [Util applyButtonStyle: self.runButton];
    [Util applyOutputTextStyle: self.outputText];
    [Util applyHeaderStyle: self.header];
    
    addUIAction(^{
        [self setActive];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)runTest:(id)sender {
    NSString *selectedTest = [self.otherTestText text];

    [self clearOutput];

    if ([selectedTest isEqualToString:@"chromaprint"]) {
        [self testChromaprint];
    } else if ([selectedTest isEqualToString:@"dav1d"]) {
        [self testDav1d];
    } else if ([selectedTest isEqualToString:@"webp"]) {
        [self testWebp];
    } else if ([selectedTest isEqualToString:@"zscale"]) {
        [self testZscale];
    }
}

-(void)testChromaprint {
    NSLog(@"Testing 'chromaprint' mutex\n");
    
    NSString *audioSampleFile = [self getChromaprintSamplePath];
    [[NSFileManager defaultManager] removeItemAtPath:audioSampleFile error:NULL];

    NSString *ffmpegCommand = [NSString stringWithFormat:@"-hide_banner -y -f lavfi -i sine=frequency=1000:duration=5 -c:a pcm_s16le %@", audioSampleFile];

    NSLog(@"Creating audio sample with '%@'.\n", ffmpegCommand);

    [FFmpegKit executeAsync:ffmpegCommand withCompleteCallback:^(FFmpegSession* session) {

        NSLog(@"FFmpeg process exited with state %@ and rc %@.%@", [FFmpegKitConfig sessionStateToString:[session getState]], [session getReturnCode], notNull([session getFailStackTrace], @"\n"));

        if ([ReturnCode isSuccess:[session getReturnCode]]) {

            NSLog(@"AUDIO sample created\n");

            NSString *chromaprintCommand = [NSString stringWithFormat:@"-hide_banner -y -i %@ -f chromaprint -fp_format 2 %@", audioSampleFile, [self getChromaprintOutputPath]];

            NSLog(@"FFmpeg process started with arguments '%@'.\n", chromaprintCommand);
            
            [FFmpegKit executeAsync:chromaprintCommand withCompleteCallback:^(FFmpegSession* session) {
                
                NSLog(@"FFmpeg process exited with state %@ and rc %@.%@", [FFmpegKitConfig sessionStateToString:[session getState]], [session getReturnCode], notNull([session getFailStackTrace], @"\n"));

            } withLogCallback:^(Log *log) {
                addUIAction(^{
                    [self appendOutput: [log getMessage]];
                });
            } withStatisticsCallback:nil];
        }
    }];
}

-(void)testDav1d {
    NSLog(@"Testing decoding 'av1' codec\n");

    NSString *ffmpegCommand = [NSString stringWithFormat:@"-hide_banner -y -i %@ %@", DAV1D_TEST_DEFAULT_URL, [self getDav1dOutputPath]];

    NSLog(@"FFmpeg process started with arguments '%@'.\n", ffmpegCommand);

    [FFmpegKit executeAsync:ffmpegCommand withCompleteCallback:^(FFmpegSession* session) {
        NSLog(@"FFmpeg process exited with state %@ and rc %@.%@", [FFmpegKitConfig sessionStateToString:[session getState]], [session getReturnCode], notNull([session getFailStackTrace], @"\n"));
    } withLogCallback:^(Log *log) {
        addUIAction(^{
            [self appendOutput: [log getMessage]];
        });
    } withStatisticsCallback:nil];
}

-(void)testWebp {
    NSString *resourceFolder = [[NSBundle mainBundle] resourcePath];
    NSString *imageFile = [resourceFolder stringByAppendingPathComponent: @"machupicchu.jpg"];
    NSString* docFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *outputFile = [docFolder stringByAppendingPathComponent: @"video.webp"];

    NSLog(@"Testing 'webp' codec\n");

    NSString *ffmpegCommand = [NSString stringWithFormat:@"-hide_banner -y -i %@ %@", imageFile, outputFile];

    NSLog(@"FFmpeg process started with arguments '%@'.\n", ffmpegCommand);

    [FFmpegKit executeAsync:ffmpegCommand withCompleteCallback:^(FFmpegSession* session) {

        NSLog(@"FFmpeg process exited with state %@ and rc %@.%@", [FFmpegKitConfig sessionStateToString:[session getState]], [session getReturnCode], notNull([session getFailStackTrace], @"\n"));

    } withLogCallback:^(Log *log) {
        addUIAction(^{
            [self appendOutput: [log getMessage]];
        });
    } withStatisticsCallback:nil];
}

-(void)testZscale {
    NSString* docFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *videoFile = [docFolder stringByAppendingPathComponent: @"video.mp4"];
    NSString *zscaledVideoFile = [docFolder stringByAppendingPathComponent: @"video.zscaled.mp4"];

    NSLog(@"Testing 'zscale' filter with video file created on the Video tab\n");

    NSString *ffmpegCommand = [Video generateZscaleVideoScript:videoFile:zscaledVideoFile];

    NSLog(@"FFmpeg process started with arguments '%@'.\n", ffmpegCommand);

    [FFmpegKit executeAsync:ffmpegCommand withCompleteCallback:^(FFmpegSession* session) {

        NSLog(@"FFmpeg process exited with state %@ and rc %@.%@", [FFmpegKitConfig sessionStateToString:[session getState]], [session getReturnCode], notNull([session getFailStackTrace], @"\n"));

    } withLogCallback:^(Log *log) {
        addUIAction(^{
            [self appendOutput: [log getMessage]];
        });
    } withStatisticsCallback:nil];
}

- (NSString*)getChromaprintSamplePath {
    NSString* docFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [docFolder stringByAppendingPathComponent: @"audio-sample.wav"];
}

- (NSString*)getDav1dOutputPath {
    NSString* docFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [docFolder stringByAppendingPathComponent: @"video.mp4"];
}

- (NSString*)getChromaprintOutputPath {
    NSString* docFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [docFolder stringByAppendingPathComponent: @"chromaprint.txt"];
}

- (void)setActive {
    NSLog(@"Other Tab Activated");
}

- (void)appendOutput:(NSString*) message {
    self.outputText.text = [self.outputText.text stringByAppendingString:message];
    
    if (self.outputText.text.length > 0 ) {
        NSRange bottom = NSMakeRange(self.outputText.text.length - 1, 1);
        [self.outputText scrollRangeToVisible:bottom];
    }
}

- (void)clearOutput {
    [[self outputText] setText:@""];
}

@end
