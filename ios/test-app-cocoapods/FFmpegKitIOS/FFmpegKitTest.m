/*
 * Copyright (c) 2019-2022 Taner Sener
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

#include <UIKit/UIKit.h>
#include "MediaInformationParserTest.h"
#include "ffmpegkit/FFmpegSession.h"
#include "ffmpegkit/FFprobeSession.h"

NSArray *parseArguments(NSString *command) {
    NSMutableArray *argumentArray = [[NSMutableArray alloc] init];
    NSMutableString *currentArgument = [[NSMutableString alloc] init];
    
    bool singleQuoteStarted = false;
    bool doubleQuoteStarted = false;
    
    for (int i = 0; i < command.length; i++) {
        unichar previousChar;
        if (i > 0) {
            previousChar = [command characterAtIndex:(i - 1)];
        } else {
            previousChar = 0;
        }
        char currentChar = [command characterAtIndex:i];
        
        if (currentChar == ' ') {
            if (singleQuoteStarted || doubleQuoteStarted) {
                [currentArgument appendFormat: @"%c", currentChar];
            } else if ([currentArgument length] > 0) {
                [argumentArray addObject: currentArgument];
                currentArgument = [[NSMutableString alloc] init];
            }
        } else if (currentChar == '\'' && (previousChar == 0 || previousChar != '\\')) {
            if (singleQuoteStarted) {
                singleQuoteStarted = false;
            } else if (doubleQuoteStarted) {
                [currentArgument appendFormat: @"%c", currentChar];
            } else {
                singleQuoteStarted = true;
            }
        } else if (currentChar == '\"' && (previousChar == 0 || previousChar != '\\')) {
            if (doubleQuoteStarted) {
                doubleQuoteStarted = false;
            } else if (singleQuoteStarted) {
                [currentArgument appendFormat: @"%c", currentChar];
            } else {
                doubleQuoteStarted = true;
            }
        } else {
            [currentArgument appendFormat: @"%c", currentChar];
        }
    }
    
    if ([currentArgument length] > 0) {
        [argumentArray addObject: currentArgument];
    }
    
    return argumentArray;
}

void testParseSimpleCommand() {
    NSArray *argumentArray = parseArguments(@"-hide_banner -loop 1 -i file.jpg -filter_complex [0:v]setpts=PTS-STARTPTS[video] -map [video] -vsync 2 -async 1 video.mp4");
    
    assert(argumentArray != nil);
    assertNumber([[NSNumber alloc] initWithInt:14], [[NSNumber alloc] initWithUnsignedLong: [argumentArray count]]);
    
    assertString(@"-hide_banner", argumentArray[0]);
    assertString(@"-loop", argumentArray[1]);
    assertString(@"1", argumentArray[2]);
    assertString(@"-i", argumentArray[3]);
    assertString(@"file.jpg", argumentArray[4]);
    assertString(@"-filter_complex", argumentArray[5]);
    assertString(@"[0:v]setpts=PTS-STARTPTS[video]", argumentArray[6]);
    assertString(@"-map", argumentArray[7]);
    assertString(@"[video]", argumentArray[8]);
    assertString(@"-vsync", argumentArray[9]);
    assertString(@"2", argumentArray[10]);
    assertString(@"-async", argumentArray[11]);
    assertString(@"1", argumentArray[12]);
    assertString(@"video.mp4", argumentArray[13]);
}

void testParseSingleQuotesInCommand() {
    NSArray *argumentArray = parseArguments(@"-loop 1 'file one.jpg'  -filter_complex  '[0:v]setpts=PTS-STARTPTS[video]'  -map  [video]  video.mp4 ");
    
    assert(argumentArray != nil);
    assertNumber([[NSNumber alloc] initWithInt:8], [[NSNumber alloc] initWithUnsignedLong: [argumentArray count]]);

    assertString(@"-loop", argumentArray[0]);
    assertString(@"1", argumentArray[1]);
    assertString(@"file one.jpg", argumentArray[2]);
    assertString(@"-filter_complex", argumentArray[3]);
    assertString(@"[0:v]setpts=PTS-STARTPTS[video]", argumentArray[4]);
    assertString(@"-map", argumentArray[5]);
    assertString(@"[video]", argumentArray[6]);
    assertString(@"video.mp4", argumentArray[7]);
}

void testParseDoubleQuotesInCommand() {
    NSArray *argumentArray = parseArguments(@"-loop  1 \"file one.jpg\"   -filter_complex \"[0:v]setpts=PTS-STARTPTS[video]\"  -map  [video]  video.mp4 ");
    
    assert(argumentArray != nil);
    assertNumber([[NSNumber alloc] initWithInt:8], [[NSNumber alloc] initWithUnsignedLong: [argumentArray count]]);

    assertString(@"-loop", argumentArray[0]);
    assertString(@"1", argumentArray[1]);
    assertString(@"file one.jpg", argumentArray[2]);
    assertString(@"-filter_complex", argumentArray[3]);
    assertString(@"[0:v]setpts=PTS-STARTPTS[video]", argumentArray[4]);
    assertString(@"-map", argumentArray[5]);
    assertString(@"[video]", argumentArray[6]);
    assertString(@"video.mp4", argumentArray[7]);
    
    argumentArray = parseArguments(@" -i   file:///tmp/input.mp4 -vcodec libx264 -vf \"scale=1024:1024,pad=width=1024:height=1024:x=0:y=0:color=black\"  -acodec copy  -q:v 0  -q:a   0 video.mp4");
    
    assert(argumentArray != nil);
    assertNumber([[NSNumber alloc] initWithInt:13], [[NSNumber alloc] initWithUnsignedLong: [argumentArray count]]);

    assertString(@"-i", argumentArray[0]);
    assertString(@"file:///tmp/input.mp4", argumentArray[1]);
    assertString(@"-vcodec", argumentArray[2]);
    assertString(@"libx264", argumentArray[3]);
    assertString(@"-vf", argumentArray[4]);
    assertString(@"scale=1024:1024,pad=width=1024:height=1024:x=0:y=0:color=black", argumentArray[5]);
    assertString(@"-acodec", argumentArray[6]);
    assertString(@"copy", argumentArray[7]);
    assertString(@"-q:v", argumentArray[8]);
    assertString(@"0", argumentArray[9]);
    assertString(@"-q:a", argumentArray[10]);
    assertString(@"0", argumentArray[11]);
    assertString(@"video.mp4", argumentArray[12]);
}

void testParseDoubleQuotesAndEscapesInCommand() {
    NSArray *argumentArray = parseArguments(@"  -i   file:///tmp/input.mp4 -vf \"subtitles=file:///tmp/subtitles.srt:force_style=\'FontSize=16,PrimaryColour=&HFFFFFF&\'\" -vcodec libx264   -acodec copy  -q:v 0 -q:a  0  video.mp4");
    
    assert(argumentArray != nil);
    assertNumber([[NSNumber alloc] initWithInt:13], [[NSNumber alloc] initWithUnsignedLong: [argumentArray count]]);

    assertString(@"-i", argumentArray[0]);
    assertString(@"file:///tmp/input.mp4", argumentArray[1]);
    assertString(@"-vf", argumentArray[2]);
    assertString(@"subtitles=file:///tmp/subtitles.srt:force_style='FontSize=16,PrimaryColour=&HFFFFFF&'", argumentArray[3]);
    assertString(@"-vcodec", argumentArray[4]);
    assertString(@"libx264", argumentArray[5]);
    assertString(@"-acodec", argumentArray[6]);
    assertString(@"copy", argumentArray[7]);
    assertString(@"-q:v", argumentArray[8]);
    assertString(@"0", argumentArray[9]);
    assertString(@"-q:a", argumentArray[10]);
    assertString(@"0", argumentArray[11]);
    assertString(@"video.mp4", argumentArray[12]);
    
    argumentArray = parseArguments(@"  -i   file:///tmp/input.mp4 -vf \"subtitles=file:///tmp/subtitles.srt:force_style=\\\"FontSize=16,PrimaryColour=&HFFFFFF&\\\"\" -vcodec libx264   -acodec copy  -q:v 0 -q:a  0  video.mp4");
    
    assert(argumentArray != nil);
    assertNumber([[NSNumber alloc] initWithInt:13], [[NSNumber alloc] initWithUnsignedLong: [argumentArray count]]);

    assertString(@"-i", argumentArray[0]);
    assertString(@"file:///tmp/input.mp4", argumentArray[1]);
    assertString(@"-vf", argumentArray[2]);
    assertString(@"subtitles=file:///tmp/subtitles.srt:force_style=\\\"FontSize=16,PrimaryColour=&HFFFFFF&\\\"", argumentArray[3]);
    assertString(@"-vcodec", argumentArray[4]);
    assertString(@"libx264", argumentArray[5]);
    assertString(@"-acodec", argumentArray[6]);
    assertString(@"copy", argumentArray[7]);
    assertString(@"-q:v", argumentArray[8]);
    assertString(@"0", argumentArray[9]);
    assertString(@"-q:a", argumentArray[10]);
    assertString(@"0", argumentArray[11]);
    assertString(@"video.mp4", argumentArray[12]);
}

void getSessionIdTest() {
    NSArray *TEST_ARGUMENTS = [[NSArray alloc] initWithObjects:@"argument1", @"argument2", nil];

    FFmpegSession *sessions1 = [FFmpegSession create:TEST_ARGUMENTS];
    FFprobeSession *sessions2 = [FFprobeSession create:TEST_ARGUMENTS];
    MediaInformationSession *sessions3 = [MediaInformationSession create:TEST_ARGUMENTS];

    assert([sessions3 getSessionId] > [sessions2 getSessionId]);
    assert([sessions3 getSessionId] > [sessions1 getSessionId]);
    assert([sessions2 getSessionId] > [sessions1 getSessionId]);

    assert([sessions1 getSessionId] > 0);
    assert([sessions2 getSessionId] > 0);
    assert([sessions3 getSessionId] > 0);
}

void setSessionHistorySizeTest() {
    NSArray *TEST_ARGUMENTS = [[NSArray alloc] initWithObjects:@"argument1", @"argument2", nil];
    int newSize = 15;
    [FFmpegKitConfig setSessionHistorySize:newSize];

    for (int i = 1; i <= (newSize + 5); i++) {
        [FFmpegSession create:TEST_ARGUMENTS];
        assert([[FFmpegKitConfig getSessions] count] <= newSize);
    }

    newSize = 3;
    [FFmpegKitConfig setSessionHistorySize:newSize];
    for (int i = 1; i <= (newSize + 5); i++) {
        [FFmpegSession create:TEST_ARGUMENTS];
        assert([[FFmpegKitConfig getSessions] count] <= newSize);
    }
}

void testFFmpegKit(void) {
    testParseSimpleCommand();
    testParseSingleQuotesInCommand();
    testParseDoubleQuotesInCommand();
    testParseDoubleQuotesAndEscapesInCommand();
    getSessionIdTest();
    setSessionHistorySizeTest();
    
    NSLog(@"FFmpegKitTest passed.");
}
