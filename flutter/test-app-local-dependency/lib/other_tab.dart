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
import 'package:ffmpeg_kit_flutter/log.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';

import 'abstract.dart';
import 'popup.dart';
import 'tooltip.dart';
import 'util.dart';
import 'video_util.dart';

class OtherTab {
  static const String DAV1D_TEST_DEFAULT_URL =
      "http://download.opencontent.netflix.com.s3.amazonaws.com/AV1/Sparks/Sparks-5994fps-AV1-10bit-960x540-film-grain-synthesis-854kbps.obu";

  late Refreshable _refreshable;
  late String _selectedTest;
  String _outputText = "";

  void init(Refreshable refreshable) {
    _refreshable = refreshable;
    List<DropdownMenuItem<String>> testList = getTestList();
    _selectedTest = testList[0].value!;
    this.clearOutput();
  }

  void changedTest(String? selectedTest) {
    _selectedTest = selectedTest!;
    _refreshable.refresh();
  }

  void setActive() {
    print("Other Tab Activated");
    FFmpegKitConfig.enableLogCallback(null);
    FFmpegKitConfig.enableStatisticsCallback(null);
    showPopup(OTHER_TEST_TOOLTIP_TEXT);
  }

  void logCallback(Log log) {
    this.appendOutput(log.getMessage());
  }

  void appendOutput(String logMessage) {
    _outputText += logMessage;
    _refreshable.refresh();
  }

  void clearOutput() {
    _outputText = "";
    _refreshable.refresh();
  }

  void runTest() {
    this.clearOutput();

    switch (this._selectedTest) {
      case "chromaprint":
        this.testChromaprint();
        break;
      case "dav1d":
        this.testDav1d();
        break;
      case "webp":
        this.testWebp();
        break;
      case "zscale":
        this.testZscale();
        break;
    }
  }

  testChromaprint() {
    ffprint("Testing 'chromaprint' mutex");

    this.getChromaprintSampleFile().then((audioSampleFile) {
      this.getChromaprintOutputFile().then((outputFile) {
        deleteFile(audioSampleFile);
        deleteFile(outputFile);

        final ffmpegCommand =
            "-hide_banner -y -f lavfi -i sine=frequency=1000:duration=5 -c:a pcm_s16le ${audioSampleFile.path}";

        ffprint("Creating audio sample with '${ffmpegCommand}'.");

        FFmpegKit.executeAsync(ffmpegCommand, (session) async {
          final state =
              FFmpegKitConfig.sessionStateToString(await session.getState());
          final returnCode = await session.getReturnCode();
          final failStackTrace = await session.getFailStackTrace();

          ffprint(
              "FFmpeg process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}");

          if (ReturnCode.isSuccess(returnCode)) {
            ffprint("AUDIO sample created");

            final chromaprintCommand =
                "-hide_banner -y -i ${audioSampleFile.path} -f chromaprint -fp_format 2 ${outputFile.path}";

            ffprint("Creating audio sample with '${chromaprintCommand}'.");

            FFmpegKit.executeAsync(chromaprintCommand, (secondSession) async {
              final secondState = FFmpegKitConfig.sessionStateToString(
                  await secondSession.getState());
              final secondReturnCode = await secondSession.getReturnCode();
              final secondFailStackTrace =
                  await secondSession.getFailStackTrace();

              ffprint(
                  "FFmpeg process exited with state ${secondState} and rc ${secondReturnCode}.${notNull(secondFailStackTrace, "\\n")}");

              if (ReturnCode.isSuccess(secondReturnCode)) {
                showPopup("Testing chromaprint completed successfully.");
              } else {
                showPopup(
                    "Testing chromaprint failed. Please check logs for the details.");
              }
            }, (log) => this.appendOutput(log.getMessage()));
          } else {
            showPopup(
                "Creating AUDIO sample failed. Please check logs for the details.");
          }
        });
      });
    });
  }

  testDav1d() {
    ffprint("Testing decoding 'av1' codec");

    this.getDav1dOutputFile().then((outputFile) {
      final ffmpegCommand =
          "-hide_banner -y -i ${DAV1D_TEST_DEFAULT_URL} ${outputFile.path}";

      ffprint("FFmpeg process started with arguments:'${ffmpegCommand}'.");

      FFmpegKit.executeAsync(ffmpegCommand, (session) async {
        final state =
            FFmpegKitConfig.sessionStateToString(await session.getState());
        final returnCode = await session.getReturnCode();
        final failStackTrace = await session.getFailStackTrace();

        ffprint(
            "FFmpeg process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}");
      }, (log) => this.appendOutput(log.getMessage()));
    });
  }

