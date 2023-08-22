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
import 'package:video_player/video_player.dart';

import 'abstract.dart';
import 'player.dart';
import 'popup.dart';
import 'tooltip.dart';
import 'util.dart';
import 'video_util.dart';

class _ControllerWrapper implements PlayerTab {
  late VideoPlayerController? _controller;

  @override
  void setController(VideoPlayerController controller) {
    _controller = controller;
  }
}

class VidStabTab {
  late _ControllerWrapper videoController;
  late _ControllerWrapper stabilizedVideoController;
  late RefreshablePlayerDialogFactory _refreshablePlayerDialogFactory;

  void init(RefreshablePlayerDialogFactory refreshablePlayerDialogFactory) {
    _refreshablePlayerDialogFactory = refreshablePlayerDialogFactory;
    videoController = _ControllerWrapper();
    stabilizedVideoController = _ControllerWrapper();
  }

  void setActive() {
    print("VidStab Tab Activated");
    FFmpegKitConfig.enableLogCallback(logCallback);
    FFmpegKitConfig.enableStatisticsCallback(null);
    showPopup(VIDSTAB_TEST_TOOLTIP_TEXT);
  }

  void logCallback(Log log) {
    ffprint(log.getMessage());
  }

  void stabilizeVideo() {
    VideoUtil.assetPath(VideoUtil.ASSET_1).then((image1Path) {
      VideoUtil.assetPath(VideoUtil.ASSET_2).then((image2Path) {
        VideoUtil.assetPath(VideoUtil.ASSET_3).then((image3Path) {
          getShakeResultsFile().then((shakeResultsFile) {
            getVideoFile().then((videoFile) {
              getStabilizedVideoFile().then((stabilizedVideoFile) {
                // IF VIDEO IS PLAYING STOP PLAYBACK
                pauseVideo();
                pauseStabilizedVideo();

                deleteFile(shakeResultsFile);
                deleteFile(videoFile);
                deleteFile(stabilizedVideoFile);

                ffprint("Testing VID.STAB");

                this.hideProgressDialog();
                this.showCreateProgressDialog();

                final ffmpegCommand = VideoUtil.generateShakingVideoScript(
                    image1Path, image2Path, image3Path, videoFile.path);

                ffprint(
                    "FFmpeg process started with arguments: \'${ffmpegCommand}\'.");

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
                        "Create completed successfully; stabilizing video.");

                    final analyzeVideoCommand =
                        "-y -i ${videoFile.path} -vf vidstabdetect=shakiness=10:accuracy=15:result=${shakeResultsFile.path} -f null -";

                    this.showStabilizeProgressDialog();

                    ffprint(
                        "FFmpeg process started with arguments: \'${analyzeVideoCommand}\'.");

                    FFmpegKit.executeAsync(analyzeVideoCommand,
                        (Session secondSession) async {
                      final secondState = FFmpegKitConfig.sessionStateToString(
                          await secondSession.getState());
                      final secondReturnCode =
                          await secondSession.getReturnCode();
                      final secondFailStackTrace =
                          await secondSession.getFailStackTrace();

                      ffprint(
                          "FFmpeg process exited with state ${secondState} and rc ${secondReturnCode}.${notNull(secondFailStackTrace, "\\n")}");

                      if (ReturnCode.isSuccess(secondReturnCode)) {
                        final stabilizeVideoCommand =
                            "-y -i ${videoFile.path} -vf vidstabtransform=smoothing=30:input=${shakeResultsFile.path} -c:v mpeg4 ${stabilizedVideoFile.path}";

                        ffprint(
                            "FFmpeg process started with arguments: \'${stabilizeVideoCommand}\'.");

                        FFmpegKit.executeAsync(stabilizeVideoCommand,
                            (thirdSession) async {
                          final thirdState =
                              FFmpegKitConfig.sessionStateToString(
                                  await thirdSession.getState());
                          final thirdReturnCode =
                              await thirdSession.getReturnCode();
                          final thirdFailStackTrace =
                              await thirdSession.getFailStackTrace();

                          ffprint(
                              "FFmpeg process exited with state ${thirdState} and rc ${thirdReturnCode}.${notNull(thirdFailStackTrace, "\\n")}");

                          this.hideProgressDialog();

                          if (ReturnCode.isSuccess(thirdReturnCode)) {
                            ffprint(
                                "Stabilize video completed successfully; playing videos.");
                            this.playVideo();
                            this.playStabilizedVideo();
                          } else {
                            showPopup(
                                "Stabilize video failed. Please check log for the details.");
                          }
                        });
                      } else {
                        this.hideProgressDialog();
                        showPopup(
                            "Stabilize video failed. Please check log for the details.");
                      }
                    });
                  } else {
                    showPopup(
                        "Create video failed. Please check log for the details.");
                  }
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
      if (videoController._controller != null) {
        await videoController._controller!.initialize();
        await videoController._controller!.play();
      }
      _refreshablePlayerDialogFactory.refresh();
    }
  }

  Future<void> pauseVideo() async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (videoController._controller != null) {
        await videoController._controller!.pause();
      }
      _refreshablePlayerDialogFactory.refresh();
    }
  }

  Future<void> playStabilizedVideo() async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (stabilizedVideoController._controller != null) {
        await stabilizedVideoController._controller!.initialize();
        await stabilizedVideoController._controller!.play();
      }
      _refreshablePlayerDialogFactory.refresh();
    }
  }

  Future<void> pauseStabilizedVideo() async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (stabilizedVideoController._controller != null) {
        await stabilizedVideoController._controller!.pause();
      }
      _refreshablePlayerDialogFactory.refresh();
    }
  }

  Future<File> getShakeResultsFile() async {
    final String subtitle = "transforms.trf";
    Directory documentsDirectory = await VideoUtil.tempDirectory;
    return new File("${documentsDirectory.path}/$subtitle");
  }

  Future<File> getVideoFile() async {
    final String video = "video-shaking.mp4";
    Directory documentsDirectory = await VideoUtil.documentsDirectory;
    return new File("${documentsDirectory.path}/$video");
  }

  Future<File> getStabilizedVideoFile() async {
    final String video = "video-stabilized.mp4";
    Directory documentsDirectory = await VideoUtil.documentsDirectory;
    return new File("${documentsDirectory.path}/$video");
  }

  void showCreateProgressDialog() {
    _refreshablePlayerDialogFactory.dialogShow("Creating video");
  }

  void showStabilizeProgressDialog() {
    _refreshablePlayerDialogFactory.dialogShow("Stabilizing video");
  }

  void hideProgressDialog() {
    _refreshablePlayerDialogFactory.dialogHide();
  }
}
