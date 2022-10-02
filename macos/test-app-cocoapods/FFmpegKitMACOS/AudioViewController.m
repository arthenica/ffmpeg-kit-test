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
#include "AudioViewController.h"
#include "ProgressIndicator.h"

@interface AudioViewController ()

@property (strong) IBOutlet NSComboBox *audioCodecComboBox;
@property (strong) IBOutlet NSButton *encodeButton;
@property (strong) IBOutlet NSTextView *outputText;

@end

@implementation AudioViewController {

    // Video codec data
    NSArray *codecData;
    NSInteger selectedCodec;

    ProgressIndicator *indicator;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // AUDIO CODEC PICKER INIT
    codecData = @[@"aac (audiotoolbox)", @"mp2 (twolame)", @"mp3 (liblame)", @"mp3 (libshine)", @"vorbis", @"opus", @"amr-nb", @"amr-wb", @"ilbc", @"soxr", @"speex", @"wavpack"];
    selectedCodec = 0;

    [self.audioCodecComboBox setUsesDataSource:YES];
    self.audioCodecComboBox.dataSource = self;
    self.audioCodecComboBox.delegate = self;
    self.audioCodecComboBox.stringValue = codecData[selectedCodec];

    // STYLE UPDATE
    [Util applyComboBoxStyle: self.audioCodecComboBox];
    [Util applyButtonStyle: self.encodeButton];
    [Util applyOutputTextStyle: self.outputText];

    indicator = [[ProgressIndicator alloc] init];

    addUIAction(^{
        [self setActive];
    });
}

- (void)enableLogCallback {
    [FFmpegKitConfig enableLogCallback: ^(Log* log){
        addUIAction(^{
            [self appendOutput:[log getMessage]];
        });
    }];
}

- (void)disableLogCallback {
    [FFmpegKitConfig enableLogCallback:nil];
}

- (void)disableStatisticsCallback {
    [FFmpegKitConfig enableStatisticsCallback:nil];
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
    selectedCodec = [self.audioCodecComboBox indexOfSelectedItem];
}


- (IBAction)encodeAudio:(id)sender {
    [self disableLogCallback];
    [self createAudioSample];
    [self enableLogCallback];

    NSString *audioOutputFile = [self getAudioOutputFilePath];
    [[NSFileManager defaultManager] removeItemAtPath:audioOutputFile error:NULL];

    NSString *audioCodec = codecData[selectedCodec];
    
    NSLog(@"Testing AUDIO encoding with '%@' codec\n", audioCodec);
    
    NSString *ffmpegCommand = [self generateAudioEncodeScript];
    
    [self showProgressDialog:@"Encoding audio\n\n"];

    [self clearOutput];
        
    NSLog(@"FFmpeg process started with arguments '%@'.\n", ffmpegCommand);
    
    [FFmpegKit executeAsync:ffmpegCommand withCompleteCallback:^(FFmpegSession* session) {
        SessionState state = [session getState];
        ReturnCode* returnCode = [session getReturnCode];
        
        if ([ReturnCode isSuccess:returnCode]) {
            NSLog(@"Encode completed successfully.\n");
            addUIAction(^{
                [self hideProgressDialogAndAlert:@"Success" and:@"Encode completed successfully."];
            });
        } else {
            NSLog(@"Encode failed with state %@ and rc %@.%@", [FFmpegKitConfig sessionStateToString:state], returnCode, notNull([session getFailStackTrace], @"\n"));
            addUIAction(^{
                [self hideProgressDialogAndAlert:@"Error" and:@"Encode failed. Please check logs for the details."];
            });
        }
    }];
}

- (void)createAudioSample {
    NSLog(@"Creating AUDIO sample before the test.\n");
    
    NSString *audioSampleFile = [self getAudioSamplePath];
    [[NSFileManager defaultManager] removeItemAtPath:audioSampleFile error:NULL];
    
    NSString *ffmpegCommand = [NSString stringWithFormat:@"-y -f lavfi -i sine=frequency=1000:duration=5 -c:a pcm_s16le %@", audioSampleFile];
    
    NSLog(@"Creating audio sample with '%@'\n", ffmpegCommand);
    
    FFmpegSession* session = [FFmpegKit execute:ffmpegCommand];
    ReturnCode* returnCode = [session getReturnCode];
    if ([ReturnCode isSuccess:returnCode]) {
        NSLog(@"AUDIO sample created\n");
    } else {
        NSLog(@"Creating AUDIO sample failed with state %@ and rc %@.%@", [FFmpegKitConfig sessionStateToString:[session getState]], returnCode, notNull([session getFailStackTrace], @"\n"));
        addUIAction(^{
            [Util alert:self.view.window withTitle:@"Error" message:@"Creating AUDIO sample failed. Please check logs for the details." buttonText:@"OK" andHandler:nil];
        });
    }
}

