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

class AudioTab {
  late RefreshablePlayerDialogFactory _refreshablePlayerDialogFactory;
  late String _selectedCodec;
  String _outputText = "";

  void init(RefreshablePlayerDialogFactory refreshablePlayerDialogFactory) {
    _refreshablePlayerDialogFactory = refreshablePlayerDialogFactory;
    List<DropdownMenuItem<String>> audioCodecList = getAudioCodecList();
    _selectedCodec = audioCodecList[0].value!;
    this.clearOutput();
  }

  void setActive() {
    print("Audio Tab Activated");
    FFmpegKitConfig.enableLogCallback(null);
    FFmpegKitConfig.enableStatisticsCallback(null);
    createAudioSample();
    FFmpegKitConfig.enableLogCallback(this.logCallback);
    showPopup(AUDIO_TEST_TOOLTIP_TEXT);
  }

  void logCallback(Log log) {
    this.appendOutput(log.getMessage());
  }

  void appendOutput(String logMessage) {
    _outputText += logMessage;
    _refreshablePlayerDialogFactory.refresh();
  }

  void clearOutput() {
    _outputText = "";
    _refreshablePlayerDialogFactory.refresh();
  }

  void changedAudioCodec(String? selectedCodec) {
    _selectedCodec = selectedCodec!;
    _refreshablePlayerDialogFactory.refresh();
  }

