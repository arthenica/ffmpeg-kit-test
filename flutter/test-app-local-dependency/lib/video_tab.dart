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

import 'dart:async';
import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:ffmpeg_kit_flutter/statistics.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'abstract.dart';
import 'player.dart';
import 'popup.dart';
import 'tooltip.dart';
import 'util.dart';
import 'video_util.dart';

class VideoTab implements PlayerTab {
  VideoPlayerController? _videoPlayerController;
  late RefreshablePlayerDialogFactory _refreshablePlayerDialogFactory;
  late String _selectedCodec;
  late Statistics? _statistics;

  void init(RefreshablePlayerDialogFactory refreshablePlayerDialogFactory) {
    _refreshablePlayerDialogFactory = refreshablePlayerDialogFactory;
    List<DropdownMenuItem<String>> videoCodecList = getVideoCodecList();
    _selectedCodec = videoCodecList[0].value!;
    _statistics = null;
  }

  void setActive() {
    print("Video Tab Activated");
    FFmpegKitConfig.enableLogCallback(null);
    FFmpegKitConfig.enableStatisticsCallback(null);
    showPopup(VIDEO_TEST_TOOLTIP_TEXT);
  }

  void changedVideoCodec(String? selectedCodec) {
    _selectedCodec = selectedCodec!;
    _refreshablePlayerDialogFactory.refresh();
  }

