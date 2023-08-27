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

import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter/level.dart';
import 'package:ffmpeg_kit_flutter/packages.dart';
import 'package:ffmpeg_kit_flutter/signal.dart';

import 'util.dart';

class Test {
  static void testCommonApiMethods() async {
    ffprint("Testing common api methods.");

    final version = await FFmpegKitConfig.getFFmpegVersion();
    ffprint("FFmpeg version: $version");
    final platform = await FFmpegKitConfig.getPlatform();
    ffprint("Platform: $platform");
    ffprint(
        "Old log level: " + Level.levelToString(FFmpegKitConfig.getLogLevel()));
    await FFmpegKitConfig.setLogLevel(Level.avLogInfo);
    ffprint(
        "New log level: " + Level.levelToString(FFmpegKitConfig.getLogLevel()));
    final packageName = await Packages.getPackageName();
    ffprint("Package name: $packageName");
    Packages.getExternalLibraries().then((packageList) {
      packageList.forEach((value) => ffprint("External library: $value"));
    });
    await FFmpegKitConfig.ignoreSignal(Signal.sigXCpu);
  }

  static void testParseArguments() {
    ffprint("Testing parseArguments.");

    _testParseSimpleCommand();
    _testParseSingleQuotesInCommand();
    _testParseDoubleQuotesInCommand();
    _testParseDoubleQuotesAndEscapesInCommand();
  }

  static void _testParseSimpleCommand() {
    var argumentArray = FFmpegKitConfig.parseArguments(
        "-hide_banner -loop 1 -i file.jpg -filter_complex [0:v]setpts=PTS-STARTPTS[video] -map [video] -fps_mode cfr video.mp4");

    assert(argumentArray.length == 12);

    assert("-hide_banner" == argumentArray[0]);
    assert("-loop" == argumentArray[1]);
    assert("1" == argumentArray[2]);
    assert("-i" == argumentArray[3]);
    assert("file.jpg" == argumentArray[4]);
    assert("-filter_complex" == argumentArray[5]);
    assert("[0:v]setpts=PTS-STARTPTS[video]" == argumentArray[6]);
    assert("-map" == argumentArray[7]);
    assert("[video]" == argumentArray[8]);
    assert("-fps_mode" == argumentArray[9]);
    assert("cfr" == argumentArray[10]);
    assert("video.mp4" == argumentArray[11]);
  }

  static void _testParseSingleQuotesInCommand() {
    var argumentArray = FFmpegKitConfig.parseArguments(
        "-loop 1 'file one.jpg'  -filter_complex  '[0:v]setpts=PTS-STARTPTS[video]'  -map  [video]  video.mp4 ");

    assert(argumentArray.length == 8);

    assert("-loop" == argumentArray[0]);
    assert("1" == argumentArray[1]);
    assert("file one.jpg" == argumentArray[2]);
    assert("-filter_complex" == argumentArray[3]);
    assert("[0:v]setpts=PTS-STARTPTS[video]" == argumentArray[4]);
    assert("-map" == argumentArray[5]);
    assert("[video]" == argumentArray[6]);
    assert("video.mp4" == argumentArray[7]);
  }

  static void _testParseDoubleQuotesInCommand() {
    var argumentArray = FFmpegKitConfig.parseArguments(
        "-loop  1 \"file one.jpg\"   -filter_complex \"[0:v]setpts=PTS-STARTPTS[video]\"  -map  [video]  video.mp4 ");

    assert(argumentArray.length == 8);

    assert("-loop" == argumentArray[0]);
    assert("1" == argumentArray[1]);
    assert("file one.jpg" == argumentArray[2]);
    assert("-filter_complex" == argumentArray[3]);
    assert("[0:v]setpts=PTS-STARTPTS[video]" == argumentArray[4]);
    assert("-map" == argumentArray[5]);
    assert("[video]" == argumentArray[6]);
    assert("video.mp4" == argumentArray[7]);

    argumentArray = FFmpegKitConfig.parseArguments(
        " -i   file:///tmp/input.mp4 -vcodec libx264 -vf \"scale=1024:1024,pad=width=1024:height=1024:x=0:y=0:color=black\"  -acodec copy  -q:v 0  -q:a   0 video.mp4");

    assert(argumentArray.length == 13);

    assert("-i" == argumentArray[0]);
    assert("file:///tmp/input.mp4" == argumentArray[1]);
    assert("-vcodec" == argumentArray[2]);
    assert("libx264" == argumentArray[3]);
    assert("-vf" == argumentArray[4]);
    assert("scale=1024:1024,pad=width=1024:height=1024:x=0:y=0:color=black" ==
        argumentArray[5]);
    assert("-acodec" == argumentArray[6]);
    assert("copy" == argumentArray[7]);
    assert("-q:v" == argumentArray[8]);
    assert("0" == argumentArray[9]);
    assert("-q:a" == argumentArray[10]);
    assert("0" == argumentArray[11]);
    assert("video.mp4" == argumentArray[12]);
  }