  void encodeAudio() {
    getAudioOutputFile().then((audioOutputFile) {
      deleteFile(audioOutputFile);

      final String audioCodec = _selectedCodec;

      ffprint("Testing AUDIO encoding with '$audioCodec' codec");

      generateAudioEncodeScript().then((ffmpegCommand) {
        this.hideProgressDialog();
        this.showProgressDialog();

        clearOutput();

        ffprint("FFmpeg process started with arguments: '${ffmpegCommand}'.");

        FFmpegKit.execute(ffmpegCommand).then((session) async {
          final state =
              FFmpegKitConfig.sessionStateToString(await session.getState());
          final returnCode = await session.getReturnCode();
          final failStackTrace = await session.getFailStackTrace();

          hideProgressDialog();

          if (ReturnCode.isSuccess(returnCode)) {
            showPopup("Encode completed successfully.");
            ffprint("Encode completed successfully.");
            listAllLogs(session);
          } else {
            showPopup("Encode failed. Please check log for the details.");
            ffprint(
                "Encode failed with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\n")}");
          }
        });
      });
    });
  }

  void createAudioSample() {
    ffprint("Creating AUDIO sample before the test.");

    getAudioSampleFile().then((audioSampleFile) {
      deleteFile(audioSampleFile);

      String ffmpegCommand =
          "-hide_banner -y -f lavfi -i sine=frequency=1000:duration=5 -c:a pcm_s16le ${audioSampleFile.path}";

      ffprint("Creating audio sample with '$ffmpegCommand'.");

      FFmpegKit.execute(ffmpegCommand).then((session) async {
        final state =
            FFmpegKitConfig.sessionStateToString(await session.getState());
        final returnCode = await session.getReturnCode();
        final failStackTrace = await session.getFailStackTrace();

        if (ReturnCode.isSuccess(returnCode)) {
          ffprint("AUDIO sample created");
        } else {
          ffprint(
              "Creating AUDIO sample failed with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\n")}");
          showPopup(
              "Creating AUDIO sample failed. Please check log for the details.");
        }
      });
    });
  }

  Future<File> getAudioOutputFile() async {
    String audioCodec = _selectedCodec;

    String extension;
    switch (audioCodec) {
      case "mp2 (twolame)":
        extension = "mpg";
        break;
      case "mp3 (liblame)":
      case "mp3 (libshine)":
        extension = "mp3";
        break;
      case "vorbis":
        extension = "ogg";
        break;
      case "opus":
        extension = "opus";
        break;
      case "amr-nb":
        extension = "amr";
        break;
      case "amr-wb":
        extension = "amr";
        break;
      case "ilbc":
        extension = "lbc";
        break;
      case "speex":
        extension = "spx";
        break;
      case "wavpack":
        extension = "wv";
        break;
      default:
        // soxr
        extension = "wav";
        break;
    }

    final String audio = "audio." + extension;
    Directory documentsDirectory = await VideoUtil.documentsDirectory;
    return new File("${documentsDirectory.path}/$audio");
  }

  Future<File> getAudioSampleFile() async {
    Directory documentsDirectory = await VideoUtil.documentsDirectory;
    return new File("${documentsDirectory.path}/audio-sample.wav");
  }

  void showProgressDialog() {
    _refreshablePlayerDialogFactory.dialogShow("Encoding audio");
  }

  void hideProgressDialog() {
    _refreshablePlayerDialogFactory.dialogHide();
  }

  Future<String> generateAudioEncodeScript() async {
    String audioCodec = _selectedCodec;
    String audioSampleFile = (await getAudioSampleFile()).path;
    String audioOutputFile = (await getAudioOutputFile()).path;

    switch (audioCodec) {
      case "mp2 (twolame)":
        return "-hide_banner -y -i $audioSampleFile -c:a mp2 -b:a 192k $audioOutputFile";
      case "mp3 (liblame)":
        return "-hide_banner -y -i $audioSampleFile -c:a libmp3lame -qscale:a 2 $audioOutputFile";
      case "mp3 (libshine)":
        return "-hide_banner -y -i $audioSampleFile -c:a libshine -qscale:a 2 $audioOutputFile";
      case "vorbis":
        return "-hide_banner -y -i $audioSampleFile -c:a libvorbis -b:a 64k $audioOutputFile";
      case "opus":
        return "-hide_banner -y -i $audioSampleFile -c:a libopus -b:a 64k -vbr on -compression_level 10 $audioOutputFile";
      case "amr-nb":
        return "-hide_banner -y -i $audioSampleFile -ar 8000 -ab 12.2k -c:a libopencore_amrnb $audioOutputFile";
      case "amr-wb":
        return "-hide_banner -y -i $audioSampleFile -ar 8000 -ab 12.2k -c:a libvo_amrwbenc -strict experimental $audioOutputFile";
      case "ilbc":
        return "-hide_banner -y -i $audioSampleFile -c:a ilbc -ar 8000 -b:a 15200 $audioOutputFile";
      case "speex":
        return "-hide_banner -y -i $audioSampleFile -c:a libspeex -ar 16000 $audioOutputFile";
      case "wavpack":
        return "-hide_banner -y -i $audioSampleFile -c:a wavpack -b:a 64k $audioOutputFile";
      default:
        // soxr
        return "-hide_banner -y -i $audioSampleFile -af aresample=resampler=soxr -ar 44100 $audioOutputFile";
    }
  }

  List<DropdownMenuItem<String>> getAudioCodecList() {
    List<DropdownMenuItem<String>> list = List.empty(growable: true);

    list.add(new DropdownMenuItem(
        value: "mp2 (twolame)",
        child: SizedBox(
            width: 100, child: Center(child: new Text("mp2 (twolame)")))));
    list.add(new DropdownMenuItem(
        value: "mp3 (liblame)",
        child: SizedBox(
            width: 100, child: Center(child: new Text("mp3 (liblame)")))));
    list.add(new DropdownMenuItem(
        value: "mp3 (libshine)",
        child: SizedBox(
            width: 100, child: Center(child: new Text("mp3 (libshine)")))));
    list.add(new DropdownMenuItem(
        value: "vorbis",
        child: SizedBox(width: 100, child: Center(child: new Text("vorbis")))));
    list.add(new DropdownMenuItem(
        value: "opus",
        child: SizedBox(width: 100, child: Center(child: new Text("opus")))));
    list.add(new DropdownMenuItem(
        value: "amr-nb",
        child: SizedBox(width: 100, child: Center(child: new Text("amr-nb")))));
    list.add(new DropdownMenuItem(
        value: "amr-wb",
        child: SizedBox(width: 100, child: Center(child: new Text("amr-wb")))));
    list.add(new DropdownMenuItem(
        value: "ilbc",
        child: SizedBox(width: 100, child: Center(child: new Text("ilbc")))));
    list.add(new DropdownMenuItem(
        value: "soxr",
        child: SizedBox(width: 100, child: Center(child: new Text("soxr")))));
    list.add(new DropdownMenuItem(
        value: "speex",
        child: SizedBox(width: 100, child: Center(child: new Text("speex")))));
    list.add(new DropdownMenuItem(
        value: "wavpack",
        child:
            SizedBox(width: 100, child: Center(child: new Text("wavpack")))));

    return list;
  }

  String getOutputText() => _outputText;

  String getSelectedCodec() => _selectedCodec;
}
