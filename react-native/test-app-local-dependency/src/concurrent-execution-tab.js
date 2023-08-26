import React from 'react';
import {ScrollView, Text, TouchableOpacity, View} from 'react-native';
import {styles} from './style';
import {FFmpegKit, FFmpegKitConfig, ReturnCode} from 'ffmpeg-kit-react-native';
import {ffprint, listFFmpegSessions, notNull} from './util';
import VideoUtil from "./video-util";
import RNFS from "react-native-fs";

export default class ConcurrentExecutionTab extends React.Component {
    constructor(props) {
        super(props);

        this.state = {
            outputText: '',
            sessionId1: 0,
            sessionId2: 0,
            sessionId3: 0
        };
    }

    componentDidMount() {
        this.props.navigation.addListener('focus', (_) => {
            this.clearOutput();
            this.setActive();
        });
    }

    async setActive() {
        ffprint("Concurrent Execution Tab Activated");
        await FFmpegKitConfig.clearSessions();
        FFmpegKitConfig.enableLogCallback(this.logCallback);
        FFmpegKitConfig.enableStatisticsCallback(undefined);
    }

    logCallback = (log) => {
        this.appendOutput(`${log.getSessionId()} -> ${log.getMessage()}`);
    };

    appendOutput(logMessage) {
        this.setState({outputText: this.state.outputText + logMessage});
    };

    clearOutput() {
        this.setState({outputText: ''});
    }

    encodeVideo(buttonNumber) {
        let image1Path = VideoUtil.assetPath(VideoUtil.ASSET_1);
        let image2Path = VideoUtil.assetPath(VideoUtil.ASSET_2);
        let image3Path = VideoUtil.assetPath(VideoUtil.ASSET_3);
        let videoFile = this.getVideoFile(buttonNumber);

        ffprint(`Testing CONCURRENT EXECUTION for button ${buttonNumber}.`);

        let ffmpegCommand = VideoUtil.generateEncodeVideoScript(image1Path, image2Path, image3Path, videoFile, "mpeg4", "");

        ffprint(`FFmpeg process starting for button ${buttonNumber} with arguments: \'${ffmpegCommand}\'.`);

        FFmpegKit.executeAsync(ffmpegCommand, async (session) => {
                const sessionId = await session.getSessionId();
                const state = FFmpegKitConfig.sessionStateToString(await session.getState());
                const returnCode = await session.getReturnCode();
                const failStackTrace = await session.getFailStackTrace();

                if (ReturnCode.isCancel(returnCode)) {
                    ffprint(`FFmpeg process ended with cancel for button ${buttonNumber} with sessionId ${sessionId}.`);
                } else {
                    ffprint(`FFmpeg process ended with state ${state} and rc ${returnCode} for button ${buttonNumber} with sessionId ${sessionId}.${notNull(failStackTrace, "\\n")}`);
                }
            }
        ).then(session => {
            const sessionId = session.getSessionId();

            ffprint(`Async FFmpeg process started for button ${buttonNumber} with sessionId ${sessionId}.`);

            switch (buttonNumber) {
                case 1:
                    this.setState({sessionId1: sessionId});
                    break;
                case 2:
                    this.setState({sessionId2: sessionId});
                    break;
                default:
                    this.setState({sessionId3: sessionId});
                    FFmpegKitConfig.setSessionHistorySize(3);
            }

            listFFmpegSessions();
        });
    }

    getVideoFile(buttonNumber) {
        return `${RNFS.CachesDirectoryPath}/video${buttonNumber}.mp4`;
    }

    cancel(buttonNumber) {
        let sessionId = 0;

        switch (buttonNumber) {
            case 1:
                sessionId = this.state.sessionId1;
                break;
            case 2:
                sessionId = this.state.sessionId2;
                break;
            case 3:
                sessionId = this.state.sessionId3;
        }

        ffprint(`Cancelling FFmpeg process for button ${buttonNumber} with sessionId ${sessionId}.`);

        if (sessionId === 0) {
            FFmpegKit.cancel();
        } else {
            FFmpegKit.cancel(sessionId);
        }
    }

    render() {
        return (
            <View style={styles.screenStyle}>
                <View style={styles.headerViewStyle}>
                    <Text style={styles.headerTextStyle}>
                        FFmpegKit ReactNative
                    </Text>
                </View>
                <View style={[styles.buttonViewStyle, {paddingTop: 20, flexDirection: 'row'}]}>
                    <TouchableOpacity
                        style={[styles.buttonStyle, {width: 92}]}
                        onPress={() => this.encodeVideo(1)}>
                        <Text style={styles.buttonTextStyle}>ENCODE 1</Text>
                    </TouchableOpacity>
                    <TouchableOpacity
                        style={[styles.buttonStyle, {width: 92, marginHorizontal: 20}]}
                        onPress={() => this.encodeVideo(2)}>
                        <Text style={styles.buttonTextStyle}>ENCODE 2</Text>
                    </TouchableOpacity>
                    <TouchableOpacity
                        style={[styles.buttonStyle, {width: 92}]}
                        onPress={() => this.encodeVideo(3)}>
                        <Text style={styles.buttonTextStyle}>ENCODE 3</Text>
                    </TouchableOpacity>
                </View>
                <View style={[styles.buttonViewStyle, {paddingBottom: 0, flexDirection: 'row'}]}>
                    <TouchableOpacity
                        style={[styles.buttonStyle, {width: 86}]}
                        onPress={() => this.cancel(1)}>
                        <Text style={styles.buttonTextStyle}>CANCEL 1</Text>
                    </TouchableOpacity>
                    <TouchableOpacity
                        style={[styles.buttonStyle, {width: 86, marginHorizontal: 10}]}
                        onPress={() => this.cancel(2)}>
                        <Text style={styles.buttonTextStyle}>CANCEL 2</Text>
                    </TouchableOpacity>
                    <TouchableOpacity
                        style={[styles.buttonStyle, {width: 86, marginRight: 10}]}
                        onPress={() => this.cancel(3)}>
                        <Text style={styles.buttonTextStyle}>CANCEL 3</Text>
                    </TouchableOpacity>
                    <TouchableOpacity
                        style={[styles.buttonStyle, {width: 80}]}
                        onPress={() => this.cancel(0)}>
                        <Text style={styles.buttonTextStyle}>CANCEL ALL</Text>
                    </TouchableOpacity>
                </View>
                <View style={styles.outputViewStyle}>
                    <ScrollView
                        ref={(view) => {
                            this.scrollViewReference = view;
                        }}
                        onContentSizeChange={(width, height) => this.scrollViewReference.scrollTo({y: height})}
                        style={styles.outputScrollViewStyle}>
                        <Text style={styles.outputTextStyle}>{this.state.outputText}</Text>
                    </ScrollView>
                </View>
            </View>
        );
    };

}