  testWebp() {
    VideoUtil.assetPath(VideoUtil.ASSET_1).then((imagePath) {
      this.getWebpOutputFile().then((outputPath) {
        ffprint("Testing 'webp' codec");

        final ffmpegCommand =
            "-hide_banner -y -i ${imagePath} ${outputPath.path}";

        ffprint("FFmpeg process started with arguments '${ffmpegCommand}'.");

        FFmpegKit.executeAsync(ffmpegCommand, (session) async {
          final state =
              FFmpegKitConfig.sessionStateToString(await session.getState());
          final returnCode = await session.getReturnCode();
          final failStackTrace = await session.getFailStackTrace();

          ffprint(
              "FFmpeg process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}");

          if (ReturnCode.isSuccess(returnCode)) {
            showPopup("Encode webp completed successfully.");
          } else {
            showPopup("Encode webp failed. Please check logs for the details.");
          }
        }, (log) => this.appendOutput(log.getMessage()));
      });
    });
  }

  testZscale() {
    getVideoFile().then((videoFile) {
      getZscaledVideoFile().then((zscaledVideoFile) {
        this.getWebpOutputFile().then((outputPath) {
          ffprint(
              "Testing 'zscale' filter with video file created on the Video tab");

          final ffmpegCommand = VideoUtil.generateZscaleVideoScript(
              videoFile.path, zscaledVideoFile.path);

          ffprint("FFmpeg process started with arguments '${ffmpegCommand}'.");

          FFmpegKit.executeAsync(ffmpegCommand, (session) async {
            final state =
                FFmpegKitConfig.sessionStateToString(await session.getState());
            final returnCode = await session.getReturnCode();
            final failStackTrace = await session.getFailStackTrace();

            ffprint(
                "FFmpeg process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}");

            if (ReturnCode.isSuccess(returnCode)) {
              showPopup("zscale completed successfully.");
            } else {
              showPopup("zscale failed. Please check logs for the details.");
            }
          }, (log) => this.appendOutput(log.getMessage()));
        });
      });
    });
  }

  Future<File> getChromaprintSampleFile() async {
    Directory documentsDirectory = await VideoUtil.documentsDirectory;
    return new File("${documentsDirectory.path}/audio-sample.wav");
  }

  Future<File> getDav1dOutputFile() async {
    Directory documentsDirectory = await VideoUtil.documentsDirectory;
    return new File("${documentsDirectory.path}/video.mp4");
  }

  Future<File> getChromaprintOutputFile() async {
    Directory documentsDirectory = await VideoUtil.documentsDirectory;
    return new File("${documentsDirectory.path}/chromaprint.txt");
  }

  Future<File> getWebpOutputFile() async {
    Directory documentsDirectory = await VideoUtil.documentsDirectory;
    return new File("${documentsDirectory.path}/video.webp");
  }

  Future<File> getVideoFile() async {
    Directory documentsDirectory = await VideoUtil.documentsDirectory;
    return new File("${documentsDirectory.path}/video.mp4");
  }

  Future<File> getZscaledVideoFile() async {
    Directory documentsDirectory = await VideoUtil.documentsDirectory;
    return new File("${documentsDirectory.path}/video.zscaled.mp4");
  }

  List<DropdownMenuItem<String>> getTestList() {
    List<DropdownMenuItem<String>> list = List.empty(growable: true);

    list.add(new DropdownMenuItem(
        value: "chromaprint",
        child: SizedBox(
            width: 100, child: Center(child: new Text("chromaprint")))));
    list.add(new DropdownMenuItem(
        value: "dav1d",
        child: SizedBox(width: 100, child: Center(child: new Text("dav1d")))));
    list.add(new DropdownMenuItem(
        value: "webp",
        child: SizedBox(width: 100, child: Center(child: new Text("webp")))));
    list.add(new DropdownMenuItem(
        value: "zscale",
        child: SizedBox(width: 100, child: Center(child: new Text("zscale")))));

    return list;
  }

  String getOutputText() => _outputText;

  String getSelectedCodec() => _selectedTest;
}
