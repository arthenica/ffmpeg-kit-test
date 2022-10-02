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

#include "MediaInformationParserTest.h"
#include <FFmpegKitConfig.h>
#include <FFmpegSession.h>
#include <FFprobeSession.h>

using namespace ffmpegkit;

void testParseSimpleCommand() {
    auto argumentList = FFmpegKitConfig::parseArguments("-hide_banner -loop 1 -i file.jpg -filter_complex [0:v]setpts=PTS-STARTPTS[video] -map [video] -vsync 2 -async 1 video.mp4");
    
    assert(14 == argumentList.size());

    auto it = argumentList.begin();
    assertString("-hide_banner", *it++);
    assertString("-loop", *it++);
    assertString("1", *it++);
    assertString("-i", *it++);
    assertString("file.jpg", *it++);
    assertString("-filter_complex", *it++);
    assertString("[0:v]setpts=PTS-STARTPTS[video]", *it++);
    assertString("-map", *it++);
    assertString("[video]", *it++);
    assertString("-vsync", *it++);
    assertString("2", *it++);
    assertString("-async", *it++);
    assertString("1", *it++);
    assertString("video.mp4", *it++);
}

void testParseSingleQuotesInCommand() {
    auto argumentList = FFmpegKitConfig::parseArguments("-loop 1 'file one.jpg'  -filter_complex  '[0:v]setpts=PTS-STARTPTS[video]'  -map  [video]  video.mp4 ");
    
    assert(8 == argumentList.size());

    auto it = argumentList.begin();
    assertString("-loop", *it++);
    assertString("1", *it++);
    assertString("file one.jpg", *it++);
    assertString("-filter_complex", *it++);
    assertString("[0:v]setpts=PTS-STARTPTS[video]", *it++);
    assertString("-map", *it++);
    assertString("[video]", *it++);
    assertString("video.mp4", *it++);
}

void testParseDoubleQuotesInCommand() {
    auto argumentList = FFmpegKitConfig::parseArguments("-loop  1 \"file one.jpg\"   -filter_complex \"[0:v]setpts=PTS-STARTPTS[video]\"  -map  [video]  video.mp4 ");
    
    assert(8 == argumentList.size());

    auto it = argumentList.begin();
    assertString("-loop", *it++);
    assertString("1", *it++);
    assertString("file one.jpg", *it++);
    assertString("-filter_complex", *it++);
    assertString("[0:v]setpts=PTS-STARTPTS[video]", *it++);
    assertString("-map", *it++);
    assertString("[video]", *it++);
    assertString("video.mp4", *it++);
    
    argumentList = FFmpegKitConfig::parseArguments(" -i   file:///tmp/input.mp4 -vcodec libx264 -vf \"scale=1024:1024,pad=width=1024:height=1024:x=0:y=0:color=black\"  -acodec copy  -q:v 0  -q:a   0 video.mp4");
    
    assert(13 == argumentList.size());

    it = argumentList.begin();
    assertString("-i", *it++);
    assertString("file:///tmp/input.mp4", *it++);
    assertString("-vcodec", *it++);
    assertString("libx264", *it++);
    assertString("-vf", *it++);
    assertString("scale=1024:1024,pad=width=1024:height=1024:x=0:y=0:color=black", *it++);
    assertString("-acodec", *it++);
    assertString("copy", *it++);
    assertString("-q:v", *it++);
    assertString("0", *it++);
    assertString("-q:a", *it++);
    assertString("0", *it++);
    assertString("video.mp4", *it++);
}

void testParseDoubleQuotesAndEscapesInCommand() {
    auto argumentList = FFmpegKitConfig::parseArguments("  -i   file:///tmp/input.mp4 -vf \"subtitles=file:///tmp/subtitles.srt:force_style=\'FontSize=16,PrimaryColour=&HFFFFFF&\'\" -vcodec libx264   -acodec copy  -q:v 0 -q:a  0  video.mp4");
    
    assert(13 == argumentList.size());

    auto it = argumentList.begin();
    assertString("-i", *it++);
    assertString("file:///tmp/input.mp4", *it++);
    assertString("-vf", *it++);
    assertString("subtitles=file:///tmp/subtitles.srt:force_style='FontSize=16,PrimaryColour=&HFFFFFF&'", *it++);
    assertString("-vcodec", *it++);
    assertString("libx264", *it++);
    assertString("-acodec", *it++);
    assertString("copy", *it++);
    assertString("-q:v", *it++);
    assertString("0", *it++);
    assertString("-q:a", *it++);
    assertString("0", *it++);
    assertString("video.mp4", *it++);
    
    argumentList = FFmpegKitConfig::parseArguments("  -i   file:///tmp/input.mp4 -vf \"subtitles=file:///tmp/subtitles.srt:force_style=\\\"FontSize=16,PrimaryColour=&HFFFFFF&\\\"\" -vcodec libx264   -acodec copy  -q:v 0 -q:a  0  video.mp4");
    
    assert(13 == argumentList.size());

    it = argumentList.begin();
    assertString("-i", *it++);
    assertString("file:///tmp/input.mp4", *it++);
    assertString("-vf", *it++);
    assertString("subtitles=file:///tmp/subtitles.srt:force_style=\\\"FontSize=16,PrimaryColour=&HFFFFFF&\\\"", *it++);
    assertString("-vcodec", *it++);
    assertString("libx264", *it++);
    assertString("-acodec", *it++);
    assertString("copy", *it++);
    assertString("-q:v", *it++);
    assertString("0", *it++);
    assertString("-q:a", *it++);
    assertString("0", *it++);
    assertString("video.mp4", *it++);
}

void getSessionIdTest() {
    const std::list<std::string> TEST_ARGUMENTS{"argument1", "argument2"};

    auto sessions1 = FFmpegSession::create(TEST_ARGUMENTS);
    auto sessions2 = FFprobeSession::create(TEST_ARGUMENTS);
    auto sessions3 = MediaInformationSession::create(TEST_ARGUMENTS);

    assert(sessions3->getSessionId() > sessions2->getSessionId());
    assert(sessions3->getSessionId() > sessions1->getSessionId());
    assert(sessions2->getSessionId() > sessions1->getSessionId());

    assert(sessions1->getSessionId() > 0);
    assert(sessions2->getSessionId() > 0);
    assert(sessions3->getSessionId() > 0);
}

void testFFmpegKit(void) {
    testParseSimpleCommand();
    testParseSingleQuotesInCommand();
    testParseDoubleQuotesInCommand();
    testParseDoubleQuotesAndEscapesInCommand();
    getSessionIdTest();

    std::cout << "FFmpegKitConfigTest passed." << std::endl;
}
