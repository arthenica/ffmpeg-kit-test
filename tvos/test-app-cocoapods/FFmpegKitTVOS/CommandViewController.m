/*
 * Copyright (c) 2018-2022 Taner Sener
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
#include "AppDelegate.h"
#include "CommandViewController.h"

@interface CommandViewController ()

@property (strong, nonatomic) IBOutlet UILabel *header;
@property (strong, nonatomic) IBOutlet UITextField *commandText;
@property (strong, nonatomic) IBOutlet UIButton *runFFmpegButton;
@property (strong, nonatomic) IBOutlet UIButton *runFFprobeButton;
@property (strong, nonatomic) IBOutlet UITextView *outputText;

@end

@implementation CommandViewController {
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // STYLE UPDATE
    [Util applyEditTextStyle: self.commandText];
    [Util applyButtonStyle: self.runFFmpegButton];
    [Util applyButtonStyle: self.runFFprobeButton];
    [Util applyOutputTextStyle: self.outputText];
    [Util applyHeaderStyle: self.header];

    addUIAction(^{
        [self setActive];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)runFFmpeg:(id)sender {
    [self clearOutput];
    
    [[self commandText] endEditing:TRUE];
    
    NSString *ffmpegCommand = [NSString stringWithFormat:@"-hide_banner %@", [[self commandText] text]];
    
    NSLog(@"Current log level is %d.\n", [FFmpegKitConfig getLogLevel]);

    NSLog(@"Testing FFmpeg COMMAND asynchronously.\n");
    
    NSLog(@"FFmpeg process started with arguments '%@'.\n", ffmpegCommand);

    [FFmpegKit executeAsync:ffmpegCommand withCompleteCallback:^(FFmpegSession* session) {
        SessionState state = [session getState];
        ReturnCode* returnCode = [session getReturnCode];

        NSLog(@"FFmpeg process exited with state %@ and rc %@.%@", [FFmpegKitConfig sessionStateToString:state], returnCode, notNull([session getFailStackTrace], @"\n"));

        if (state == SessionStateFailed || !returnCode.isValueSuccess) {
            addUIAction(^{
                [Util alert:self withTitle:@"Error" message:@"Command failed. Please check output for the details." andButtonText:@"OK"];
            });
        }
    } withLogCallback:^(Log *log) {
        addUIAction(^{
            [self appendOutput: [log getMessage]];
        });
    } withStatisticsCallback:nil];
}

- (IBAction)runFFprobe:(id)sender {
    [self clearOutput];
    
    [[self commandText] endEditing:TRUE];
    
    NSString *ffprobeCommand = [NSString stringWithFormat:@"-hide_banner %@", [[self commandText] text]];
    
    NSLog(@"Testing FFprobe COMMAND asynchronously.\n");
    
    NSLog(@"FFprobe process started with arguments '%@'.\n", ffprobeCommand);
    
    FFprobeSession *session = [FFprobeSession create:[FFmpegKitConfig parseArguments:ffprobeCommand] withCompleteCallback:^(FFprobeSession* session) {
        SessionState state = [session getState];
        ReturnCode* returnCode = [session getReturnCode];

        addUIAction(^{
            [self appendOutput: [session getOutput]];
        });

        NSLog(@"FFprobe process exited with state %@ and rc %@.%@", [FFmpegKitConfig sessionStateToString:state], returnCode, notNull([session getFailStackTrace], @"\n"));

        if (state == SessionStateFailed || !returnCode.isValueSuccess) {
            addUIAction(^{
                [Util alert:self withTitle:@"Error" message:@"Command failed. Please check output for the details." andButtonText:@"OK"];
            });
        }
    } withLogCallback:nil withLogRedirectionStrategy:LogRedirectionStrategyNeverPrintLogs];

    [FFmpegKitConfig asyncFFprobeExecute:session];
    
    [AppDelegate listFFprobeSessions];
}

- (void)setActive {
    NSLog(@"Command Tab Activated");
    [FFmpegKitConfig enableLogCallback:nil];
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