- (NSString*)getAudioOutputFilePath {
    NSString *audioCodec = codecData[selectedCodec];
    
    NSString *extension;
    if ([audioCodec isEqualToString:@"aac (audiotoolbox)"]) {
        extension = @"m4a";
    } else if ([audioCodec isEqualToString:@"mp2 (twolame)"]) {
        extension = @"mpg";
    } else if ([audioCodec isEqualToString:@"mp3 (liblame)"] || [audioCodec isEqualToString:@"mp3 (libshine)"]) {
        extension = @"mp3";
    } else if ([audioCodec isEqualToString:@"vorbis"]) {
        extension = @"ogg";
    } else if ([audioCodec isEqualToString:@"opus"]) {
        extension = @"opus";
    } else if ([audioCodec isEqualToString:@"amr-nb"]) {
        extension = @"amr";
    } else if ([audioCodec isEqualToString:@"amr-wb"]) {
        extension = @"amr";
    } else if ([audioCodec isEqualToString:@"ilbc"]) {
        extension = @"lbc";
    } else if ([audioCodec isEqualToString:@"speex"]) {
        extension = @"spx";
    } else if ([audioCodec isEqualToString:@"wavpack"]) {
        extension = @"wv";
    } else {
        
        // soxr
        extension = @"wav";
    }
    
    NSString* docFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [[docFolder stringByAppendingPathComponent: @"audio."] stringByAppendingString: extension];
}

- (NSString*)getAudioSamplePath {
    NSString* docFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [docFolder stringByAppendingPathComponent: @"audio-sample.wav"];
}

- (void)setActive {
    NSLog(@"Audio Tab Activated");
    [self disableStatisticsCallback];
    [self enableLogCallback];
}

- (void)appendOutput:(NSString*) message {
    [self.outputText setString:[self.outputText.string stringByAppendingString:message]];
    [self.outputText scrollRangeToVisible:NSMakeRange([[self.outputText string] length], 0)];
}

- (void)clearOutput {
    [[self outputText] setString:@""];
}

- (void)showProgressDialog:(NSString*)dialogMessage {
    [indicator show:self.view message:@"Encoding video" indeterminate:false asyncBlock:nil];
}

- (void)hideProgressDialogAndAlert:(NSString*)title and:(NSString*)message {
    [indicator hide];
    [Util alert:self.view.window withTitle:title message:message buttonText:@"OK" andHandler:nil];
}

- (NSString*)generateAudioEncodeScript {
    NSString *audioCodec = codecData[selectedCodec];
    NSString *audioSampleFile = [self getAudioSamplePath];
    NSString *audioOutputFile = [self getAudioOutputFilePath];

    if ([audioCodec isEqualToString:@"aac (audiotoolbox)"]) {
        return [NSString stringWithFormat:@"-hide_banner -y -i %@ -c:a aac_at -b:a 192k %@", audioSampleFile, audioOutputFile];
    } else if ([audioCodec isEqualToString:@"mp2 (twolame)"]) {
        return [NSString stringWithFormat:@"-hide_banner -y -i %@ -c:a mp2 -b:a 192k %@", audioSampleFile, audioOutputFile];
    } else if ([audioCodec isEqualToString:@"mp3 (liblame)"]) {
        return [NSString stringWithFormat:@"-hide_banner -y -i %@ -c:a libmp3lame -qscale:a 2 %@", audioSampleFile, audioOutputFile];
    } else if ([audioCodec isEqualToString:@"mp3 (libshine)"]) {
        return [NSString stringWithFormat:@"-hide_banner -y -i %@ -c:a libshine -qscale:a 2 %@", audioSampleFile, audioOutputFile];
    } else if ([audioCodec isEqualToString:@"vorbis"]) {
        return [NSString stringWithFormat:@"-hide_banner -y -i %@ -c:a libvorbis -b:a 64k %@", audioSampleFile, audioOutputFile];
    } else if ([audioCodec isEqualToString:@"opus"]) {
        return [NSString stringWithFormat:@"-hide_banner -y -i %@ -c:a libopus -b:a 64k -vbr on -compression_level 10 %@", audioSampleFile, audioOutputFile];
    } else if ([audioCodec isEqualToString:@"amr-nb"]) {
        return [NSString stringWithFormat:@"-hide_banner -y -i %@ -ar 8000 -ab 12.2k -c:a libopencore_amrnb %@", audioSampleFile, audioOutputFile];
    } else if ([audioCodec isEqualToString:@"amr-wb"]) {
        return [NSString stringWithFormat:@"-hide_banner -y -i %@ -ar 8000 -ab 12.2k -c:a libvo_amrwbenc -strict experimental %@", audioSampleFile, audioOutputFile];
    } else if ([audioCodec isEqualToString:@"ilbc"]) {
        return [NSString stringWithFormat:@"-hide_banner -y -i %@ -c:a ilbc -ar 8000 -b:a 15200 %@", audioSampleFile, audioOutputFile];
    } else if ([audioCodec isEqualToString:@"speex"]) {
        return [NSString stringWithFormat:@"-hide_banner -y -i %@ -c:a libspeex -ar 16000 %@", audioSampleFile, audioOutputFile];
    } else if ([audioCodec isEqualToString:@"wavpack"]) {
        return [NSString stringWithFormat:@"-hide_banner -y -i %@ -c:a wavpack -b:a 64k %@", audioSampleFile, audioOutputFile];
    } else {

        // soxr
        return [NSString stringWithFormat:@"-hide_banner -y -i %@ -af aresample=resampler=soxr -ar 44100 %@", audioSampleFile, audioOutputFile];
    }
}

@end
