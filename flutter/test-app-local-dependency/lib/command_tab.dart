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
import 'package:ffmpeg_kit_flutter/ffprobe_session.dart';
import 'package:ffmpeg_kit_flutter/level.dart';
import 'package:ffmpeg_kit_flutter/log.dart';
import 'package:ffmpeg_kit_flutter/log_redirection_strategy.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:ffmpeg_kit_flutter/session_state.dart';
import 'package:flutter/material.dart';

import 'abstract.dart';
import 'popup.dart';
import 'tooltip.dart';
import 'util.dart';

class CommandTab {
  late Refreshable _refreshable;
  late TextEditingController _commandText;
  String _outputText = "";

  void init(Refreshable refreshable) {
    _refreshable = refreshable;
    _commandText = TextEditingController();
    this.clearOutput();

    // COMMAND TAB IS SELECTED BY DEFAULT
    this.setActive();
  }

  void setActive() {
    print("Command Tab Activated");
    FFmpegKitConfig.enableLogCallback(null);
    FFmpegKitConfig.enableStatisticsCallback(null);
    showPopup(COMMAND_TEST_TOOLTIP_TEXT);
  }

  void appendOutput(String? logMessage) {
    if (logMessage != null) {
      _outputText += logMessage;
    }
    _refreshable.refresh();
  }

  void logCallback(Log log) {
    appendOutput(log.getMessage());
  }

  void clearOutput() {
    _outputText = "";
    _refreshable.refresh();
  }

  void runFFmpeg() {
    this.clearOutput();

    final String ffmpegCommand = _commandText.text;

    ffprint(
        "Current log level is ${Level.levelToString(FFmpegKitConfig.getLogLevel())}.");

    ffprint("Testing FFmpeg COMMAND asynchronously.");

    ffprint("FFmpeg process started with arguments: \'$ffmpegCommand\'");

    FFmpegKit.execute(ffmpegCommand).then((session) async {
      final state =
          FFmpegKitConfig.sessionStateToString(await session.getState());
      final returnCode = await session.getReturnCode();
      final failStackTrace = await session.getFailStackTrace();
      final output = await session.getOutput();

      ffprint(
          "FFmpeg process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}");

      appendOutput(output);

      if (state == SessionState.failed || !ReturnCode.isSuccess(returnCode)) {
        showPopup("Command failed. Please check output for the details.");
      }
    });
  }

  void runFFprobe() {
    this.clearOutput();

    final String ffprobeCommand = _commandText.text;

    ffprint("Testing FFprobe COMMAND asynchronously.");

    ffprint("FFprobe process started with arguments: \'$ffprobeCommand\'");

    FFprobeSession.create(FFmpegKitConfig.parseArguments(ffprobeCommand),
            (session) async {
      final state =
          FFmpegKitConfig.sessionStateToString(await session.getState());
      final returnCode = await session.getReturnCode();
      final failStackTrace = await session.getFailStackTrace();
      session.getOutput().then((output) => this.appendOutput(output ?? ""));

      ffprint(
          "FFprobe process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}");

      if (state == SessionState.failed || !ReturnCode.isSuccess(returnCode)) {
        showPopup("Command failed. Please check output for the details.");
      }
    }, null, LogRedirectionStrategy.neverPrintLogs)
        .then((session) {
      FFmpegKitConfig.asyncFFprobeExecute(session);
      listFFprobeSessions();
    });
  }

  String getOutputText() => _outputText;

  TextEditingController getCommandText() => _commandText;

  void dispose() {
    _commandText.dispose();
  }
}
