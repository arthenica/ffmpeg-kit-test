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

import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:flutter/material.dart';

import 'abstract.dart';
import 'audio_tab.dart';
import 'command_tab.dart';
import 'concurrent_execution_tab.dart';
import 'decoration.dart';
import 'https_tab.dart';
import 'other_tab.dart';
import 'pipe_tab.dart';
import 'player.dart';
import 'progress_modal.dart';
import 'saf_tab.dart';
import 'subtitle_tab.dart';
import 'test_api.dart';
import 'vid_stab_tab.dart';
import 'video_tab.dart';
import 'video_util.dart';

GlobalKey _globalKey = GlobalKey();

void main() => runApp(FFmpegKitFlutterApp());

class FFmpegKitFlutterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appThemeData,
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  FFmpegKitFlutterAppState createState() => new FFmpegKitFlutterAppState();
}

class DecoratedTabBar extends StatelessWidget implements PreferredSizeWidget {
  DecoratedTabBar({required this.tabBar, required this.decoration});

  final TabBar tabBar;
  final BoxDecoration decoration;

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Container(decoration: decoration)),
        tabBar,
      ],
    );
  }
}

class FFmpegKitFlutterAppState extends State<MainPage>
    with TickerProviderStateMixin
    implements RefreshablePlayerDialogFactory {
  static final constantTabIndex = (Platform.isAndroid ? 0 : 0);
  static final videoTabIndex = (Platform.isAndroid ? 1 : 1);
  static final httpsTabIndex = (Platform.isAndroid ? 2 : 2);
  static final audioTabIndex = (Platform.isAndroid ? 3 : 3);
  static final subtitleTabIndex = (Platform.isAndroid ? 4 : 4);
  static final vidStabTabIndex = (Platform.isAndroid ? 5 : 5);
  static final pipeTabIndex = (Platform.isAndroid ? 6 : 6);
  static final concurrentExecutionTabIndex = (Platform.isAndroid ? 7 : 7);
  static final safTabIndex = (Platform.isAndroid ? 8 : -1);
  static final otherIndex = (Platform.isAndroid ? 9 : 8);

  // COMMON COMPONENTS
  late TabController _controller;
  ProgressModal? progressModal;

  // COMMAND TAB COMPONENTS
  CommandTab commandTab = new CommandTab();

  // VIDEO TAB COMPONENTS
  VideoTab videoTab = new VideoTab();

  // HTTPS TAB COMPONENTS
  HttpsTab httpsTab = new HttpsTab();

  // AUDIO TAB COMPONENTS
  AudioTab audioTab = new AudioTab();

  // SUBTITLE TAB COMPONENTS
  SubtitleTab subtitleTab = new SubtitleTab();

  // VIDSTAB TAB COMPONENTS
  VidStabTab vidStabTab = new VidStabTab();

  // PIPE TAB COMPONENTS
  PipeTab pipeTab = new PipeTab();

  // CONCURRENT EXECUTION TAB COMPONENTS
  ConcurrentExecutionTab concurrentExecutionTab = new ConcurrentExecutionTab();

  // SAF TAB COMPONENTS
  SafTab safTab = new SafTab();

  // OTHER TAB COMPONENTS
  OtherTab otherTab = new OtherTab();

  void refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    commandTab.init(this);
    videoTab.init(this);
    httpsTab.init(this);
    audioTab.init(this);
    subtitleTab.init(this);
    vidStabTab.init(this);
    pipeTab.init(this);
    concurrentExecutionTab.init(this);
    safTab.init(this);
    otherTab.init(this);

    _controller =
        TabController(length: (Platform.isAndroid ? 10 : 9), vsync: this);
    _controller.addListener(() {
      if (_controller.indexIsChanging) {
        if (_controller.index == constantTabIndex) {
          commandTab.setActive();
        } else if (_controller.index == videoTabIndex) {
          videoTab.setActive();
        } else if (_controller.index == httpsTabIndex) {
          httpsTab.setActive();
        } else if (_controller.index == audioTabIndex) {
          audioTab.setActive();
        } else if (_controller.index == subtitleTabIndex) {
          subtitleTab.setActive();
        } else if (_controller.index == vidStabTabIndex) {
          vidStabTab.setActive();
        } else if (_controller.index == pipeTabIndex) {
          pipeTab.setActive();
        } else if (_controller.index == concurrentExecutionTabIndex) {
          concurrentExecutionTab.setActive();
        } else if (_controller.index == safTabIndex) {
          safTab.setActive();
        } else if (_controller.index == otherIndex) {
          otherTab.setActive();
        }
      }
    });

    FFmpegKitConfig.init().then((_) {
      VideoUtil.prepareAssets();
      VideoUtil.registerApplicationFonts();

      Test.testCommonApiMethods();
      Test.testParseArguments();
      Test.setSessionHistorySizeTest();
    });
  }

  @override
  Widget build(BuildContext context) {
    var tabs;

    if (Platform.isAndroid) {
      tabs = <Tab>[
        Tab(text: "COMMAND"),
        Tab(text: "VIDEO"),
        Tab(text: "HTTPS"),
        Tab(text: "AUDIO"),
        Tab(text: "SUBTITLE"),
        Tab(text: "VID.STAB"),
        Tab(text: "PIPE"),
        Tab(text: "CONCURRENT EXECUTION"),
        Tab(text: "SAF"),
        Tab(text: "OTHER")
      ];
    } else {
      tabs = <Tab>[
        Tab(text: "COMMAND"),
        Tab(text: "VIDEO"),
        Tab(text: "HTTPS"),
        Tab(text: "AUDIO"),
        Tab(text: "SUBTITLE"),
        Tab(text: "VID.STAB"),
        Tab(text: "PIPE"),
        Tab(text: "CONCURRENT EXECUTION"),
        Tab(text: "OTHER")
      ];
    }

    var commandColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
          child: TextField(
            controller: commandTab.getCommandText(),
            decoration: inputDecoration('Enter command'),
            style: textFieldStyle,
          ),
        ),
        Container(
          padding: const EdgeInsets.only(bottom: 20),
          child: new InkWell(
            onTap: () => commandTab.runFFmpeg(),
            child: new Container(
              width: 130,
              height: 38,
              decoration: buttonDecoration,
              child: new Center(
                child: new Text(
                  'RUN FFMPEG',
                  style: buttonTextStyle,
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(bottom: 20),
          child: new InkWell(
            onTap: () => commandTab.runFFprobe(),
            child: new Container(
              width: 130,
              height: 38,
              decoration: buttonDecoration,
              child: new Center(
                child: new Text(
                  'RUN FFPROBE',
                  style: buttonTextStyle,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
              alignment: Alignment(-1.0, -1.0),
              margin: EdgeInsets.all(20.0),
              padding: EdgeInsets.all(4.0),
              decoration: outputDecoration,
              child: SingleChildScrollView(
                  reverse: true, child: Text(commandTab.getOutputText()))),
        )
      ],
    );
    var videoColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            child: Container(
              width: 200,
              alignment: Alignment.center,
              decoration: dropdownButtonDecoration,
              child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                style: dropdownButtonTextStyle,
                value: videoTab.getSelectedCodec(),
                items: videoTab.getVideoCodecList(),
                onChanged: videoTab.changedVideoCodec,
                iconSize: 0,
                isExpanded: false,
              )),
            )),
        Container(
          padding: const EdgeInsets.only(bottom: 20),
          child: new InkWell(
            onTap: () => videoTab.encodeVideo(),
            child: new Container(
              width: 100,
              height: 38,
              decoration: buttonDecoration,
              child: new Center(
                child: new Text(
                  'ENCODE',
                  style: buttonTextStyle,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.all(20.0),
            padding: EdgeInsets.all(4.0),
            child: FutureBuilder(
              future: videoTab.getVideoFile(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  File file = snapshot.data as File;
                  return Container(
                      alignment: Alignment(0.0, 0.0),
                      child:
                          EmbeddedPlayer("${file.path.toString()}", videoTab));
                } else {
                  return Container(
                    alignment: Alignment(0.0, 0.0),
                    decoration: videoPlayerFrameDecoration,
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
    var httpsColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
          child: TextField(
            controller: httpsTab.getUrlText(),
            decoration: inputDecoration('Enter https url'),
            style: textFieldStyle,
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: new InkWell(
            onTap: () => httpsTab.runGetMediaInformation(1),
            child: new Container(
              width: 180,
              height: 38,
              decoration: buttonDecoration,
              child: new Center(
                child: new Text(
                  'GET INFO FROM URL',
                  style: buttonTextStyle,
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: new InkWell(
            onTap: () => httpsTab.runGetMediaInformation(2),
            child: new Container(
              width: 180,
              height: 38,
              decoration: buttonDecoration,
              child: new Center(
                child: new Text(
                  'GET RANDOM INFO',
                  style: buttonTextStyle,
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: new InkWell(
            onTap: () => httpsTab.runGetMediaInformation(3),
            child: new Container(
              width: 180,
              height: 38,
              decoration: buttonDecoration,
              child: new Center(
                child: new Text(
                  'GET RANDOM INFO',
                  style: buttonTextStyle,
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: new InkWell(
            onTap: () => httpsTab.runGetMediaInformation(4),
            child: new Container(
              width: 160,
              height: 38,
              decoration: buttonDecoration,
              child: new Center(
                child: new Text(
                  'GET INFO AND FAIL',
                  style: buttonTextStyle,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
              alignment: Alignment(-1.0, -1.0),
              margin: EdgeInsets.all(20.0),
              padding: EdgeInsets.all(4.0),
              decoration: outputDecoration,
              child: SingleChildScrollView(
                  reverse: true, child: Text(httpsTab.getOutputText()))),
        )
      ],
    );
    var audioColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            child: Container(
              width: 200,
              alignment: Alignment.center,
              decoration: dropdownButtonDecoration,
              child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                style: dropdownButtonTextStyle,
                value: audioTab.getSelectedCodec(),
                items: audioTab.getAudioCodecList(),
                onChanged: audioTab.changedAudioCodec,
                iconSize: 0,
                isExpanded: false,
              )),
            )),
        Container(
          padding: const EdgeInsets.only(bottom: 20),
          child: new InkWell(
            onTap: () => audioTab.encodeAudio(),
            child: new Container(
              width: 100,
              height: 38,
              decoration: buttonDecoration,
              child: new Center(
                child: new Text(
                  'ENCODE',
                  style: buttonTextStyle,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
              alignment: Alignment(-1.0, -1.0),
              margin: EdgeInsets.all(20.0),
              padding: EdgeInsets.all(4.0),
              decoration: outputDecoration,
              child: SingleChildScrollView(
                  reverse: true, child: Text(audioTab.getOutputText()))),
        ),
      ],
    );
    var subtitleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(top: 80, bottom: 60),
          child: new InkWell(
            onTap: () => subtitleTab.burnSubtitles(),
            child: new Container(
              width: 180,
              height: 38,
              decoration: buttonDecoration,
              child: new Center(
                child: new Text(
                  'BURN SUBTITLES',
                  style: buttonTextStyle,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.all(20.0),
            padding: EdgeInsets.all(4.0),
            child: FutureBuilder(
              future: subtitleTab.getVideoWithSubtitlesFile(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  File file = snapshot.data as File;
                  return Container(
                      alignment: Alignment(0.0, 0.0),
                      child: EmbeddedPlayer("${file.path}", subtitleTab));
                } else {
                  return Container(
                    alignment: Alignment(0.0, 0.0),
                    decoration: videoPlayerFrameDecoration,
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
    var vidStabColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Container(
            margin: EdgeInsets.all(10.0),
            padding: EdgeInsets.all(4.0),
            child: FutureBuilder(
              future: vidStabTab.getVideoFile(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  File file = snapshot.data as File;
                  return Container(
                      alignment: Alignment(0.0, 0.0),
                      child: EmbeddedPlayer(
                          "${file.path}", vidStabTab.videoController));
                } else {
                  return Container(
                    alignment: Alignment(0.0, 0.0),
                    decoration: videoPlayerFrameDecoration,
                  );
                }
              },
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: new InkWell(
            onTap: () => vidStabTab.stabilizeVideo(),
            child: new Container(
              width: 180,
              height: 38,
              decoration: buttonDecoration,
              child: new Center(
                child: new Text(
                  'STABILIZE VIDEO',
                  style: buttonTextStyle,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.all(10.0),
            padding: EdgeInsets.all(4.0),
            child: FutureBuilder(
              future: vidStabTab.getStabilizedVideoFile(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  File file = snapshot.data as File;
                  return Container(
                      alignment: Alignment(0.0, 0.0),
                      child: EmbeddedPlayer("${file.path}",
                          vidStabTab.stabilizedVideoController));
                } else {
                  return Container(
                    alignment: Alignment(0.0, 0.0),
                    decoration: videoPlayerFrameDecoration,
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
    var pipeColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: new InkWell(
            onTap: () => pipeTab.createVideo(),
            child: new Container(
              width: 180,
              height: 38,
              decoration: buttonDecoration,
              child: new Center(
                child: new Text(
                  'CREATE',
                  style: buttonTextStyle,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.all(10.0),
            padding: EdgeInsets.all(4.0),
            child: FutureBuilder(
              future: pipeTab.getVideoFile(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  File file = snapshot.data as File;
                  return Container(
                      alignment: Alignment(0.0, 0.0),
                      child: EmbeddedPlayer("${file.path}", pipeTab));
                } else {
                  return Container(
                    alignment: Alignment(0.0, 0.0),
                    decoration: videoPlayerFrameDecoration,
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
    var concurrentExecutionColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
              child: new InkWell(
                onTap: () => concurrentExecutionTab.encodeVideo(1),
                child: new Container(
                  width: 64,
                  height: 38,
                  decoration: buttonDecoration,
                  child: new Center(
                    child: new Text(
                      'ENCODE 1',
                      style: buttonSmallTextStyle,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
              child: new InkWell(
                onTap: () => concurrentExecutionTab.encodeVideo(2),
                child: new Container(
                  width: 64,
                  height: 38,
                  decoration: buttonDecoration,
                  child: new Center(
                    child: new Text(
                      'ENCODE 2',
                      style: buttonSmallTextStyle,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
              child: new InkWell(
                onTap: () => concurrentExecutionTab.encodeVideo(3),
                child: new Container(
                  width: 64,
                  height: 38,
                  decoration: buttonDecoration,
                  child: new Center(
                    child: new Text(
                      'ENCODE 3',
                      style: buttonSmallTextStyle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: new InkWell(
                onTap: () => concurrentExecutionTab.runCancel(1),
                child: new Container(
                  width: 62,
                  height: 38,
                  decoration: buttonDecoration,
                  child: new Center(
                    child: new Text(
                      'CANCEL 1',
                      style: buttonSmallTextStyle,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(right: 10),
              child: new InkWell(
                onTap: () => concurrentExecutionTab.runCancel(2),
                child: new Container(
                  width: 62,
                  height: 38,
                  decoration: buttonDecoration,
                  child: new Center(
                    child: new Text(
                      'CANCEL 2',
                      style: buttonSmallTextStyle,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: new InkWell(
                onTap: () => concurrentExecutionTab.runCancel(3),
                child: new Container(
                  width: 62,
                  height: 38,
                  decoration: buttonDecoration,
                  child: new Center(
                    child: new Text(
                      'CANCEL 3',
                      style: buttonSmallTextStyle,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: new InkWell(
                onTap: () => concurrentExecutionTab.runCancel(0),
                child: new Container(
                  width: 76,
                  height: 38,
                  decoration: buttonDecoration,
                  child: new Center(
                    child: new Text(
                      'CANCEL ALL',
                      style: buttonSmallTextStyle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
              alignment: Alignment(-1.0, -1.0),
              margin: EdgeInsets.all(20.0),
              padding: EdgeInsets.all(4.0),
              decoration: outputDecoration,
              child: SingleChildScrollView(
                  reverse: true,
                  child: Text(concurrentExecutionTab.getOutputText()))),
        )
      ],
    );
    var safColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(top: 30, bottom: 20),
          child: new InkWell(
            onTap: () => safTab.encodeVideo(),
            child: new Container(
              width: 130,
              height: 38,
              decoration: buttonDecoration,
              child: new Center(
                child: new Text(
                  'RUN FFMPEG',
                  style: buttonTextStyle,
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(bottom: 10),
          child: new InkWell(
            onTap: () => safTab.runFFprobe(),
            child: new Container(
              width: 130,
              height: 38,
              decoration: buttonDecoration,
              child: new Center(
                child: new Text(
                  'RUN FFPROBE',
                  style: buttonTextStyle,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
              alignment: Alignment(-1.0, -1.0),
              margin: EdgeInsets.all(20.0),
              padding: EdgeInsets.all(4.0),
              decoration: outputDecoration,
              child: SingleChildScrollView(
                  reverse: true, child: Text(safTab.getOutputText()))),
        )
      ],
    );
    var otherColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            child: Container(
              width: 200,
              alignment: Alignment.center,
              decoration: dropdownButtonDecoration,
              child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                style: dropdownButtonTextStyle,
                value: otherTab.getSelectedCodec(),
                items: otherTab.getTestList(),
                onChanged: otherTab.changedTest,
                iconSize: 0,
                isExpanded: false,
              )),
            )),
        Container(
          padding: const EdgeInsets.only(bottom: 10),
          child: new InkWell(
            onTap: () => otherTab.runTest(),
            child: new Container(
              width: 100,
              height: 38,
              decoration: buttonDecoration,
              child: new Center(
                child: new Text(
                  'RUN',
                  style: buttonTextStyle,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
              alignment: Alignment(-1.0, -1.0),
              margin: EdgeInsets.all(20.0),
              padding: EdgeInsets.all(4.0),
              decoration: outputDecoration,
              child: SingleChildScrollView(
                  reverse: true, child: Text(otherTab.getOutputText()))),
        ),
      ],
    );

    var columns = (Platform.isAndroid)
        ? <Widget>[
            commandColumn,
            videoColumn,
            httpsColumn,
            audioColumn,
            subtitleColumn,
            vidStabColumn,
            pipeColumn,
            concurrentExecutionColumn,
            safColumn,
            otherColumn
          ]
        : <Widget>[
            commandColumn,
            videoColumn,
            httpsColumn,
            audioColumn,
            subtitleColumn,
            vidStabColumn,
            pipeColumn,
            concurrentExecutionColumn,
            otherColumn
          ];

    return Scaffold(
        key: _globalKey,
        appBar: AppBar(
          title: Text('FFmpegKit Flutter'),
          centerTitle: true,
        ),
        bottomNavigationBar: Material(
          child: DecoratedTabBar(
            tabBar: TabBar(
              isScrollable: true,
              tabs: tabs,
              controller: _controller,
              labelColor: selectedTabColor,
              unselectedLabelColor: unSelectedTabColor,
            ),
            decoration: tabBarDecoration,
          ),
        ),
        body: TabBarView(
          children: columns,
          controller: _controller,
        ));
  }

  @override
  void dialogHide() {
    if (progressModal != null) {
      progressModal?.hide();
    }
  }

  @override
  void dialogShowCancellable(String message, Function cancelFunction) {
    progressModal = new ProgressModal(_globalKey.currentContext!);
    progressModal?.show(message, cancelFunction: cancelFunction);
  }

  @override
  void dialogShow(String message) {
    progressModal = new ProgressModal(_globalKey.currentContext!);
    progressModal?.show(message);
  }

  @override
  void dialogUpdate(String message) {
    progressModal?.update(message: message);
  }

  @override
  void dispose() {
    commandTab.dispose();
    super.dispose();
  }
}
