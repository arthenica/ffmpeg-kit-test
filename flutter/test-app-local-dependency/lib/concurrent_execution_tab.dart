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

import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/log.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';

import 'abstract.dart';
import 'popup.dart';
import 'tooltip.dart';
import 'util.dart';
import 'video_util.dart';

class ConcurrentExecutionTab {
  late Refreshable _refreshable;
  String _outputText = "";
  late int? _sessionId1;
  late int? _sessionId2;
  late int? _sessionId3;

  void init(Refreshable refreshable) {
    _refreshable = refreshable;
    clearOutput();

    _sessionId1 = null;
    _sessionId2 = null;
    _sessionId3 = null;
  }

  void setActive() async {
    print("Concurrent Execution Tab Activated");
    await FFmpegKitConfig.clearSessions();
    FFmpegKitConfig.enableLogCallback(logCallback);
    FFmpegKitConfig.enableStatisticsCallback(null);
    showPopup(CONCURRENT_EXECUTION_TEST_TOOLTIP_TEXT);
  }

  void logCallback(Log log) {
    appendOutput("${log.getSessionId()}:${log.getMessage()}");
  }

  void appendOutput(String logMessage) {
    _outputText += logMessage;
    _refreshable.refresh();
  }

  void clearOutput() {
    _outputText = "";
    _refreshable.refresh();
  }

  void encodeVideo(int buttonNumber) {
    VideoUtil.assetPath(VideoUtil.ASSET_1).then((image1Path) {
      VideoUtil.assetPath(VideoUtil.ASSET_2).then((image2Path) {
        VideoUtil.assetPath(VideoUtil.ASSET_3).then((image3Path) {
          getVideoFile(buttonNumber).then((videoFile) {
            ffprint("Testing CONCURRENT EXECUTION for button $buttonNumber.");

            final ffmpegCommand = VideoUtil.generateEncodeVideoScript(
                image1Path,
                image2Path,
                image3Path,
                videoFile.path,
                "mpeg4",
                "");

            FFmpegKit.executeAsync(ffmpegCommand, (session) async {
              final sessionId = await session.getSessionId();
              final state = FFmpegKitConfig.sessionStateToString(
                  await session.getState());
              final returnCode = await session.getReturnCode();
              final failStackTrace = await session.getFailStackTrace();

              if (ReturnCode.isCancel(returnCode)) {
                ffprint(
                    "FFmpeg process ended with cancel for button ${buttonNumber} with sessionId ${sessionId}.");
              } else {
                ffprint(
                    "FFmpeg process ended with state ${state} and rc ${returnCode} for button ${buttonNumber} with sessionId ${sessionId}.${notNull(failStackTrace, "\\n")}");
              }
            }).then((session) {
              final sessionId = session.getSessionId();

              ffprint(
                  "Async FFmpeg process started for button ${buttonNumber} with sessionId ${sessionId}.");

              switch (buttonNumber) {
                case 1:
                  {
                    _sessionId1 = sessionId;
                  }
                  break;
                case 2:
                  {
                    _sessionId2 = sessionId;
                  }
                  break;
                default:
                  {
                    _sessionId3 = sessionId;
                    FFmpegKitConfig.setSessionHistorySize(3);
                  }
              }

              listFFmpegSessions();
            });
          });
        });
      });
    });
  }

  Future<File> getVideoFile(int buttonNumber) async {
    final String video = "video$buttonNumber.mp4";
    Directory documentsDirectory = await VideoUtil.documentsDirectory;
    return new File("${documentsDirectory.path}/$video");
  }

  void runCancel(final int buttonNumber) {
    int? sessionId = null;

    switch (buttonNumber) {
      case 1:
        {
          sessionId = _sessionId1;
        }
        break;
      case 2:
        {
          sessionId = _sessionId2;
        }
        break;
      case 3:
        {
          sessionId = _sessionId3;
        }
    }

    ffprint(
        "Cancelling FFmpeg process for button ${buttonNumber} with sessionId ${sessionId}.");

    FFmpegKit.cancel(sessionId);
  }

  String getOutputText() => _outputText;
}