  void encodeVideo() {
    VideoUtil.assetPath(VideoUtil.ASSET_1).then((image1Path) {
      VideoUtil.assetPath(VideoUtil.ASSET_2).then((image2Path) {
        VideoUtil.assetPath(VideoUtil.ASSET_3).then((image3Path) {
          getVideoFile().then((videoFile) {
            // IF VIDEO IS PLAYING STOP PLAYBACK
            this.pause();

            deleteFile(videoFile);

            final String videoCodec = getSelectedVideoCodec();

            ffprint("Testing VIDEO encoding with '$videoCodec' codec");

            this.hideProgressDialog();
            this.showProgressDialog();

            final ffmpegCommand =
                VideoUtil.generateEncodeVideoScriptWithCustomPixelFormat(
                    image1Path,
                    image2Path,
                    image3Path,
                    videoFile.path,
                    videoCodec,
                    this.getPixelFormat(),
                    this.getCustomOptions());

            ffprint(
                "FFmpeg process started with arguments: \'${ffmpegCommand}\'.");

            FFmpegKit.executeAsync(
                    ffmpegCommand,
                    (session) async {
                      final state = FFmpegKitConfig.sessionStateToString(
                          await session.getState());
                      final returnCode = await session.getReturnCode();
                      final failStackTrace = await session.getFailStackTrace();
                      final duration = await session.getDuration();

                      this.hideProgressDialog();

                      if (ReturnCode.isSuccess(returnCode)) {
                        ffprint(
                            "Encode completed successfully in ${duration} milliseconds; playing video.");
                        this.playVideo();
                      } else {
                        showPopup(
                            "Encode failed. Please check log for the details.");
                        ffprint(
                            "Encode failed with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}");
                      }
                    },
                    (log) => ffprint(log.getMessage()),
                    (statistics) {
                      this._statistics = statistics;
                      this.updateProgressDialog();
                    })
                .then((session) => ffprint(
                    "Async FFmpeg process started with sessionId ${session.getSessionId()}."));
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

  getPixelFormat() {
    String videoCodec = _selectedCodec;

    String pixelFormat;
    if (videoCodec == "x265") {
      pixelFormat = "yuv420p10le";
    } else {
      pixelFormat = "yuv420p";
    }

    return pixelFormat;
  }

  String getSelectedVideoCodec() {
    String videoCodec = _selectedCodec;

    // VIDEO CODEC MENU HAS BASIC NAMES, FFMPEG NEEDS LONGER LIBRARY NAMES.
    // APPLYING NECESSARY TRANSFORMATION HERE
    switch (videoCodec) {
      case "x264":
        videoCodec = "libx264";
        break;
      case "h264_mediacodec":
        videoCodec = "h264_mediacodec";
        break;
      case "hevc_mediacodec":
        videoCodec = "hevc_mediacodec";
        break;
      case "openh264":
        videoCodec = "libopenh264";
        break;
      case "x265":
        videoCodec = "libx265";
        break;
      case "xvid":
        videoCodec = "libxvid";
        break;
      case "vp8":
        videoCodec = "libvpx";
        break;
      case "vp9":
        videoCodec = "libvpx-vp9";
        break;
      case "aom":
        videoCodec = "libaom-av1";
        break;
      case "kvazaar":
        videoCodec = "libkvazaar";
        break;
      case "theora":
        videoCodec = "libtheora";
        break;
    }

    return videoCodec;
  }

  Future<File> getVideoFile() async {
    String videoCodec = _selectedCodec;

    String extension;
    switch (videoCodec) {
      case "vp8":
      case "vp9":
        extension = "webm";
        break;
      case "aom":
        extension = "mkv";
        break;
      case "theora":
        extension = "ogv";
        break;
      case "hap":
        extension = "mov";
        break;
      default:
        // mpeg4, x264, h264_mediacodec, hevc_mediacodec, x265, xvid, kvazaar
        extension = "mp4";
        break;
    }

    final String video = "video." + extension;
    Directory documentsDirectory = await VideoUtil.documentsDirectory;
    return new File("${documentsDirectory.path}/$video");
  }

  String getCustomOptions() {
    String videoCodec = _selectedCodec;

    switch (videoCodec) {
      case "x265":
        return "-crf 28 -preset fast ";
      case "vp8":
        return "-b:v 1M -crf 10 ";
      case "vp9":
        return "-b:v 2M ";
      case "aom":
        return "-crf 30 -strict experimental ";
      case "theora":
        return "-qscale:v 7 ";
      case "hap":
        return "-format hap_q ";
      default:
        // kvazaar, mpeg4, x264, h264_mediacodec, hevc_mediacodec, xvid
        return "";
    }
  }

  List<DropdownMenuItem<String>> getVideoCodecList() {
    List<DropdownMenuItem<String>> list = List.empty(growable: true);

    list.add(new DropdownMenuItem(
        value: "mpeg4",
        child: SizedBox(width: 130, child: Center(child: new Text("mpeg4")))));
    list.add(new DropdownMenuItem(
        value: "x264",
        child: SizedBox(width: 130, child: Center(child: new Text("x264")))));
    list.add(new DropdownMenuItem(
        value: "h264_mediacodec",
        child: SizedBox(width: 130, child: Center(child: new Text("h264_mediacodec")))));
    list.add(new DropdownMenuItem(
        value: "hevc_mediacodec",
        child: SizedBox(width: 130, child: Center(child: new Text("hevc_mediacodec")))));
    list.add(new DropdownMenuItem(
        value: "openh264",
        child:
            SizedBox(width: 130, child: Center(child: new Text("openh264")))));
    list.add(new DropdownMenuItem(
        value: "x265",
        child: SizedBox(width: 130, child: Center(child: new Text("x265")))));
    list.add(new DropdownMenuItem(
        value: "xvid",
        child: SizedBox(width: 130, child: Center(child: new Text("xvid")))));
    list.add(new DropdownMenuItem(
        value: "vp8",
        child: SizedBox(width: 130, child: Center(child: new Text("vp8")))));
    list.add(new DropdownMenuItem(
        value: "vp9",
        child: SizedBox(width: 130, child: Center(child: new Text("vp9")))));
    list.add(new DropdownMenuItem(
        value: "aom",
        child: SizedBox(width: 130, child: Center(child: new Text("aom")))));
    list.add(new DropdownMenuItem(
        value: "kvazaar",
        child:
            SizedBox(width: 130, child: Center(child: new Text("kvazaar")))));
    list.add(new DropdownMenuItem(
        value: "theora",
        child: SizedBox(width: 130, child: Center(child: new Text("theora")))));
    list.add(new DropdownMenuItem(
        value: "hap",
        child: SizedBox(width: 130, child: Center(child: new Text("hap")))));

    return list;
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

  String getSelectedCodec() => _selectedCodec;

  @override
  void setController(VideoPlayerController controller) {
    _videoPlayerController = controller;
  }
}
