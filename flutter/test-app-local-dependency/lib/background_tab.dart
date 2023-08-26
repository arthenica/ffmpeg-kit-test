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
import 'package:ffmpeg_kit_flutter/log.dart';
import 'package:flutter_isolate/flutter_isolate.dart';

import 'abstract.dart';
import 'popup.dart';
import 'tooltip.dart';

class BackgroundTab {
  late RefreshablePlayerDialogFactory _refreshablePlayerDialogFactory;

  String _outputText = "";

  void init(RefreshablePlayerDialogFactory refreshablePlayerDialogFactory) {
    _refreshablePlayerDialogFactory = refreshablePlayerDialogFactory;
    this.clearOutput();
  }

  void setActive() {
    print("Background Tab Activated");
    FFmpegKitConfig.enableLogCallback(this.logCallback);
    showPopup(BACKGROUND_TEST_TOOLTIP_TEXT);
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

  void runInService() {
    flutterCompute(runCommand, "-version").then((output) {
      if (output != null) {
        appendOutput(output);
      }
    });
  }

  String getOutputText() => _outputText;
}

@pragma('vm:entry-point')
Future<String?> runCommand(String command) async {
  final session = await FFmpegKit.execute(command);
  return await session.getOutput();
}
