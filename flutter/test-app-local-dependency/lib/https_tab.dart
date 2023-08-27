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

import 'dart:math';

import 'package:ffmpeg_kit_flutter/chapter.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/media_information_session.dart';
import 'package:ffmpeg_kit_flutter/stream_information.dart';
import 'package:flutter/material.dart';

import 'abstract.dart';
import 'popup.dart';
import 'tooltip.dart';
import 'util.dart';

class HttpsTab {
  static const String HTTPS_TEST_DEFAULT_URL =
      "https://download.blender.org/peach/trailer/trailer_1080p.ogg";

  static const String HTTPS_TEST_FAIL_URL =
      "https://download2.blender.org/peach/trailer/trailer_1080p.ogg";

  static const String HTTPS_TEST_RANDOM_URL_1 =
      "https://filesamples.com/samples/video/mov/sample_640x360.mov";

  static const String HTTPS_TEST_RANDOM_URL_2 =
      "https://filesamples.com/samples/audio/mp3/sample3.mp3";

  static const String HTTPS_TEST_RANDOM_URL_3 =
      "https://filesamples.com/samples/image/webp/sample1.webp";

  static final Random testUrlRandom = new Random();

  late Refreshable _refreshable;
  late TextEditingController _urlText;
  String _outputText = "";

  void init(Refreshable refreshable) {
    _refreshable = refreshable;
    _urlText = TextEditingController();
    this.clearOutput();
  }

  void setActive() {
    print("Https Tab Activated");
    FFmpegKitConfig.enableLogCallback(null);
    FFmpegKitConfig.enableStatisticsCallback(null);
    showPopup(HTTPS_TEST_TOOLTIP_TEXT);
  }

  void appendOutput(String logMessage) {
    _outputText += logMessage;
    _refreshable.refresh();
  }

  void clearOutput() {
    _outputText = "";
    _refreshable.refresh();
  }

  String getRandomTestUrl() {
    switch (testUrlRandom.nextInt(3)) {
      case 0:
        return HTTPS_TEST_RANDOM_URL_1;
      case 1:
        return HTTPS_TEST_RANDOM_URL_2;
      default:
        return HTTPS_TEST_RANDOM_URL_3;
    }
  }