  static void _testParseDoubleQuotesAndEscapesInCommand() {
    var argumentArray = FFmpegKitConfig.parseArguments(
        "  -i   file:///tmp/input.mp4 -vf \"subtitles=file:///tmp/subtitles.srt:force_style=\'FontSize=16,PrimaryColour=&HFFFFFF&\'\" -vcodec libx264   -acodec copy  -q:v 0 -q:a  0  video.mp4");

    assert(argumentArray.length == 13);

    assert("-i" == argumentArray[0]);
    assert("file:///tmp/input.mp4" == argumentArray[1]);
    assert("-vf" == argumentArray[2]);
    assert(
        "subtitles=file:///tmp/subtitles.srt:force_style='FontSize=16,PrimaryColour=&HFFFFFF&'" ==
            argumentArray[3]);
    assert("-vcodec" == argumentArray[4]);
    assert("libx264" == argumentArray[5]);
    assert("-acodec" == argumentArray[6]);
    assert("copy" == argumentArray[7]);
    assert("-q:v" == argumentArray[8]);
    assert("0" == argumentArray[9]);
    assert("-q:a" == argumentArray[10]);
    assert("0" == argumentArray[11]);
    assert("video.mp4" == argumentArray[12]);

    argumentArray = FFmpegKitConfig.parseArguments(
        "  -i   file:///tmp/input.mp4 -vf \"subtitles=file:///tmp/subtitles.srt:force_style=\\\"FontSize=16,PrimaryColour=&HFFFFFF&\\\"\" -vcodec libx264   -acodec copy  -q:v 0 -q:a  0  video.mp4");

    assert(argumentArray.length == 13);

    assert("-i" == argumentArray[0]);
    assert("file:///tmp/input.mp4" == argumentArray[1]);
    assert("-vf" == argumentArray[2]);
    assert(
        "subtitles=file:///tmp/subtitles.srt:force_style=\\\"FontSize=16,PrimaryColour=&HFFFFFF&\\\"" ==
            argumentArray[3]);
    assert("-vcodec" == argumentArray[4]);
    assert("libx264" == argumentArray[5]);
    assert("-acodec" == argumentArray[6]);
    assert("copy" == argumentArray[7]);
    assert("-q:v" == argumentArray[8]);
    assert("0" == argumentArray[9]);
    assert("-q:a" == argumentArray[10]);
    assert("0" == argumentArray[11]);
    assert("video.mp4" == argumentArray[12]);
  }

  static void setSessionHistorySizeTest() async {
    ffprint("Testing setSessionHistorySize.");

    int newSize = 15;
    await FFmpegKitConfig.setSessionHistorySize(newSize);
    for (int i = 1; i <= (newSize + 5); i++) {
      FFmpegSession.create(<String>["argument1", "argument2"]);
      assert((await FFmpegKitConfig.getSessions()).length <= newSize);
    }

    newSize = 3;
    await FFmpegKitConfig.setSessionHistorySize(newSize);
    for (int i = 1; i <= (newSize + 5); i++) {
      FFmpegSession.create(<String>["argument1", "argument2"]);
      assert((await FFmpegKitConfig.getSessions()).length <= newSize);
    }
  }
}
