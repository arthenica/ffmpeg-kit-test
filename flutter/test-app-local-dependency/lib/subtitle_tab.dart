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
import 'package:ffmpeg_kit_flutter/session.dart';
import 'package:ffmpeg_kit_flutter/statistics.dart';
import 'package:video_player/video_player.dart';

import 'abstract.dart';
import 'player.dart';
import 'popup.dart';
import 'tooltip.dart';
import 'util.dart';
import 'video_util.dart';

enum _State { IDLE, CREATING, BURNING }

class SubtitleTab implements PlayerTab {
  VideoPlayerController? _videoPlayerController;
  late RefreshablePlayerDialogFactory _refreshablePlayerDialogFactory;
  late Statistics? _statistics;
  late _State _state;
  late int? _sessionId;

  void init(RefreshablePlayerDialogFactory refreshablePlayerDialogFactory) {
    _refreshablePlayerDialogFactory = refreshablePlayerDialogFactory;
    _statistics = null;
    _state = _State.IDLE;
    _sessionId = null;
  }

  void setActive() {
    print("Subtitle Tab Activated");
    FFmpegKitConfig.enableLogCallback(logCallback);
    FFmpegKitConfig.enableStatisticsCallback(statisticsCallback);
    showPopup(SUBTITLE_TEST_TOOLTIP_TEXT);
  }

  void logCallback(Log log) {
    ffprint(log.getMessage());
  }

  void statisticsCallback(Statistics statistics) {
    this._statistics = statistics;
    this.updateProgressDialog();
  }

  void burnSubtitles() {
    VideoUtil.assetPath(VideoUtil.ASSET_1).then((image1Path) {
      VideoUtil.assetPath(VideoUtil.ASSET_2).then((image2Path) {
        VideoUtil.assetPath(VideoUtil.ASSET_3).then((image3Path) {
          VideoUtil.assetPath(VideoUtil.SUBTITLE_ASSET).then((subtitlePath) {
            getVideoFile().then((videoFile) {
              getVideoWithSubtitlesFile().then((videoWithSubtitlesFile) {
                // IF VIDEO IS PLAYING STOP PLAYBACK
                pause();

                deleteFile(videoFile);
                deleteFile(videoWithSubtitlesFile);

                ffprint("Testing SUBTITLE burning");

                this.hideProgressDialog();
                this.showCreateProgressDialog();

                final ffmpegCommand = VideoUtil.generateEncodeVideoScript(
                    image1Path,
                    image2Path,
                    image3Path,
                    videoFile.path,
                    "mpeg4",
                    "");

                _state = _State.CREATING;

                FFmpegKit.executeAsync(ffmpegCommand, (session) async {
                  final state = FFmpegKitConfig.sessionStateToString(
                      await session.getState());
                  final returnCode = await session.getReturnCode();
                  final failStackTrace = await session.getFailStackTrace();

                  ffprint(
                      "FFmpeg process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}");

                  this.hideProgressDialog();

                  if (ReturnCode.isSuccess(returnCode)) {
                    ffprint(
                        "Create completed successfully; burning subtitles.");

                    String burnSubtitlesCommand =
                        "-y -i ${videoFile.path} -vf subtitles=$subtitlePath:force_style='Fontname=Trueno' -c:v mpeg4 ${videoWithSubtitlesFile.path}";

                    this.showBurnProgressDialog();

                    ffprint(
                        "FFmpeg process started with arguments: \'$burnSubtitlesCommand\'.");

                    _state = _State.BURNING;

                    FFmpegKit.executeAsync(burnSubtitlesCommand,
                        (Session secondSession) async {
                      final secondState = FFmpegKitConfig.sessionStateToString(
                          await secondSession.getState());
                      final secondReturnCode =
                          await secondSession.getReturnCode();
                      final secondFailStackTrace =
                          await secondSession.getFailStackTrace();

                      this.hideProgressDialog();

                      if (ReturnCode.isSuccess(secondReturnCode)) {
                        ffprint(
                            "Burn subtitles completed successfully; playing video.");
                        this.playVideo();
                      } else if (ReturnCode.isCancel(secondReturnCode)) {
                        showPopup("Burn subtitles operation cancelled.");
                        ffprint("Burn subtitles operation cancelled");
                      } else {
                        showPopup(
                            "Burn subtitles failed. Please check log for the details.");
                        ffprint(
                            "Burn subtitles failed with state ${secondState} and rc ${secondReturnCode}.${notNull(secondFailStackTrace, "\\n")}");
                      }
                    }).then((session) => _sessionId = session.getSessionId());
                  }
                }).then((session) {
                  _sessionId = session.getSessionId();
                  ffprint(
                      "Async FFmpeg process started with sessionId ${session.getSessionId()}.");
                });
              });
            });
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

  Future<File> getVideoWithSubtitlesFile() async {
    final String video = "video-with-subtitles.mp4";
    Directory documentsDirectory = await VideoUtil.documentsDirectory;
    return new File("${documentsDirectory.path}/$video");
  }

  void showCreateProgressDialog() {
    // CLEAN STATISTICS
    _statistics = null;
    _refreshablePlayerDialogFactory.dialogShowCancellable(
        "Creating video", () => FFmpegKit.cancel(_sessionId));
  }

  void showBurnProgressDialog() {
    // CLEAN STATISTICS
    _statistics = null;
    _refreshablePlayerDialogFactory.dialogShowCancellable(
        "Burning subtitles", () => FFmpegKit.cancel(_sessionId));
  }

  void updateProgressDialog() {
    var statistics = this._statistics;
    if (statistics == null || statistics.getTime() < 0) {
      return;
    }

    double timeInMilliseconds = this._statistics!.getTime();
    int totalVideoDuration = 9000;

    int completePercentage = (timeInMilliseconds * 100) ~/ totalVideoDuration;

    if (_state == _State.CREATING) {
      _refreshablePlayerDialogFactory
          .dialogUpdate("Creating video % $completePercentage");
    } else if (_state == _State.BURNING) {
      _refreshablePlayerDialogFactory
          .dialogUpdate("Burning subtitles % $completePercentage");
    }
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
