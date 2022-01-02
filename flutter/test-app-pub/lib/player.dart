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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'decoration.dart';

class PlayerTab {
  void setController(VideoPlayerController controller) {}
}

class EmbeddedPlayer extends StatefulWidget {
  final String _filePath;
  final PlayerTab _playerTab;

  EmbeddedPlayer(this._filePath, this._playerTab);

  @override
  _EmbeddedPlayerState createState() =>
      _EmbeddedPlayerState(new File(_filePath), _playerTab);
}

class _EmbeddedPlayerState extends State<EmbeddedPlayer> {
  final PlayerTab _playerTab;
  final File _file;
  VideoPlayerController? _videoPlayerController;
  bool startedPlaying = false;

  _EmbeddedPlayerState(this._file, this._playerTab);

  @override
  void initState() {
    super.initState();

    _videoPlayerController = VideoPlayerController.file(_file);
    _playerTab.setController(_videoPlayerController!);
  }

  @override
  void dispose() {
    _videoPlayerController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        elevation: 0,
        child: Center(
          child: FutureBuilder<bool>(
            future: Future.value(_videoPlayerController!.value.isInitialized),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.data == true) {
                return Container(
                  alignment: Alignment(0.0, 0.0),
                  child: VideoPlayer(_videoPlayerController!),
                );
              } else {
                return Container(
                  alignment: Alignment(0.0, 0.0),
                  decoration: videoPlayerFrameDecoration,
                );
              }
            },
          ),
        ));
  }
}
