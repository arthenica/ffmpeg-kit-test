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
import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter/log.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:ffmpeg_kit_flutter/session.dart';
import 'package:ffmpeg_kit_flutter/statistics.dart';
import 'package:video_player/video_player.dart';

import 'abstract.dart';
import 'player.dart';
import 'popup.dart';
import 'tooltip.dart';
import 'util.dart';
import 'video_util.dart';

class PipeTab implements PlayerTab {
  VideoPlayerController? _videoPlayerController;
  late RefreshablePlayerDialogFactory _refreshablePlayerDialogFactory;
  Statistics? _statistics;

  void init(RefreshablePlayerDialogFactory refreshablePlayerDialogFactory) {
    _refreshablePlayerDialogFactory = refreshablePlayerDialogFactory;
    _statistics = null;
  }

  void setActive() {
    print("Pipe Tab Activated");
    FFmpegKitConfig.enableLogCallback(logCallback);
    FFmpegKitConfig.enableStatisticsCallback(statisticsCallback);
    showPopup(PIPE_TEST_TOOLTIP_TEXT);
  }

  void logCallback(Log log) {
    ffprint(log.getMessage());
  }

  void statisticsCallback(Statistics statistics) {
    this._statistics = statistics;
    this.updateProgressDialog();
  }

  void createVideo() {
    getVideoFile().then((videoFile) {
      FFmpegKitConfig.registerNewFFmpegPipe().then((pipe1) {
        FFmpegKitConfig.registerNewFFmpegPipe().then((pipe2) {
          FFmpegKitConfig.registerNewFFmpegPipe().then((pipe3) {
            // IF VIDEO IS PLAYING STOP PLAYBACK
            this.pause();

            deleteFile(videoFile);

            ffprint("Testing PIPE with 'mpeg4' codec");

            this.hideProgressDialog();
            this.showProgressDialog();

            final ffmpegCommand = VideoUtil.generateCreateVideoWithPipesScript(
                pipe1!, pipe2!, pipe3!, videoFile.path);

            ffprint(
                "FFmpeg process started with arguments: \'${ffmpegCommand}\'.");

            FFmpegKit.executeAsync(ffmpegCommand,
                (FFmpegSession session) async {
              final state = FFmpegKitConfig.sessionStateToString(
                  await session.getState());
              final returnCode = await session.getReturnCode();
              final failStackTrace = await session.getFailStackTrace();

              ffprint(
                  "FFmpeg process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}");

              this.hideProgressDialog();

              // CLOSE PIPES
              FFmpegKitConfig.closeFFmpegPipe(pipe1);
              FFmpegKitConfig.closeFFmpegPipe(pipe2);
              FFmpegKitConfig.closeFFmpegPipe(pipe3);

              if (ReturnCode.isSuccess(returnCode)) {
                ffprint("Create completed successfully; playing video.");
                this.playVideo();
                listAllStatistics(session as FFmpegSession);
              } else {
                showPopup("Create failed. Please check log for the details.");
              }
            });

            VideoUtil.assetPath(VideoUtil.ASSET_1)
                .then((path) => FFmpegKitConfig.writeToPipe(path, pipe1));
            VideoUtil.assetPath(VideoUtil.ASSET_2)
                .then((path) => FFmpegKitConfig.writeToPipe(path, pipe2));
            VideoUtil.assetPath(VideoUtil.ASSET_3)
                .then((path) => FFmpegKitConfig.writeToPipe(path, pipe3));
          });
        });
      });
    });
  }

  Future<void> playVideo() async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (_videoPlayerController != null) {
        await _videoPlayerController!.initialize();
        await _videoPlayerController!.play();
      }
      _refreshablePlayerDialogFactory.refresh();
    }
  }

  Future<void> pause() async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (_videoPlayerController != null) {
        await _videoPlayerController!.pause();
      }
      _refreshablePlayerDialogFactory.refresh();
    }
  }

  Future<File> getVideoFile() async {
    final String video = "video.mp4";
    Directory documentsDirectory = await VideoUtil.documentsDirectory;
    return new File("${documentsDirectory.path}/$video");
  }

  void showProgressDialog() {
    // CLEAN STATISTICS
    _statistics = null;
    _refreshablePlayerDialogFactory.dialogShow("Creating video");
  }

  void updateProgressDialog() {
    var statistics = this._statistics;
    if (statistics == null || statistics.getTime() < 0) {
      return;
    }

    int timeInMilliseconds = this._statistics!.getTime();
    int totalVideoDuration = 9000;

    int completePercentage = (timeInMilliseconds * 100) ~/ totalVideoDuration;

    _refreshablePlayerDialogFactory
        .dialogUpdate("Creating video % $completePercentage");
    _refreshablePlayerDialogFactory.refresh();
  }

  void hideProgressDialog() {
    _refreshablePlayerDialogFactory.dialogHide();
  }

  @override
  void setController(VideoPlayerController controller) {
    _videoPlayerController = controller;
  }
}