  void runGetMediaInformation(int buttonNumber) {
    // SELECT TEST URL
    String testUrl = "";
    switch (buttonNumber) {
      case 1:
        {
          testUrl = _urlText.text;
          if (testUrl.trim().length <= 0) {
            testUrl = HTTPS_TEST_DEFAULT_URL;
            _urlText.text = testUrl;
          }
          break;
        }
      case 2:
      case 3:
        {
          testUrl = this.getRandomTestUrl();
          break;
        }
      case 4:
      default:
        {
          testUrl = HTTPS_TEST_FAIL_URL;
          _urlText.text = testUrl;
        }
    }

    ffprint(
        "Testing HTTPS with for button ${buttonNumber} using url ${testUrl}.");

    if (buttonNumber == 4) {
      // ONLY THIS BUTTON CLEARS THE TEXT VIEW
      this.clearOutput();
    }

    // EXECUTE
    FFprobeKit.getMediaInformation(testUrl)
        .then((MediaInformationSession session) async {
      var information = await session.getMediaInformation();

      if (information == null) {
        final state =
            FFmpegKitConfig.sessionStateToString(await session.getState());
        final returnCode = await session.getReturnCode();
        final failStackTrace = await session.getFailStackTrace();
        final duration = await session.getDuration();
        final output = await session.getOutput();

        this.appendOutput("Get media information failed\n");
        this.appendOutput("State: ${state}\n");
        this.appendOutput("Duration: ${duration}\n");
        this.appendOutput("Return Code: ${returnCode}\n");
        this.appendOutput(
            "Fail stack trace: ${notNull(failStackTrace, "\\n")}\n");
        this.appendOutput("Output: ${output}\n");
      } else {
        this.appendOutput(
            "Media information for ${information.getFilename()}\n");

        if (information.getFormat() != null) {
          this.appendOutput("Format: ${information.getFormat()}\n");
        }
        if (information.getBitrate() != null) {
          this.appendOutput("Bitrate: ${information.getBitrate()}\n");
        }
        if (information.getDuration() != null) {
          this.appendOutput("Duration: ${information.getDuration()}\n");
        }
        if (information.getStartTime() != null) {
          this.appendOutput("Start time: ${information.getStartTime()}\n");
        }
        if (information.getTags() != null) {
          final tags = information.getTags();
          if (tags != null) {
            tags.forEach((key, value) {
              this.appendOutput("Tag: ${key}:${tags[key]}\n");
            });
          }
        }

        List<StreamInformation> streams = information.getStreams();
        for (var i = 0; i < streams.length; ++i) {
          StreamInformation stream = streams[i];
          if (stream.getIndex() != null) {
            this.appendOutput("Stream index: ${stream.getIndex()}\n");
          }
          if (stream.getType() != null) {
            this.appendOutput("Stream type: ${stream.getType()}\n");
          }
          if (stream.getCodec() != null) {
            this.appendOutput("Stream codec: ${stream.getCodec()}\n");
          }
          if (stream.getCodecLong() != null) {
            this.appendOutput("Stream codec long: ${stream.getCodecLong()}\n");
          }
          if (stream.getFormat() != null) {
            this.appendOutput("Stream format: ${stream.getFormat()}\n");
          }
          if (stream.getWidth() != null) {
            this.appendOutput("Stream width: ${stream.getWidth()}\n");
          }
          if (stream.getHeight() != null) {
            this.appendOutput("Stream height: ${stream.getHeight()}\n");
          }
          if (stream.getBitrate() != null) {
            this.appendOutput("Stream bitrate: ${stream.getBitrate()}\n");
          }
          if (stream.getSampleRate() != null) {
            this.appendOutput(
                "Stream sample rate: ${stream.getSampleRate()}\n");
          }
          if (stream.getSampleFormat() != null) {
            this.appendOutput(
                "Stream sample format: ${stream.getSampleFormat()}\n");
          }
          if (stream.getChannelLayout() != null) {
            this.appendOutput(
                "Stream channel layout: ${stream.getChannelLayout()}\n");
          }
          if (stream.getSampleAspectRatio() != null) {
            this.appendOutput(
                "Stream sample aspect ratio: ${stream.getSampleAspectRatio()}\n");
          }
          if (stream.getDisplayAspectRatio() != null) {
            this.appendOutput(
                "Stream display ascpect ratio: ${stream.getDisplayAspectRatio()}\n");
          }
          if (stream.getAverageFrameRate() != null) {
            this.appendOutput(
                "Stream average frame rate: ${stream.getAverageFrameRate()}\n");
          }
          if (stream.getRealFrameRate() != null) {
            this.appendOutput(
                "Stream real frame rate: ${stream.getRealFrameRate()}\n");
          }
          if (stream.getTimeBase() != null) {
            this.appendOutput("Stream time base: ${stream.getTimeBase()}\n");
          }
          if (stream.getCodecTimeBase() != null) {
            this.appendOutput(
                "Stream codec time base: ${stream.getCodecTimeBase()}\n");
          }
          if (stream.getTags() != null) {
            final tags = stream.getTags();
            if (tags != null) {
              tags.forEach((key, value) {
                this.appendOutput("Stream tag: ${key}:${tags[key]}\n");
              });
            }
          }
        }

        List<Chapter> chapters = information.getChapters();
        for (var i = 0; i < chapters.length; ++i) {
          Chapter chapter = chapters[i];
          if (chapter.getId() != null) {
            appendOutput("Chapter id: ${chapter.getId()}\n");
          }
          if (chapter.getTimeBase() != null) {
            appendOutput("Chapter time base: ${chapter.getTimeBase()}\n");
          }
          if (chapter.getStart() != null) {
            appendOutput("Chapter start: ${chapter.getStart()}\n");
          }
          if (chapter.getStartTime() != null) {
            appendOutput("Chapter start time: ${chapter.getStartTime()}\n");
          }
          if (chapter.getEnd() != null) {
            appendOutput("Chapter end: ${chapter.getEnd()}\n");
          }
          if (chapter.getEndTime() != null) {
            appendOutput("Chapter end time: ${chapter.getEndTime()}\n");
          }
          if (chapter.getTags() != null) {
            final tags = chapter.getTags();
            if (tags != null) {
              tags.forEach((key, value) {
                this.appendOutput("Chapter tag: ${key}:${tags[key]}\n");
              });
            }
          }
        }
      }
    });
  }

  String getOutputText() => _outputText;

  TextEditingController getUrlText() => _urlText;

  void dispose() {
    _urlText.dispose();
  }
}
