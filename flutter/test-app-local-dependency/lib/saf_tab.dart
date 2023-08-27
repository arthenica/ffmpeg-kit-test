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

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/log.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:ffmpeg_kit_flutter/statistics.dart';

import 'abstract.dart';
import 'popup.dart';
import 'tooltip.dart';
import 'util.dart';
import 'video_util.dart';

class SafTab {
  late RefreshablePlayerDialogFactory _refreshablePlayerDialogFactory;
  String _outputText = "";
  late Statistics? _statistics;

  void init(RefreshablePlayerDialogFactory refreshablePlayerDialogFactory) {
    _refreshablePlayerDialogFactory = refreshablePlayerDialogFactory;
    _statistics = null;
    this.clearOutput();
  }

  void setActive() {
    print("SAF Tab Activated");
    FFmpegKitConfig.enableLogCallback(this.logCallback);
    FFmpegKitConfig.enableStatisticsCallback(this.statisticsCallback);
    showPopup(SAF_TEST_TOOLTIP_TEXT);
  }

  void logCallback(Log log) {
    this.appendOutput(log.getMessage());
  }

  void statisticsCallback(Statistics statistics) {
    this._statistics = statistics;
    this.updateProgressDialog();
  }

  void appendOutput(String logMessage) {
    _outputText += logMessage;
    _refreshablePlayerDialogFactory.refresh();
  }

  void clearOutput() {
    _outputText = "";
    _refreshablePlayerDialogFactory.refresh();
  }

  void runFFprobe() {
    FFmpegKitConfig.selectDocumentForRead(
        "*/*", ["image/*", "video/*", "audio/*"]).then((uri) {
      FFmpegKitConfig.getSafParameterForRead(uri!).then((safUrl) {
        this.clearOutput();

        final String ffprobeCommand =
            "-hide_banner -print_format json -show_format -show_streams ${safUrl}";

        ffprint("Testing FFprobe COMMAND asynchronously.");

        ffprint("FFprobe process started with arguments: '$ffprobeCommand'");

        FFprobeKit.execute(ffprobeCommand).then((session) async {
          final state =
              FFmpegKitConfig.sessionStateToString(await session.getState());
          final returnCode = await session.getReturnCode();
          final failStackTrace = await session.getFailStackTrace();
          session.getOutput().then((output) => this.appendOutput(output ?? ""));

          ffprint(
              "FFprobe process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}");

          if (!ReturnCode.isSuccess(returnCode)) {
            showPopup("Command failed. Please check output for the details.");
          }
        });
      });
    });
  }

  void encodeVideo() {
    FFmpegKitConfig.selectDocumentForWrite("video.mp4", "video/*").then((uri) {
      FFmpegKitConfig.getSafParameterForWrite(uri!).then((safUrl) {
        VideoUtil.assetPath(VideoUtil.ASSET_1).then((image1Path) {
          VideoUtil.assetPath(VideoUtil.ASSET_2).then((image2Path) {
            VideoUtil.assetPath(VideoUtil.ASSET_3).then((image3Path) {
              final String videoFile = safUrl!;

              final videoCodec = 'mpeg4';

              ffprint("Testing VIDEO encoding with '${videoCodec}' codec");

              this.hideProgressDialog();
              this.showProgressDialog();

              final ffmpegCommand = VideoUtil.generateEncodeVideoScript(
                  image1Path,
                  image2Path,
                  image3Path,
                  videoFile,
                  videoCodec,
                  "");

              ffprint(
                  "FFmpeg process started with arguments: '${ffmpegCommand}'.");

              FFmpegKit.executeAsync(ffmpegCommand, (session) async {
                final state = FFmpegKitConfig.sessionStateToString(
                    await session.getState());
                final returnCode = await session.getReturnCode();
                final failStackTrace = await session.getFailStackTrace();

                ffprint(
                    "FFmpeg process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}");

                this.hideProgressDialog();

                if (ReturnCode.isSuccess(returnCode)) {
                  ffprint("Encode completed successfully.");
                } else {
                  showPopup("Encode failed. Please check log for the details.");
                }
              }).then((session) => ffprint(
                  "Async FFmpeg process started with sessionId ${session.getSessionId()}."));
            });
          });
        });
      });
    });
  }

  void showProgressDialog() {
    // CLEAN STATISTICS
    _statistics = null;
    _refreshablePlayerDialogFactory.dialogShow("Encoding video");
  }

  void updateProgressDialog() {
    var statistics = this._statistics;
    if (statistics == null || statistics.getTime() < 0) {
      return;
    }

    double timeInMilliseconds = statistics.getTime();
    int totalVideoDuration = 9000;

    int completePercentage = (timeInMilliseconds * 100) ~/ totalVideoDuration;

    _refreshablePlayerDialogFactory
        .dialogUpdate("Encoding video % $completePercentage");
    _refreshablePlayerDialogFactory.refresh();
  }

  void hideProgressDialog() {
    _refreshablePlayerDialogFactory.dialogHide();
  }

  String getOutputText() => _outputText;
}
