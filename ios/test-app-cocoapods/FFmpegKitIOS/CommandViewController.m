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
#include "AppDelegate.h"
#include "CommandViewController.h"

@interface CommandViewController ()

@property (strong, nonatomic) IBOutlet UILabel *header;
@property (strong, nonatomic) IBOutlet UITextField *commandText;
@property (strong, nonatomic) IBOutlet UIButton *runFFmpegButton;
@property (strong, nonatomic) IBOutlet UIButton *runFFprobeButton;
@property (strong, nonatomic) IBOutlet UITextView *outputText;

@end

@implementation CommandViewController

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
    
    NSLog(@"FFmpeg process started with arguments\n'%@'.\n", ffmpegCommand);

    [FFmpegKit executeAsync:ffmpegCommand withExecuteCallback:^(id<Session> session) {
        SessionState state = [session getState];
        ReturnCode* returnCode = [session getReturnCode];

        NSLog(@"FFmpeg process exited with state %@ and rc %@.%@", [FFmpegKitConfig sessionStateToString:state], returnCode, notNull([session getFailStackTrace], @"\n"));

        if (state == SessionStateFailed || !returnCode.isSuccess) {
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
    
    NSLog(@"FFprobe process started with arguments\n'%@'.\n", ffprobeCommand);
    
    FFprobeSession *session = [[FFprobeSession alloc] init:[FFmpegKit parseArguments:ffprobeCommand] withExecuteCallback:^(id<Session> session) {
        SessionState state = [session getState];
        ReturnCode* returnCode = [session getReturnCode];

        addUIAction(^{
            [self appendOutput: [session getOutput]];
        });

        NSLog(@"FFprobe process exited with state %@ and rc %@.%@", [FFmpegKitConfig sessionStateToString:state], returnCode, notNull([session getFailStackTrace], @"\n"));

        if (state == SessionStateFailed || !returnCode.isSuccess) {
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
