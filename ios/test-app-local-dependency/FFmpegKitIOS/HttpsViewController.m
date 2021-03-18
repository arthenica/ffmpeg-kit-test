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

#include <stdlib.h>
#include <ffmpegkit/FFmpegKitConfig.h>
#include <ffmpegkit/FFprobeKit.h>
#include "HttpsViewController.h"

@interface HttpsViewController ()

@property (strong, nonatomic) IBOutlet UILabel *header;
@property (strong, nonatomic) IBOutlet UITextField *urlText;
@property (strong, nonatomic) IBOutlet UIButton *getInfoFromUrlButton;
@property (strong, nonatomic) IBOutlet UIButton *getRandomInfoButton1;
@property (strong, nonatomic) IBOutlet UIButton *getRandomInfoButton2;
@property (strong, nonatomic) IBOutlet UIButton *getInfoAndFailButton;
@property (strong, nonatomic) IBOutlet UITextView *outputText;

@end

@implementation HttpsViewController {
    NSObject *outputLock;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // STYLE UPDATE
    [Util applyEditTextStyle: self.urlText];
    [Util applyButtonStyle: self.getInfoFromUrlButton];
    [Util applyButtonStyle: self.getRandomInfoButton1];
    [Util applyButtonStyle: self.getRandomInfoButton2];
    [Util applyButtonStyle: self.getInfoAndFailButton];
    [Util applyOutputTextStyle: self.outputText];
    [Util applyHeaderStyle: self.header];
    
    outputLock = [[NSObject alloc] init];

    addUIAction(^{
        [self setActive];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)runGetInfoFromUrl:(id)sender {
    [self runGetMediaInformation:1];
}

- (IBAction)runGetRandomInfo1:(id)sender {
    [self runGetMediaInformation:2];
}

- (IBAction)runGetRandomInfo2:(id)sender {
    [self runGetMediaInformation:3];
}

- (IBAction)runGetInfoAndFail:(id)sender {
    [self runGetMediaInformation:4];
}

- (void)runGetMediaInformation:(int)buttonNumber {

    // SELECT TEST URL
    NSString *testUrl;
    switch (buttonNumber) {
        case 1: {
            testUrl = [self.urlText text];
            if ([testUrl length] == 0) {
                testUrl = HTTPS_TEST_DEFAULT_URL;
                [self.urlText setText:testUrl];
            }
        }
        break;
        case 2:
        case 3: {
            testUrl = [self getRandomTestUrl];
        }
        break;
        case 4:
        default: {
            testUrl = HTTPS_TEST_FAIL_URL;
            [self.urlText setText:testUrl];
        }
    }

    NSLog(@"Testing HTTPS with for button %d using url %@.", buttonNumber, testUrl);

    if (buttonNumber == 4) {

        // ONLY THIS BUTTON CLEARS THE TEXT VIEW
        [self clearOutput];
    }

    [FFprobeKit getMediaInformationAsync:testUrl withExecuteCallback:[self createNewExecuteCallback]];
}

- (void)setActive {
    NSLog(@"Https Tab Activated");
    [FFmpegKitConfig enableLogCallback:nil];
    [FFmpegKitConfig enableStatisticsCallback:nil];
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

- (NSString*)getRandomTestUrl {
    switch (arc4random_uniform(3)) {
        case 0:
            return HTTPS_TEST_RANDOM_URL_1;
        case 1:
            return HTTPS_TEST_RANDOM_URL_2;
        default:
            return HTTPS_TEST_RANDOM_URL_3;
    }
}

- (ExecuteCallback)createNewExecuteCallback {
    return ^(id<Session> session){
        addUIAction(^{
            @synchronized (self->outputLock) {
                MediaInformation *information = [((MediaInformationSession*) session) getMediaInformation];
                if (information == nil) {
                    [self appendOutput:@"Get media information failed\n"];
                    [self appendOutput:[NSString stringWithFormat:@"State: %@\n", [FFmpegKitConfig sessionStateToString:[session getState]]]];
                    [self appendOutput:[NSString stringWithFormat:@"Duration: %ld\n", [session getDuration]]];
                    [self appendOutput:[NSString stringWithFormat:@"Return Code: %@\n", [session getReturnCode]]];
                    [self appendOutput:[NSString stringWithFormat:@"Fail stack trace: %@\n", notNull([session getFailStackTrace], @"\n")]];
                    [self appendOutput:[NSString stringWithFormat:@"Output: %@\n", [session getOutput]]];
                } else {
                    [self appendOutput:[NSString stringWithFormat:@"Media information for %@\n", [information getFilename]]];

                    if ([information getFormat] != nil) {
                        [self appendOutput:[NSString stringWithFormat:@"Format: %@\n", [information getFormat]]];
                    }
                    if ([information getBitrate] != nil) {
                        [self appendOutput:[NSString stringWithFormat:@"Bitrate: %@\n", [information getBitrate]]];
                    }
                    if ([information getDuration] != nil) {
                        [self appendOutput:[NSString stringWithFormat:@"Duration: %@\n", [information getDuration]]];
                    }
                    if ([information getStartTime] != nil) {
                        [self appendOutput:[NSString stringWithFormat:@"Start time: %@\n", [information getStartTime]]];
                    }
                    if ([information getTags] != nil) {
                        NSDictionary* tags = [information getTags];
                        for(NSString *key in [tags allKeys]) {
                            [self appendOutput:[NSString stringWithFormat:@"Tag: %@:%@", key, [tags objectForKey:key]]];
                        }
                    }
                    if ([information getStreams] != nil) {
                        for (StreamInformation* stream in [information getStreams]) {
                            if ([stream getIndex] != nil) {
                                [self appendOutput:[NSString stringWithFormat:@"Stream index: %@\n", [stream getIndex]]];
                            }
                            if ([stream getType] != nil) {
                                [self appendOutput:[NSString stringWithFormat:@"Stream type: %@\n", [stream getType]]];
                            }
                            if ([stream getCodec] != nil) {
                                [self appendOutput:[NSString stringWithFormat:@"Stream codec: %@\n", [stream getCodec]]];
                            }
                            if ([stream getFullCodec] != nil) {
                                [self appendOutput:[NSString stringWithFormat:@"Stream full codec: %@\n", [stream getFullCodec]]];
                            }
                            if ([stream getFormat] != nil) {
                                [self appendOutput:[NSString stringWithFormat:@"Stream format: %@\n", [stream getFormat]]];
                            }

                            if ([stream getWidth] != nil) {
                                [self appendOutput:[NSString stringWithFormat:@"Stream width: %@\n", [stream getWidth]]];
                            }
                            if ([stream getHeight] != nil) {
                                [self appendOutput:[NSString stringWithFormat:@"Stream height: %@\n", [stream getHeight]]];
                            }

                            if ([stream getBitrate] != nil) {
                                [self appendOutput:[NSString stringWithFormat:@"Stream bitrate: %@\n", [stream getBitrate]]];
                            }
                            if ([stream getSampleRate] != nil) {
                                [self appendOutput:[NSString stringWithFormat:@"Stream sample rate: %@\n", [stream getSampleRate]]];
                            }
                            if ([stream getSampleFormat] != nil) {
                                [self appendOutput:[NSString stringWithFormat:@"Stream sample format: %@\n", [stream getSampleFormat]]];
                            }
                            if ([stream getChannelLayout] != nil) {
                                [self appendOutput:[NSString stringWithFormat:@"Stream channel layout: %@\n", [stream getChannelLayout]]];
                            }

                            if ([stream getSampleAspectRatio] != nil) {
                                [self appendOutput:[NSString stringWithFormat:@"Stream sample aspect ratio: %@\n", [stream getSampleAspectRatio]]];
                            }
                            if ([stream getDisplayAspectRatio] != nil) {
                                [self appendOutput:[NSString stringWithFormat:@"Stream display ascpect ratio: %@\n", [stream getDisplayAspectRatio]]];
                            }
                            if ([stream getAverageFrameRate] != nil) {
                                [self appendOutput:[NSString stringWithFormat:@"Stream average frame rate: %@\n", [stream getAverageFrameRate]]];
                            }
                            if ([stream getRealFrameRate] != nil) {
                                [self appendOutput:[NSString stringWithFormat:@"Stream real frame rate: %@\n", [stream getRealFrameRate]]];
                            }
                            if ([stream getTimeBase] != nil) {
                                [self appendOutput:[NSString stringWithFormat:@"Stream time base: %@\n", [stream getTimeBase]]];
                            }
                            if ([stream getCodecTimeBase] != nil) {
                                [self appendOutput:[NSString stringWithFormat:@"Stream codec time base: %@\n", [stream getCodecTimeBase]]];
                            }

                            if ([stream getTags] != nil) {
                                NSDictionary* tags = [stream getTags];
                                for(NSString *key in [tags allKeys]) {
                                    [self appendOutput:[NSString stringWithFormat:@"Stream tag: %@:%@", key, [tags objectForKey:key]]];
                                }
                            }
                        }
                    }
                }
            }
        });
    };
}

@end
