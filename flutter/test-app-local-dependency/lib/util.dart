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

import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/level.dart';
import 'package:ffmpeg_kit_flutter/session.dart';

String today() {
  var now = new DateTime.now();
  return "${now.year}-${now.month}-${now.day}";
}

String now() {
  var now = new DateTime.now();
  return "${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}:${now.second}.${now.millisecond}";
}

void ffprint(String text) {
  final pattern = new RegExp('.{1,900}');
  var nowString = now();
  pattern
      .allMatches(text)
      .forEach((match) => print("$nowString - " + match.group(0)!));
}

String notNull(String? string, [String valuePrefix = ""]) {
  return (string == null) ? "" : valuePrefix + string;
}

void deleteFile(File file) {
  file.exists().then((exists) {
    if (exists) {
      try {
        file.delete();
      } on Exception catch (e, stack) {
        print("Exception thrown inside deleteFile block. $e");
        print(stack);
      }
    }
  });
}

void listFFprobeSessions() {
  FFprobeKit.listSessions().then((sessionList) {
    ffprint("Listing ${sessionList.length} FFprobe sessions asynchronously.");

    int count = 0;
    sessionList.forEach((session) async {
      final sessionId = session.getSessionId();
      final startTime = session.getStartTime();
      final duration = await session.getDuration();
      final state =
          FFmpegKitConfig.sessionStateToString(await session.getState());
      final returnCode = await session.getReturnCode();

      ffprint(
          "Session ${count++} = id:${sessionId}, startTime:${startTime}, duration:${duration}, state:${state}, returnCode:${returnCode}.");
    });
  });
}

void listFFmpegSessions() {
  FFmpegKit.listSessions().then((sessionList) {
    ffprint("Listing ${sessionList.length} FFmpeg sessions asynchronously.");

    int count = 0;
    sessionList.forEach((session) async {
      final sessionId = session.getSessionId();
      final startTime = session.getStartTime();
      final duration = await session.getDuration();
      final state =
          FFmpegKitConfig.sessionStateToString(await session.getState());
      final returnCode = await session.getReturnCode();

      ffprint(
          "Session ${count++} = id:${sessionId}, startTime:${startTime}, duration:${duration}, state:${state}, returnCode:${returnCode}.");
    });
  });
}

void listAllLogs(Session session) async {
  ffprint("Listing log entries for session: ${session.getSessionId()}");
  var allLogs = await session.getAllLogs();
  allLogs.forEach((element) {
    ffprint(
        "${Level.levelToString(element.getLevel())}:${element.getMessage()}");
  });
  ffprint("Listed log entries for session: ${session.getSessionId()}");
}

void listAllStatistics(FFmpegSession session) async {
  ffprint("Listing statistics entries for session: ${session.getSessionId()}");
  var allStatistics = await session.getAllStatistics();

  allStatistics.forEach((s) {
    ffprint(
        "${s.getVideoFrameNumber()}:${s.getVideoFps()}:${s.getVideoQuality()}:${s.getSize()}:${s.getTime()}:${s.getBitrate()}:${s.getSpeed()}");
  });
  ffprint("Listed statistics entries for session: ${session.getSessionId()}");
}
